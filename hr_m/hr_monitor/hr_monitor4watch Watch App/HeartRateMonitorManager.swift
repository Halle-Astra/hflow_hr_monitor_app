//
//  HeartRateMonitorManager.swift
//  hr_monitor
//
//  Created by halle on 2025/9/29.
//

import HealthKit
import WatchConnectivity


class HeartRateMonitorManager: NSObject, ObservableObject {
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var heartRateQuery: HKQuery?
    private var connectivityManager: WatchConnectivityManager?
    
    @Published var currentHeartRate: Double = 0
    @Published var lastHeartRateTimestamp: Date = Date()
    @Published var isAuthorized = false
    @Published var isMonitoring = false
    
    var onHeartRateUpdate: ((Double, Date) -> Void)?
    
    override init() {
        super.init()
        self.connectivityManager = WatchConnectivityManager(heartRateMonitor: self)
    }
    
    // MARK: - HealthKit 授权
    func authorizeHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit 不可用")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ HealthKit 授权成功")
                    self?.isAuthorized = true
                    // 通知手机授权状态
                    self?.connectivityManager?.sendAuthorizationStatus("已授权")
                } else {
                    print("❌ HealthKit 授权失败: \(error?.localizedDescription ?? "未知错误")")
                    self?.isAuthorized = false
                    self?.connectivityManager?.sendAuthorizationStatus("授权失败")
                }
            }
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
        
        let query = HKAnchoredObjectQuery(
            type: quantityType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.processHeartRateSamples(samples)
        }
        
        query.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) in
            self?.processHeartRateSamples(samples)
        }
        
        healthStore.execute(query)
        heartRateQuery = query
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        for sample in heartRateSamples {
            let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
            let value = sample.quantity.doubleValue(for: heartRateUnit)
            let sampleTimestamp = sample.startDate
            
            DispatchQueue.main.async {
                self.currentHeartRate = value
                self.lastHeartRateTimestamp = sampleTimestamp
                
                // 调用更新回调
                self.onHeartRateUpdate?(value, sampleTimestamp)
                
                // 发送到手机
                self.connectivityManager?.sendHeartRateToPhone(value, timestamp: sampleTimestamp)
                
                print("❤️ 心率更新: \(value) BPM, 时间: \(sampleTimestamp)")
            }
        }
    }
}
