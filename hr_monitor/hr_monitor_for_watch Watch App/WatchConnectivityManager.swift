//
//  WatchConnectivityManager.swift
//  hr_monitor
//
//  Created by halle on 2025/9/29.
//

import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    private var heartRateMonitor: HeartRateMonitorManager
    
    init(heartRateMonitor: HeartRateMonitorManager) {
        self.heartRateMonitor = heartRateMonitor
        super.init()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            print("⚠️ WatchConnectivity 在此设备上不可用")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ watchOS: 会话激活失败: \(error.localizedDescription)")
        } else {
            print("✅ watchOS: 会话激活完成")
        }
    }
    
    // 接收来自 iPhone 的消息
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let type = message["type"] as? String {
                switch type {
                case "monitoringControl":
                    if let action = message["action"] as? String {
                        if action == "start" {
                            self.heartRateMonitor.startHeartRateMonitoring()
                        } else if action == "stop" {
                            self.heartRateMonitor.stopHeartRateMonitoring()
                        }
                    }
                    
                case "test":
                    if let testMessage = message["message"] as? String {
                        print("📱 收到测试消息: \(testMessage)")
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - 发送数据到 iPhone
    
    func sendHeartRateToPhone(_ heartRate: Double, timestamp: Date) {
        let message: [String: Any] = [
            "type": MessageType.heartRate,
            "value": heartRate,
            "heartRateTimestamp": timestamp.timeIntervalSince1970,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        sendMessageToPhone(message)
    }
    
    func sendAuthorizationStatus(_ status: String) {
        let message: [String: Any] = [
            "type": MessageType.authorizationStatus,
            "status": status,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        sendMessageToPhone(message)
    }
    
    private func sendMessageToPhone(_ message: [String: Any]) {
        guard WCSession.default.isReachable else {
            print("⚠️ iPhone 不可达，无法发送消息")
            return
        }
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("❌ 发送消息到 iPhone 失败: \(error)")
        }
    }
}
