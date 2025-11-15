//
//  CloudServiceManager.swift
//  hr_monitor
//
//  Created by halle on 2025/10/12.
//

import Foundation
import Combine

class CloudServiceManager: ObservableObject {
    private let session: URLSession
    private var heartRateBuffer: [HeartRateData] = []
    private let bufferLock = NSLock()
    private var uploadTimer: Timer?
    private var musicDownloadTimer: Timer?
    
    @Published var lastUploadStatus: String = "未开始"
    @Published var lastDownloadStatus: String = "未开始"
    @Published var networkStatus: String = "未知"
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - 心率数据上传
    
    func uploadHeartRateData(_ heartRateData: HeartRateData) {
        bufferLock.lock()
        heartRateBuffer.append(heartRateData)
        bufferLock.unlock()
        
        // 如果缓冲区数据较多，立即上传
        if heartRateBuffer.count >= 3 {
            uploadBufferedData()
        }
    }
    
    private func uploadBufferedData() {
        bufferLock.lock()
        guard !heartRateBuffer.isEmpty else {
            bufferLock.unlock()
            return
        }
        
        let dataToUpload = heartRateBuffer
        heartRateBuffer.removeAll()
        bufferLock.unlock()
        
        guard let url = URL(string: "\(CloudConfig.baseURL)\(CloudConfig.heartRateEndpoint)") else {
            updateUploadStatus("URL错误")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(dataToUpload)
            request.httpBody = jsonData
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.updateUploadStatus("上传失败: \(error.localizedDescription)")
                        // 重新缓冲失败的数据
                        self?.bufferLock.lock()
                        self?.heartRateBuffer.append(contentsOf: dataToUpload)
                        self?.bufferLock.unlock()
                    } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        self?.updateUploadStatus("上传成功: \(dataToUpload.count)条数据")
                    } else {
                        self?.updateUploadStatus("服务器错误")
                        self?.bufferLock.lock()
                        self?.heartRateBuffer.append(contentsOf: dataToUpload)
                        self?.bufferLock.unlock()
                    }
                }
            }
            task.resume()
            
        } catch {
            updateUploadStatus("编码错误: \(error.localizedDescription)")
            bufferLock.lock()
            heartRateBuffer.append(contentsOf: dataToUpload)
            bufferLock.unlock()
        }
    }
    
    private func updateUploadStatus(_ status: String) {
        DispatchQueue.main.async {
            self.lastUploadStatus = "\(Date().formatted(date: .omitted, time: .standard)): \(status)"
            print("📤 \(status)")
        }
    }
    
    // MARK: - 音乐下载
    
    func downloadMusicSegments(completion: @escaping ([MusicSegment]?) -> Void) {
        guard let url = URL(string: "\(CloudConfig.baseURL)\(CloudConfig.musicEndpoint)") else {
            updateDownloadStatus("音乐URL错误")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.updateDownloadStatus("下载失败: \(error.localizedDescription)")
                    completion(nil)
                } else if let data = data {
                    do {
                        let segments = try JSONDecoder().decode([MusicSegment].self, from: data)
                        self?.updateDownloadStatus("1, 下载成功: \(segments.count)个片段")
                        completion(segments)
                    } catch {
                        self?.updateDownloadStatus("解析失败: \(error.localizedDescription)")
                        completion(nil)
                        print(data)
                    }
                } else {
                    self?.updateDownloadStatus("无数据")
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    private func updateDownloadStatus(_ status: String) {
        DispatchQueue.main.async {
            self.lastDownloadStatus = "\(Date().formatted(date: .omitted, time: .standard)): \(status)"
            print("3, 🎵 \(status)")
        }
    }
    
    // MARK: - 定时任务管理
    
    func startPeriodicTasks() {
        // 停止之前的定时器
        stopPeriodicTasks()
        
        // 心率上传定时器（5秒一次）
        uploadTimer = Timer.scheduledTimer(withTimeInterval: CloudConfig.uploadInterval, repeats: true) { [weak self] _ in
            self?.uploadBufferedData()
        }
        
        // 音乐下载定时器（10秒一次）
        musicDownloadTimer = Timer.scheduledTimer(withTimeInterval: CloudConfig.musicDownloadInterval, repeats: true) { [weak self] _ in
            self?.checkForNewMusic()
        }
        
        // 立即执行一次
        uploadBufferedData()
        checkForNewMusic()
    }
    
    func stopPeriodicTasks() {
        uploadTimer?.invalidate()
        uploadTimer = nil
        musicDownloadTimer?.invalidate()
        musicDownloadTimer = nil
        
        // 上传剩余数据
        uploadBufferedData()
    }
    
    private func checkForNewMusic() {
        downloadMusicSegments { segments in
            if let segments = segments {
                // 通知音乐播放器处理新片段
                NotificationCenter.default.post(
                    name: .newMusicSegmentsAvailable,
                    object: segments
                )
            }
        }
    }
}

// 通知扩展
extension Notification.Name {
    static let newMusicSegmentsAvailable = Notification.Name("newMusicSegmentsAvailable")
}
