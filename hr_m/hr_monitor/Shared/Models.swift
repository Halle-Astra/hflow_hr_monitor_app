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
    
    public init(value: Double, timestamp: Date = Date(), heartRateTimestamp: Date = Date()) {
        self.value = value
        self.timestamp = timestamp
        self.heartRateTimestamp = heartRateTimestamp
    }
}

public struct MessageType {
    public static let heartRate = "heartRate"
    public static let authorizationStatus = "authorizationStatus"
}
