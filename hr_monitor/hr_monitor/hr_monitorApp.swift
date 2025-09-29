//
//  hr_monitorApp.swift
//  hr_monitor
//
//  Created by halle on 2025/9/1.
//
//
//import SwiftUI

import SwiftUI
import HealthKit


//
@main
struct hr_monitorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



struct ContentView: View {
    private let heartRateMonitor = HeartRateMonitorManager()
    @State private var currentHeartRate: Double = 10
    @State private var isAuthorized = false
    @State private var t = Date()
    @State private var tt = Date()
    
    var body: some View {
        VStack {
            Text("心率监控")
                .font(.title)
            
            if isAuthorized {
                Text("当前心率: \(Int(self.currentHeartRate)) bpm")
                    .font(.largeTitle)
                    .padding()
                Text("hr time: \(tt)")
                Text("time: \(t)")
            } else {
                Text("正在请求 HealthKit 权限...")
                    .padding()
            }
        }
        .onAppear {
            // 设置心率更新回调
            heartRateMonitor.onHeartRateUpdate = { heartRate, hrt in
                DispatchQueue.main.async {
                    self.currentHeartRate = heartRate
                    self.t = Date()
                    self.tt = hrt
                }
            }
            
            // 请求权限并开始监控
            heartRateMonitor.authorizeHealthKit()
            DispatchQueue.main.async {
                self.isAuthorized = true
                if self.isAuthorized {
                    // 权限获取成功后开始监测
                    self.heartRateMonitor.startHeartRateMonitoring()
                }
            }
            // isAuthorized = true
        }
        .onDisappear {
            // 当视图消失时停止监控
            heartRateMonitor.stopHeartRateMonitoring()
        }
    }
}


#Preview {
    ContentView()
}
