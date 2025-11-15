//
//  HeartRateMonitorManager.swift
//  hr_monitor
//
//  Created by halle on 2025/9/29.
//

import HealthKit
import WatchConnectivity
//import UIKit
import WatchKit

class HeartRateMonitorManager: NSObject, ObservableObject {
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var heartRateQuery: HKQuery?
    private var connectivityManager: WatchConnectivityManager?
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private var lastProcessedSampleID: UUID?
    private var processingTimer: Timer?
    
    
    private var cloudServiceManager: CloudServiceManager
        private let deviceId: String
        private let sessionId: String
    
    @Published var currentHeartRate: Double = 0
    @Published var lastHeartRateTimestamp: Date = Date()
    @Published var isAuthorized = false
    @Published var isMonitoring = false
    
    var onHeartRateUpdate: ((Double, Date) -> Void)?
    
    override init() {
        self.deviceId = WKInterfaceDevice.current().identifierForVendor?.uuidString ?? "unknown"
                self.sessionId = UUID().uuidString
                self.cloudServiceManager = CloudServiceManager()
        
        super.init()
        self.connectivityManager = WatchConnectivityManager(heartRateMonitor: self)
    }
    
    // MARK: - HealthKit 授权
    func authorizeHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit 不可用")
            return
        }
        
        let typesToRead: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            //            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            //            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]
        // 定义要写入的数据类型（重要！）
        let shareTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            //                HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            // 添加其他您想要写入的数据类型
        ]
        
        healthStore.requestAuthorization(toShare: shareTypes, read: typesToRead) { [weak self] success, error in
            //            DispatchQueue.main.async {
            if success {
                print("✅ HealthKit 授权成功")
                self?.isAuthorized = true
                // 通知手机授权状态
                // 没有用，watchconnectivityManager初始化需要当前类，所以没法发送出去，授权失败时同理，后面这部分逻辑需要修改
                //self?.connectivityManager?.sendAuthorizationStatus("已授权")
            } else {
                print("❌ HealthKit 授权失败: \(error?.localizedDescription ?? "未知错误")")
                self?.isAuthorized = false
                // 没有用，watchconnectivityManager初始化需要当前类，所以没法发送出去，授权失败时同理，后面这部分逻辑需要修改
                // self?.connectivityManager?.sendAuthorizationStatus("授权失败")
            }
            //            }
        }
    }
    
    // MARK: - 心率监测
    func startHeartRateMonitoring() {
        guard isAuthorized else {
            print("❌ 未获得 HealthKit 授权")
            return
        }
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            workoutSession?.startActivity(with: Date())
            startHeartRateQuery()
            isMonitoring = true
            print("✅ 开始心率监测")
        } catch {
            print("❌ 无法开始训练: \(error)")
        }
    }
    
    func stopHeartRateMonitoring() {
        heartRateQuery = nil
        workoutSession?.stopActivity(with: Date())
        workoutSession?.end()
        workoutSession = nil
        isMonitoring = false
        print("🛑 停止心率监测")
    }
    
    private func startHeartRateQuery() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("❌ 无法获取心率类型")
            return
        }
        
        startSmartHeartRateMonitoring()
    }
    
    
    private func startSmartHeartRateMonitoring() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKAnchoredObjectQuery(
            type: quantityType,
            predicate: nil,  // 无时间限制
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.processSamplesIntelligently(samples)
        }
        
        query.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.processSamplesIntelligently(samples)
        }
        
        healthStore.execute(query)
        heartRateQuery = query
        
        // 启动定期清理
        startCleanupTimer()
    }
    
    private func processSamplesIntelligently(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        // 智能过滤：只处理最新的、未处理过的样本
        let sortedSamples = heartRateSamples.sorted { $0.startDate > $1.startDate }
        
        for sample in sortedSamples.prefix(2) { // 只处理最新的2个
            // 避免重复处理同一个样本
            if sample.uuid != lastProcessedSampleID {
                processSingleSample(sample)
                lastProcessedSampleID = sample.uuid
                break  // 只处理一个最新样本
            }
        }
    }
    
    private func processSingleSample(_ sample: HKQuantitySample) {
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let value = sample.quantity.doubleValue(for: heartRateUnit)
        let sampleTimestamp = sample.startDate
        
        DispatchQueue.main.async {
            self.currentHeartRate = value
            self.lastHeartRateTimestamp = sampleTimestamp
            
            self.onHeartRateUpdate?(value, sampleTimestamp)
            self.connectivityManager?.sendHeartRateToPhone(value, timestamp: sampleTimestamp)
            
            print("❤️ 智能心率: \(value) BPM， 测量时间： \(sampleTimestamp)")
        }
    }
    
    private func startCleanupTimer() {
        processingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            // 定期清理，防止内存积累
            self?.lastProcessedSampleID = nil
        }
    }
    
    // 为加入音乐功能的ai代码
    private func processSingleHeartRateSample(_ sample: HKQuantitySample) {
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let value = sample.quantity.doubleValue(for: heartRateUnit)
        let sampleTimestamp = sample.startDate
        
        DispatchQueue.main.async {
            self.currentHeartRate = value
            self.lastHeartRateTimestamp = sampleTimestamp
            
            // 发送到手机
            self.connectivityManager?.sendHeartRateToPhone(value, timestamp: sampleTimestamp)
            
            // 上传到云端
            let heartRateData = HeartRateData(
                value: value,
                timestamp: sampleTimestamp,
                deviceId: self.deviceId,
                sessionId: self.sessionId
            )
            self.cloudServiceManager.uploadHeartRateData(heartRateData)
            
            print("❤️ 心率: \(value) BPM - 已上传云端")
        }
    }
    
    func startCompleteMonitoring() {
        startHeartRateMonitoring()
        cloudServiceManager.startPeriodicTasks()
    }
    
    func stopCompleteMonitoring() {
        stopHeartRateMonitoring()
        cloudServiceManager.stopPeriodicTasks()
    }
}
