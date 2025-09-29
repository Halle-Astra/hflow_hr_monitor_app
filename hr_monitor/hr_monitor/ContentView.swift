//
//  ContentView.swift
//  hr_monitor
//
//  Created by halle on 2025/9/1.
//

import SwiftUI
import HealthKit

class HeartRateMonitorManager: NSObject {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private var backgroundQuery: HKObserverQuery?
    private var timer: Timer?
    private var queryInterval: TimeInterval = 1.0 // 默认5秒间隔
    
    // 心率数据更新回调
    var onHeartRateUpdate: ((Double, Date) -> Void)?
    var onAuthorizationStatus: ((Bool, String) -> Void)?
    
    // 设置查询间隔（秒）
    func setQueryInterval(_ interval: TimeInterval) {
        self.queryInterval = interval
        // 如果正在监控，重新启动定时器
        if timer != nil {
            stopHeartRateMonitoring()
            startHeartRateMonitoring()
        }
    }
    
    // 初始化并请求权限
    func authorizeHealthKit(completion: ((Bool) -> Void)? = nil) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit 不可用")
            completion?(false)
            return
        }
        // 只请求读取权限，不需要写入权限
        let readTypes: Set<HKSampleType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: [heartRateType], read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("HealthKit 授权请求完成")
                    // 授权请求完成，但实际权限状态需要检查
                    self?.checkActualAuthorizationStatus(completion: completion)
                } else {
                    print("HealthKit 授权失败: \(error?.localizedDescription ?? "未知错误")")
                    completion?(false)
                }
            }
        }
        return
        
    }
    
    // 检查实际授权状态
    private func checkActualAuthorizationStatus(completion: ((Bool) -> Void)? = nil) {
        let status = healthStore.authorizationStatus(for: heartRateType)
        
        switch status {
        case .sharingAuthorized:
            print("已获得心率数据访问权限")
            completion?(true)
            onAuthorizationStatus?(true, "权限已授权")
        case .sharingDenied:
            print("用户拒绝了心率数据访问权限")
            completion?(false)
            onAuthorizationStatus?(false, "权限被拒绝")
        case .notDetermined:
            print("权限状态未确定")
            completion?(false)
            onAuthorizationStatus?(false, "权限未确定")
        @unknown default:
            print("未知权限状态")
            completion?(false)
            onAuthorizationStatus?(false, "未知权限状态")
        }
    }
    
    // 开始实时监控心率
    func startHeartRateMonitoring() {
        // 停止之前的监控（如果有）
        stopHeartRateMonitoring()
        
        // 检查授权状态
        let status = healthStore.authorizationStatus(for: heartRateType)
        if status != .sharingAuthorized {
            print("未获得心率数据访问权限，当前状态: \(status.rawValue)")
            // self.authorizeHealthKit(completion: nil)
            // return
        }
        
        print("开始心率监控")
        
        // 启动后台观察查询（检测新数据）
        startBackgroundObserverQuery()
        
        // 启动定时器定期查询
        timer = Timer.scheduledTimer(withTimeInterval: queryInterval, repeats: true) { [weak self] _ in
            self?.fetchLatestHeartRate()
            print("----\(Date())-----")
        }
        
        // 立即获取一次当前心率
        fetchLatestHeartRate()
        
        // 启动定时器
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    // 启动后台观察查询
    private func startBackgroundObserverQuery() {
        // 停止之前的观察查询
        if let existingQuery = backgroundQuery {
            healthStore.stop(existingQuery)
            backgroundQuery = nil
        }
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] (query, completionHandler, error) in
            if let error = error {
                print("观察查询错误: \(error.localizedDescription)")
                completionHandler()
                return
            }
            
            print("检测到新心率数据，立即获取")
            // 检测到新数据时立即获取最新心率
            self?.fetchLatestHeartRate()
            
            // 调用完成处理程序
            completionHandler()
        }
        
        backgroundQuery = query
        healthStore.execute(query)
        
        // 启用后台交付（可选）
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
            if success {
                print("后台心率数据交付已启用")
            } else {
                print("启用后台交付失败: \(error?.localizedDescription ?? "未知错误")")
            }
        }
    }
    
    // 获取最新心率数据
    private func fetchLatestHeartRate() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            
            if let error = error {
                print("获取心率数据错误: \(error.localizedDescription)")
                return
            }
            
            guard var sample = samples?.first as? HKQuantitySample else {
                print("没有心率数据")
                return
            }
            
            var heartRateUnit = HKUnit(from: "count/min")
            var heartRate = sample.quantity.doubleValue(for: heartRateUnit)
            print("\n\(samples)...\n")
            print("获取到心率: \(heartRate) bpm, 时间: \(sample.endDate)")
            
            DispatchQueue.main.async {
                self?.onHeartRateUpdate?(heartRate, sample.endDate)
            }
        }
        
        healthStore.execute(query)
    }
    
    // 停止监控
    func stopHeartRateMonitoring() {
        print("停止心率监控...")
        
        // 停止观察查询
        if let query = backgroundQuery {
            healthStore.stop(query)
            backgroundQuery = nil
        }
        
        // 停止定时器
        timer?.invalidate()
        timer = nil
        
        // 禁用后台交付
        healthStore.disableAllBackgroundDelivery { success, error in
            if success {
                print("后台交付已禁用")
            } else {
                print("禁用后台交付失败: \(error?.localizedDescription ?? "未知错误")")
            }
        }
        
        print("心率监控已停止")
    }
}
