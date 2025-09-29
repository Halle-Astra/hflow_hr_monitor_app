//
//  PhoneConnectivityManager.swift
//  hr_monitor
//
//  Created by halle on 2025/9/29.
//

import WatchConnectivity
import Combine

class PhoneConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedHeartRate: Double = 0
    @Published var lastUpdateTime: Date = Date()
    @Published var heartRateTimestamp: Date = Date()
    @Published var isWatchReachable: Bool = false
    @Published var authorizationStatus: String = "未知"
    
    override init() {
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
            print("❌ iOS: 会话激活失败: \(error.localizedDescription)")
        } else {
            print("✅ iOS: 会话激活完成")
            updateReachabilityStatus(session)
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        updateReachabilityStatus(session)
    }
    
    private func updateReachabilityStatus(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("📱 会话变为非活动状态")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("📱 会话已停用，重新激活...")
        WCSession.default.activate()
    }
    
    // 接收来自 Watch 的消息
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let type = message["type"] as? String {
                switch type {
                case MessageType.heartRate:
                    if let heartRate = message["value"] as? Double,
                       let hrTimestamp = message["heartRateTimestamp"] as? TimeInterval {
                        self.receivedHeartRate = heartRate
                        self.lastUpdateTime = Date()
                        self.heartRateTimestamp = Date(timeIntervalSince1970: hrTimestamp)
                        print("📱 收到心率数据: \(heartRate) BPM")
                    }
                    
                case MessageType.authorizationStatus:
                    if let status = message["status"] as? String {
                        self.authorizationStatus = status
                        print("📱 HealthKit 授权状态: \(status)")
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    // 发送消息到 Watch
    func sendMessageToWatch(_ message: [String: Any]) {
        guard WCSession.default.isReachable else {
            print("⚠️ Watch 不可达，无法发送消息")
            return
        }
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("❌ 发送消息到 Watch 失败: \(error)")
        }
    }
}
