//
//  ContentView.swift
//  hr_monitor
//
//  Created by halle on 2025/9/1.
//

import SwiftUI
import Foundation
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//}
//
//
//
//

import HealthKit

class HeartRateMonitorManager: NSObject {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private var observerQuery: HKObserverQuery?
    
    // 心率数据更新回调
    var onHeartRateUpdate: ((Double) -> Void)?
    
    // 初始化并请求权限
    func authorizeHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit 不可用")
            return
        }
        
        let readTypes: Set<HKSampleType> = [heartRateType]
        let writeTypes: Set<HKSampleType> = []
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            if !success {
                print("HealthKit 授权失败: \(error?.localizedDescription ?? "未知错误")")
            }
        }
    }
    
    // 开始实时监控心率
    func startHeartRateMonitoring() {
        // 停止之前的查询（如果有）
        stopHeartRateMonitoring()
        HKHealthStore().enableBackgroundDelivery(for: heartRateType,
                                                 frequency: .immediate) { success, error in
            print("后台传递启用状态: \(success)")
        }
        // 这会告诉系统你正在进行需要实时数据的活动

        // 创建观察查询
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, error in
            guard error == nil else {
                print("观察查询错误: \(error!.localizedDescription)")
                return
            }
            print("调用一次fetch，\(Date()) fromHKObserverQuery")
            self?.fetchLatestHeartRate()
        }
        
        // 保存查询引用
        observerQuery = query
        
        healthStore.execute(query)
        
        // 立即获取一次当前心率
        print("调用一次fetch from startHeartRateMonitoring")
        fetchLatestHeartRate()
    }
    
    // 获取最新心率数据
    private func fetchLatestHeartRate() {
        print("调用一次fetch")
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            
            guard let sample = samples?.first as? HKQuantitySample else {
                print("没有心率数据: \(error?.localizedDescription ?? "未知错误")")
                return
            }
            
            let heartRateUnit = HKUnit(from: "count/min")
            let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
            
            DispatchQueue.main.async {
                self?.onHeartRateUpdate?(heartRate)
            }
        }
        
        healthStore.execute(query)
    }
    
    // 停止监控
    func stopHeartRateMonitoring() {
        if let query = observerQuery {
            healthStore.stop(query)
            observerQuery = nil
        }
    }
}
