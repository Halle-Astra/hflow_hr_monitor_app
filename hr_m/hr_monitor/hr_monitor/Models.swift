//
//  Models.swift
//  hr_monitor
//
//  Created by halle on 2025/9/29.
//

import Foundation

public struct HeartRateData: Codable {
    public let value: Double
    public let timestamp: Date
    public let heartRateTimestamp: Date
    
    public let deviceId: String
    public let sessionId: String
    
    public init(value: Double, timestamp: Date = Date(), heartRateTimestamp: Date = Date(),deviceId: String, sessionId: String) {
        self.value = value
        self.timestamp = timestamp
        self.heartRateTimestamp = heartRateTimestamp
        
        self.deviceId = deviceId
        self.sessionId = sessionId
    }
}

public struct MessageType {
    public static let heartRate = "heartRate"
    public static let authorizationStatus = "authorizationStatus"
}





public struct MusicSegment: Codable {
    public let segmentId: String
    public let audioUrl: String
    public let duration: TimeInterval
    public let order: Int
    public let fileSize: Int
}

public struct CloudConfig {
    public static let baseURL = "http://ai-universe.cn:7515"
    public static let heartRateEndpoint = "/api/heart-rate"
    public static let musicEndpoint = "/api/music-segments"
    public static let uploadInterval: TimeInterval = 5.0 // 5秒上传一次
    public static let musicDownloadInterval: TimeInterval = 10.0 // 10秒检查新音乐
}

public enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case rateLimitExceeded
}




