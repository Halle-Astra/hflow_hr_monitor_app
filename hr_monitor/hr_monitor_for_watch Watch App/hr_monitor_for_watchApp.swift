//
//  hr_monitor_for_watchApp.swift
//  hr_monitor_for_watch Watch App
//
//  Created by halle on 2025/9/29.
////
//
//import SwiftUI
//
//@main
//struct hr_monitor_for_watch_Watch_AppApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}


//
//import WatchKit
//import HealthKit
//import WatchConnectivity
//
//class WorkoutManager: NSObject, ObservableObject, WCSessionDelegate {
//    private var healthStore = HKHealthStore()
//    private var workoutSession: HKWorkoutSession?
//    private var heartRateQuery: HKQuery?
//    
//    @Published var heartRate: Double = 0
//    private var session: WCSession?
//    
//    override init() {
//        super.init()
//        setupWatchConnectivity()
//    }
//    
//    // 设置 WatchConnectivity
//    private func setupWatchConnectivity() {
//        if WCSession.isSupported() {
//            session = WCSession.default
//            session?.delegate = self
//            session?.activate()
//        }
//    }
//    
//    // 开始监测心率
//    func startWorkout() {
//        let workoutConfiguration = HKWorkoutConfiguration()
//        workoutConfiguration.activityType = .running
//        workoutConfiguration.locationType = .outdoor
//        
//        do {
//            workoutSession = try HKWorkoutSession(healthStore: healthStore,
//                                                 configuration: workoutConfiguration)
//            workoutSession?.startActivity(with: Date())
//            startHeartRateQuery()
//        } catch {
//            print("无法开始训练: \(error)")
//        }
//    }
//    
//    // 查询心率数据
//    private func startHeartRateQuery() {
//        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
//        
//        let query = HKAnchoredObjectQuery(
//            type: quantityType,
//            predicate: nil,
//            anchor: nil,
//            limit: HKObjectQueryNoLimit
//        ) { [weak self] (query, samples, deletedObjects, anchor, error) in
//            self?.processHeartRateSamples(samples)
//        }
//        
//        query.updateHandler = { [weak self] (query, samples, deletedObjects, anchor, error) in
//            self?.processHeartRateSamples(samples)
//        }
//        
//        healthStore.execute(query)
//        heartRateQuery = query
//    }
//    
//    // 处理心率样本并发送到 iPhone
//    private func processHeartRateSamples(_ samples: [HKSample]?) {
//        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
//        
//        for sample in heartRateSamples {
//            let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
//            let value = sample.quantity.doubleValue(for: heartRateUnit)
//            
//            DispatchQueue.main.async {
//                self.heartRate = value
//                // 实时发送到 iPhone
//                self.sendHeartRateToiPhone(value)
//            }
//        }
//    }
//    
//    // 通过 WatchConnectivity 发送数据到 iPhone
//    private func sendHeartRateToiPhone(_ heartRate: Double) {
//        let message: [String: Any] = [
//            "type": "heartRate",
//            "value": heartRate,
//            "timestamp": Date().timeIntervalSince1970
//        ]
//        
//        session?.sendMessage(message, replyHandler: nil) { error in
//            print("发送心率数据失败: \(error)")
//        }
//    }
//    
//    // WCSessionDelegate 方法
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        // Session 激活完成
//    }
//}


import SwiftUI

@main
struct hr_monitor_Watch_App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
