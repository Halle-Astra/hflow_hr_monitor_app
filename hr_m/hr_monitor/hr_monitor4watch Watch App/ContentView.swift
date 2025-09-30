//
//  ContentView.swift
//  hr_monitor4watch Watch App
//
//  Created by halle on 2025/9/29.
//

//import SwiftUI
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


import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var heartRateMonitor = HeartRateMonitorManager()
    private let healthStore = HKHealthStore()
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    var body: some View {
        VStack(spacing: 15) {
            // 标题
            
            // 授权状态
            if heartRateMonitor.isAuthorized {
                // 心率显示
                VStack {
                    
                    Text("\(Int(heartRateMonitor.currentHeartRate))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(getHeartRateColor(heartRateMonitor.currentHeartRate))
                    + Text(" BPM")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("更新时间: \(formatTime(heartRateMonitor.lastHeartRateTimestamp))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding()
                
                // 监测状态
                HStack {
//                    Circle()
//                        .fill(heartRateMonitor.isMonitoring ? Color.green : Color.gray)
//                        .frame(width: 8, height: 8)
//                    Text(heartRateMonitor.isMonitoring ? "监测中" : "已停止")
//                        .font(.caption)
//                        .foregroundColor(heartRateMonitor.isMonitoring ? .green : .gray)
                }
                
                //Spacer()
                
                // 控制按钮
                Button(action: {
                    if heartRateMonitor.isMonitoring {
                        heartRateMonitor.stopHeartRateMonitoring()
                    } else {
                        heartRateMonitor.startHeartRateMonitoring()
                    }
                }) {
                    HStack {
                        Image(systemName: heartRateMonitor.isMonitoring ? "stop.circle.fill" : "play.circle.fill")
                        Text(heartRateMonitor.isMonitoring ? "停止监测" : "开始监测")
                    }
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(heartRateMonitor.isMonitoring ? Color.red : Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
            } else {
                // 未授权状态
                VStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("正在请求 HealthKit 权限...")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    Text("请在 iPhone 的 Health App 中授权")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .onAppear{
                            print("...Nothing")
//                            var completion: ((Bool) -> Bool)? = nil
//                            // 只请求读取权限，不需要写入权限
//                            let readTypes: Set<HKSampleType> = [heartRateType]
//                            healthStore.requestAuthorization(toShare: [heartRateType], read: readTypes) {  success, error in
//                                DispatchQueue.main.async {
//                                    if success {
//                                        print("HealthKit 授权请求完成")
//                                        
//                                    } else {
//                                        print("HealthKit 授权失败: \(error?.localizedDescription ?? "未知错误")")
//                                        completion?(false)
//                                    }
//                                }
//                            }
                        }
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            heartRateMonitor.authorizeHealthKit()
        }
        .onDisappear {
            heartRateMonitor.stopHeartRateMonitoring()
        }
    }
    
    private func getHeartRateColor(_ heartRate: Double) -> Color {
        switch heartRate {
        case 60...100:
            return .green
        case 40..<60, 100..<120:
            return .orange
        default:
            return .red
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

