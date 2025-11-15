//
//  MusicPlayerManager.swift
//  hr_monitor
//
//  Created by halle on 2025/10/12.
//

import Foundation
import AVFoundation
import Combine

class MusicPlayerManager: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var currentSegment: MusicSegment?
    private var segmentQueue: [MusicSegment] = []
    private let queueLock = NSLock()
    private var downloadTasks: [URLSessionDownloadTask] = []
    
    @Published var isPlaying: Bool = false
    @Published var currentStatus: String = "就绪"
    @Published var downloadedSegments: Int = 0
    @Published var queueLength: Int = 0
    
    override init() {
        super.init()
        setupAudioSession()
        setupNotifications()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ 音频会话设置失败: \(error)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .newMusicSegmentsAvailable,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let segments = notification.object as? [MusicSegment] {
                self?.processNewSegments(segments)
            }
        }
    }
    
    // MARK: - 音乐片段处理
    
    private func processNewSegments(_ segments: [MusicSegment]) {
        queueLock.lock()
        
        // 过滤掉已经下载或正在下载的片段
        let newSegments = segments.filter { newSegment in
            !segmentQueue.contains { $0.segmentId == newSegment.segmentId } &&
            currentSegment?.segmentId != newSegment.segmentId
        }
        
        segmentQueue.append(contentsOf: newSegments)
        queueLength = segmentQueue.count
        queueLock.unlock()
        
        updateStatus("收到 \(newSegments.count) 个新片段")
        
        // 开始下载和处理
        downloadNextSegment()
    }
    
    private func downloadNextSegment() {
        queueLock.lock()
        guard !segmentQueue.isEmpty else {
            queueLock.unlock()
            return
        }
        
        let segment = segmentQueue.removeFirst()
        queueLength = segmentQueue.count
        queueLock.unlock()
        
        downloadMusicSegment(segment) { [weak self] localURL in
            guard let self = self, let localURL = localURL else {
                self?.downloadNextSegment() // 继续下一个
                return
            }
            
            self.downloadedSegments += 1
            self.prepareToPlay(segment: segment, fileURL: localURL)
        }
    }
    
    private func downloadMusicSegment(_ segment: MusicSegment, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: segment.audioUrl) else {
            updateStatus("无效的音频URL: \(segment.audioUrl)")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { [weak self] localURL, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.updateStatus("2, 下载失败: \(error.localizedDescription)")
                    completion(nil)
                } else if let localURL = localURL {
                    // 移动到永久存储位置
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let destinationURL = documentsURL.appendingPathComponent("\(segment.segmentId).mp3")
                    
                    do {
                        if fileManager.fileExists(atPath: destinationURL.path) {
                            try fileManager.removeItem(at: destinationURL)
                        }
                        try fileManager.moveItem(at: localURL, to: destinationURL)
                        completion(destinationURL)
                    } catch {
                        self?.updateStatus("文件移动失败: \(error)")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
        task.resume()
        downloadTasks.append(task)
    }
    
    // MARK: - 播放控制
    
    private func prepareToPlay(segment: MusicSegment, fileURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            currentSegment = segment
            
            updateStatus("准备播放: \(segment.segmentId)")
            
            // 如果没有在播放，开始播放
            if !isPlaying {
                play()
            }
            
        } catch {
            updateStatus("播放器初始化失败: \(error.localizedDescription)")
            downloadNextSegment() // 继续下一个
        }
    }
    
    func play() {
        guard let player = audioPlayer, !player.isPlaying else { return }
        print(player)
        if player.play() {
            isPlaying = true
            updateStatus("播放中: \(currentSegment?.segmentId ?? "未知")")
        } else {
            updateStatus("播放失败")
            downloadNextSegment()
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        updateStatus("已暂停")
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        currentSegment = nil
        updateStatus("已停止")
    }
    
    private func updateStatus(_ status: String) {
        DispatchQueue.main.async {
            self.currentStatus = "\(Date().formatted(date: .omitted, time: .standard)): \(status)"
            print("🎵 \(status)")
        }
    }
    
    // MARK: - 清理
    
    deinit {
        stop()
        downloadTasks.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
    }
}

// AVAudioPlayerDelegate
extension MusicPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.updateStatus(flag ? "播放完成" : "播放中断")
            
            // 播放完成后下载下一个片段
            self.downloadNextSegment()
            
            // 如果有下一个片段，自动播放
            if !self.segmentQueue.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.downloadNextSegment()
                }
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.updateStatus("解码错误: \(error?.localizedDescription ?? "未知")")
            self.downloadNextSegment()
        }
    }
}
