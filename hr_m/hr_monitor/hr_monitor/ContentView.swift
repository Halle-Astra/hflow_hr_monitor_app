//
//  ContentView.swift
//  hr_monitor
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

struct ContentView: View {
    @StateObject private var connectivityManager = PhoneConnectivityManager()
    @State private var isMonitoring = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题和状态
                VStack {
                    Text("心率监测")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        StatusIndicator(isConnected: connectivityManager.isWatchReachable)
                        Text(connectivityManager.isWatchReachable ? "手表已连接" : "手表未连接")
                            .foregroundColor(connectivityManager.isWatchReachable ? .green : .red)
                    }
                    
                    Text("授权状态: \(connectivityManager.authorizationStatus)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                
                // 心率显示
                VStack {
                    Text("当前心率")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("\(Int(connectivityManager.receivedHeartRate))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(getHeartRateColor(connectivityManager.receivedHeartRate))
                    + Text(" BPM")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("更新时间: \(formatTime(connectivityManager.lastUpdateTime))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("心率测量时间: \(formatTime(connectivityManager.heartRateTimestamp))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                
                // 控制按钮
                VStack(spacing: 15) {
                    Button(action: {
                        toggleMonitoring()
                    }) {
                        HStack {
                            Image(systemName: isMonitoring ? "stop.circle.fill" : "play.circle.fill")
                            Text(isMonitoring ? "停止监测" : "开始监测")
                        }
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isMonitoring ? Color.red : Color.blue)
                        .cornerRadius(12)
                    }
                    
                    if connectivityManager.isWatchReachable {
                        Button("发送测试消息") {
                            sendTestMessage()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 历史记录（简单显示）
                VStack(alignment: .leading) {
                    Text("最近更新")
                        .font(.headline)
                    Text("心率: \(Int(connectivityManager.receivedHeartRate)) BPM")
                    Text("时间: \(formatDetailedTime(connectivityManager.lastUpdateTime))")
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func toggleMonitoring() {
        isMonitoring.toggle()
        let message: [String: Any] = [
            "type": "monitoringControl",
            "action": isMonitoring ? "start" : "stop"
        ]
        connectivityManager.sendMessageToWatch(message)
    }
    
    private func sendTestMessage() {
        let message: [String: Any] = [
            "type": "test",
            "message": "Hello from iPhone!",
            "timestamp": Date().timeIntervalSince1970
        ]
        connectivityManager.sendMessageToWatch(message)
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
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatDetailedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct StatusIndicator: View {
    let isConnected: Bool
    
    var body: some View {
        Circle()
            .fill(isConnected ? Color.green : Color.red)
            .frame(width: 12, height: 12)
    }
}
