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

import HealthKit
import SwiftUI

//struct ContentView: View {
//    @StateObject private var heartRateMonitor = HeartRateMonitorManager()
//    private let healthStore = HKHealthStore()
//    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
//
//    var body: some View {
//        VStack(spacing: 15) {
//            // 标题
//
//            // 授权状态
//            if heartRateMonitor.isAuthorized {
//                // 心率显示
//                VStack {
//
//                    Text("\(Int(heartRateMonitor.currentHeartRate))")
//                        .font(.system(size: 48, weight: .bold, design: .rounded))
//                        .foregroundColor(getHeartRateColor(heartRateMonitor.currentHeartRate))
//                    + Text(" BPM")
//                        .font(.title3)
//                        .foregroundColor(.gray)
//
//                    Text("更新时间: \(formatTime(heartRateMonitor.lastHeartRateTimestamp))")
//                        .font(.caption2)
//                        .foregroundColor(.gray)
//                }
//                .padding()
//
//                // 监测状态
//                HStack {
////                    Circle()
////                        .fill(heartRateMonitor.isMonitoring ? Color.green : Color.gray)
////                        .frame(width: 8, height: 8)
////                    Text(heartRateMonitor.isMonitoring ? "监测中" : "已停止")
////                        .font(.caption)
////                        .foregroundColor(heartRateMonitor.isMonitoring ? .green : .gray)
//                }
//
//                //Spacer()
//
//                // 控制按钮
//                Button(action: {
//                    if heartRateMonitor.isMonitoring {
//                        heartRateMonitor.stopHeartRateMonitoring()
//                    } else {
//                        heartRateMonitor.startHeartRateMonitoring()
//                    }
//                }) {
//                    HStack {
//                        Image(systemName: heartRateMonitor.isMonitoring ? "stop.circle.fill" : "play.circle.fill")
//                        Text(heartRateMonitor.isMonitoring ? "停止监测" : "开始监测")
//                    }
//                    .font(.body)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(heartRateMonitor.isMonitoring ? Color.red : Color.blue)
//                    .cornerRadius(10)
//                }
//                .padding(.horizontal)
//
//            } else {
//                // 未授权状态
//                VStack(spacing: 10) {
//                    ProgressView()
//                        .scaleEffect(1.2)
//                    Text("正在请求 HealthKit 权限...")
//                        .font(.body)
//                        .multilineTextAlignment(.center)
//                    Text("请在 iPhone 的 Health App 中授权")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .onAppear{
//                            print("...Nothing")
////                            var completion: ((Bool) -> Bool)? = nil
////                            // 只请求读取权限，不需要写入权限
////                            let readTypes: Set<HKSampleType> = [heartRateType]
////                            healthStore.requestAuthorization(toShare: [heartRateType], read: readTypes) {  success, error in
////                                DispatchQueue.main.async {
////                                    if success {
////                                        print("HealthKit 授权请求完成")
////
////                                    } else {
////                                        print("HealthKit 授权失败: \(error?.localizedDescription ?? "未知错误")")
////                                        completion?(false)
////                                    }
////                                }
////                            }
//                        }
//                }
//                .padding()
//            }
//
//            Spacer()
//        }
//        .padding()
//        .onAppear {
//            heartRateMonitor.authorizeHealthKit()
//        }
//        .onDisappear {
//            heartRateMonitor.stopHeartRateMonitoring()
//        }
//    }
//
//    private func getHeartRateColor(_ heartRate: Double) -> Color {
//        switch heartRate {
//        case 60...100:
//            return .green
//        case 40..<60, 100..<120:
//            return .orange
//        default:
//            return .red
//        }
//    }
//
//    private func formatTime(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        formatter.dateStyle = .none
//        return formatter.string(from: date)
//    }
//}

//
//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var heartRateMonitor = HeartRateMonitorManager()
//    @StateObject private var musicPlayer = MusicPlayerManager()
//    @StateObject private var cloudService = CloudServiceManager()
//    @State private var currentPage = 0
//
//    var body: some View {
//        TabView(selection: $currentPage) {
//            // 页面1: 心率监测
//            HeartRatePage(heartRateMonitor: heartRateMonitor)
//                .tag(0)
//
//            // 页面2: 音乐控制
//            MusicPage(musicPlayer: musicPlayer)
//                .tag(1)
//
//            // 页面3: 系统状态
//            StatusPage(
//                heartRateMonitor: heartRateMonitor,
//                musicPlayer: musicPlayer,
//                cloudService: cloudService
//            )
//            .tag(2)
//        }
//        .tabViewStyle(PageTabViewStyle())
//        .onChange(of: currentPage) { newValue in
//                    print("页面变化: \(newValue)")
//                }
//    }
//}
//
//// MARK: - 心率页面
//struct HeartRatePage: View {
//    @ObservedObject var heartRateMonitor: HeartRateMonitorManager
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("心率监测")
//                .font(.headline)
//
//            // 心率大显示
//            VStack(spacing: 4) {
//                Text("\(Int(heartRateMonitor.currentHeartRate))")
//                    .font(.system(size: 56, weight: .bold, design: .rounded))
//                    .foregroundColor(getHeartRateColor(heartRateMonitor.currentHeartRate))
//                + Text(" BPM")
//                    .font(.title2)
//                    .foregroundColor(.gray)
//
//                Text("更新: \(formatTime(heartRateMonitor.lastHeartRateTimestamp))")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
////            .padding(.vertical, 10)
//
//            Spacer()
//
//            // 监测控制按钮
//            Button(heartRateMonitor.isMonitoring ? "停止监测" : "开始监测") {
//                if heartRateMonitor.isMonitoring {
//                    heartRateMonitor.stopCompleteMonitoring()
//                } else {
//                    heartRateMonitor.startCompleteMonitoring()
//                }
//            }
////            .padding()
//            .background(heartRateMonitor.isMonitoring ? Color.red : Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(12)
//        }
//        .padding()
//    }
//
//    private func getHeartRateColor(_ heartRate: Double) -> Color {
//        switch heartRate {
//        case 60...100: return .green
//        case 40..<60, 100..<120: return .orange
//        default: return .red
//        }
//    }
//
//    private func formatTime(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        return formatter.string(from: date)
//    }
//}
//
//// MARK: - 音乐页面
//struct MusicPage: View {
//    @ObservedObject var musicPlayer: MusicPlayerManager
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("音乐播放")
//                .font(.headline)
//
//            // 音乐图标和状态
//            VStack(spacing: 12) {
//                Image(systemName: musicPlayer.isPlaying ? "speaker.wave.3" : "speaker.slash")
//                    .font(.system(size: 40))
//                    .foregroundColor(musicPlayer.isPlaying ? .green : .gray)
//
//                Text(musicPlayer.isPlaying ? "播放中" : "已停止")
//                    .font(.title3)
//                    .foregroundColor(musicPlayer.isPlaying ? .green : .gray)
//            }
//            .padding(.vertical, 10)
//
//            // 音乐控制按钮
//            HStack(spacing: 16) {
//                Button("播放") {
//                    musicPlayer.play()
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                .disabled(musicPlayer.isPlaying)
//                .opacity(musicPlayer.isPlaying ? 0.6 : 1.0)
//
//                Button("暂停") {
//                    musicPlayer.pause()
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
//                .background(Color.orange)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                .disabled(!musicPlayer.isPlaying)
//                .opacity(!musicPlayer.isPlaying ? 0.6 : 1.0)
//            }
//
//            Spacer()
//
//            // 下载状态
//            VStack(spacing: 4) {
//                Text("已下载片段")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//
//                Text("\(musicPlayer.downloadedSegments)")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//            }
//        }
//        .padding()
//    }
//}
//
//// MARK: - 状态页面
//struct StatusPage: View {
//    @ObservedObject var heartRateMonitor: HeartRateMonitorManager
//    @ObservedObject var musicPlayer: MusicPlayerManager
//    @ObservedObject var cloudService: CloudServiceManager
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("系统状态")
//                .font(.headline)
//
//            // 状态列表
//            VStack(spacing: 16) {
//                StatusRow(
//                    icon: "heart.fill",
//                    color: .red,
//                    title: "心率监测",
//                    value: heartRateMonitor.isMonitoring ? "运行中" : "已停止",
//                    statusColor: heartRateMonitor.isMonitoring ? .green : .gray
//                )
//
//                StatusRow(
//                    icon: "music.note",
//                    color: .blue,
//                    title: "音乐播放",
//                    value: musicPlayer.isPlaying ? "播放中" : "已停止",
//                    statusColor: musicPlayer.isPlaying ? .green : .gray
//                )
//
//                StatusRow(
//                    icon: "icloud.and.arrow.up",
//                    color: .green,
//                    title: "数据上传",
//                    value: getShortUploadStatus(cloudService.lastUploadStatus),
//                    statusColor: getUploadStatusColor(cloudService.lastUploadStatus)
//                )
//
//                StatusRow(
//                    icon: "icloud.and.arrow.down",
//                    color: .orange,
//                    title: "音乐下载",
//                    value: "\(musicPlayer.downloadedSegments)段",
//                    statusColor: .primary
//                )
//            }
//            .padding(.horizontal, 8)
//
//            Spacer()
//
//            // 重启按钮
//            Button("重启所有服务") {
//                restartAllServices()
//            }
//            .padding()
//            .background(Color.purple)
//            .foregroundColor(.white)
//            .cornerRadius(12)
//        }
//        .padding()
//    }
//
//    private func getShortUploadStatus(_ status: String) -> String {
//        if status.contains("成功") { return "正常" }
//        if status.contains("失败") { return "异常" }
//        if status.contains("上传") { return "上传中" }
//        return "等待中"
//    }
//
//    private func getUploadStatusColor(_ status: String) -> Color {
//        if status.contains("成功") { return .green }
//        if status.contains("失败") { return .red }
//        return .orange
//    }
//
//    private func restartAllServices() {
//        heartRateMonitor.stopCompleteMonitoring()
//        musicPlayer.stop()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            heartRateMonitor.startCompleteMonitoring()
//        }
//    }
//}
//
//// MARK: - 状态行组件
//struct StatusRow: View {
//    let icon: String
//    let color: Color
//    let title: String
//    let value: String
//    let statusColor: Color
//
//    var body: some View {
//        HStack {
//            // 图标
//            Image(systemName: icon)
//                .foregroundColor(color)
//                .frame(width: 30)
//                .font(.body)
//
//            // 标题
//            Text(title)
//                .font(.body)
//                .foregroundColor(.primary)
//
//            Spacer()
//
//            // 状态值
//            Text(value)
//                .font(.body)
//                .foregroundColor(statusColor)
//                .fontWeight(.medium)
//        }
//    }
//}

struct ContentView: View {
    @StateObject private var heartRateMonitor = HeartRateMonitorManager()
    @StateObject private var musicPlayer = MusicPlayerManager()
    @StateObject private var cloudService = CloudServiceManager()
    @State private var currentPage = 0
    private let healthStore = HKHealthStore()
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    var body: some View {
        
        VStack(spacing: 0) {
            // 页面指示器
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(
                            currentPage == index
                                ? Color.blue : Color.gray.opacity(0.5)
                        )
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)

            // TabView - 每个页面都是 ScrollView
            TabView(selection: $currentPage) {
                ScrollViewHeartRatePage(heartRateMonitor: heartRateMonitor)
                    .tag(0)

                ScrollViewMusicPage(musicPlayer: musicPlayer)
                    .tag(1)

                ScrollViewStatusPage(
                    heartRateMonitor: heartRateMonitor,
                    musicPlayer: musicPlayer,
                    cloudService: cloudService
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }.onAppear{
            if !heartRateMonitor.isAuthorized {
                heartRateMonitor.authorizeHealthKit()
            }
        }
    }

    // MARK: - 带滚动的心率页面
    struct ScrollViewHeartRatePage: View {
        @ObservedObject var heartRateMonitor: HeartRateMonitorManager

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("心率监测")
                        .font(.headline)

                    // 心率显示区域
                    VStack(spacing: 8) {
                        Text("\(Int(heartRateMonitor.currentHeartRate))")
                            .font(
                                .system(
                                    size: 56,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(
                                getHeartRateColor(
                                    heartRateMonitor.currentHeartRate
                                )
                            )
                            + Text(" BPM")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Text(
                            "更新时间: \(formatTime(heartRateMonitor.lastHeartRateTimestamp))"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 10)

                    // 控制按钮
                    Button(heartRateMonitor.isMonitoring ? "停止监测" : "开始监测") {
                        if heartRateMonitor.isMonitoring {
                            heartRateMonitor.stopCompleteMonitoring()
                        } else {
                            heartRateMonitor.startCompleteMonitoring()
                        }
                    }
                    .padding()
                    .background(
                        heartRateMonitor.isMonitoring ? Color.red : Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    // 历史数据区域（确保有足够内容可以滚动）
                    VStack(spacing: 12) {
                        Text("监测信息")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        InfoRow(
                            title: "监测状态",
                            value: heartRateMonitor.isMonitoring ? "运行中" : "已停止"
                        )
                        InfoRow(
                            title: "设备授权",
                            value: heartRateMonitor.isAuthorized ? "已授权" : "未授权"
                        )
                        InfoRow(
                            title: "最后同步",
                            value: formatDetailedTime(Date())
                        )
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
        }

        private func getHeartRateColor(_ heartRate: Double) -> Color {
            switch heartRate {
            case 60...100: return .green
            case 40..<60, 100..<120: return .orange
            default: return .red
            }
        }

        private func formatTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter.string(from: date)
        }

        private func formatDetailedTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: date)
        }
    }

    // MARK: - 带滚动的音乐页面
    struct ScrollViewMusicPage: View {
        @ObservedObject var musicPlayer: MusicPlayerManager

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("音乐播放")
                        .font(.headline)

                    // 播放状态
                    VStack(spacing: 12) {
                        Image(
                            systemName: musicPlayer.isPlaying
                                ? "speaker.wave.3" : "speaker.slash"
                        )
                        .font(.system(size: 40))
                        .foregroundColor(musicPlayer.isPlaying ? .green : .gray)

                        Text(musicPlayer.isPlaying ? "播放中" : "已停止")
                            .font(.title3)
                            .foregroundColor(
                                musicPlayer.isPlaying ? .green : .gray
                            )
                    }
                    .padding(.vertical, 10)

                    // 控制按钮
                    HStack(spacing: 16) {
                        Button("播放") {
                            musicPlayer.play()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(musicPlayer.isPlaying)
                        .opacity(musicPlayer.isPlaying ? 0.6 : 1.0)

                        Button("暂停") {
                            musicPlayer.pause()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(!musicPlayer.isPlaying)
                        .opacity(!musicPlayer.isPlaying ? 0.6 : 1.0)
                    }

                    // 下载信息
                    VStack(spacing: 12) {
                        Text("下载状态")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        InfoRow(
                            title: "已下载片段",
                            value: "\(musicPlayer.downloadedSegments)"
                        )
                        InfoRow(
                            title: "等待队列",
                            value: "\(musicPlayer.queueLength)"
                        )
                        InfoRow(title: "播放状态", value: musicPlayer.currentStatus)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // 操作记录
                    VStack(spacing: 8) {
                        Text("最近操作")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("最后检查: \(formatTime(Date()))")
                            .font(.caption2)
                            .foregroundColor(.gray)

                        Text("网络状态: 正常")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
        }

        private func formatTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter.string(from: date)
        }
    }

    // MARK: - 带滚动的状态页面
    struct ScrollViewStatusPage: View {
        @ObservedObject var heartRateMonitor: HeartRateMonitorManager
        @ObservedObject var musicPlayer: MusicPlayerManager
        @ObservedObject var cloudService: CloudServiceManager

        // 授权状态

        var body: some View {

            ScrollView {
                VStack(spacing: 20) {
                    Text("系统状态")
                        .font(.headline)

                    // 核心状态
                    VStack(spacing: 16) {
                        StatusRow(
                            icon: "heart.fill",
                            color: .red,
                            title: "心率监测",
                            value: heartRateMonitor.isMonitoring
                                ? "运行中" : "已停止",
                            statusColor: heartRateMonitor.isMonitoring
                                ? .green : .gray
                        )

                        StatusRow(
                            icon: "music.note",
                            color: .blue,
                            title: "音乐播放",
                            value: musicPlayer.isPlaying ? "播放中" : "已停止",
                            statusColor: musicPlayer.isPlaying ? .green : .gray
                        )

                        StatusRow(
                            icon: "icloud.and.arrow.up",
                            color: .green,
                            title: "数据上传",
                            value: getShortUploadStatus(
                                cloudService.lastUploadStatus
                            ),
                            statusColor: getUploadStatusColor(
                                cloudService.lastUploadStatus
                            )
                        )

                        StatusRow(
                            icon: "icloud.and.arrow.down",
                            color: .orange,
                            title: "音乐下载",
                            value: "\(musicPlayer.downloadedSegments)段",
                            statusColor: .primary
                        )
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // 详细状态
                    VStack(spacing: 12) {
                        Text("详细状态")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        InfoRow(
                            title: "上传状态",
                            value: cloudService.lastUploadStatus
                        )
                        InfoRow(
                            title: "下载状态",
                            value: cloudService.lastDownloadStatus
                        )
                        InfoRow(title: "网络状态", value: "正常")
                        InfoRow(title: "运行时间", value: "\(getUptime())")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // 控制按钮
                    Button("重启所有服务") {
                        restartAllServices()
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
        }

        private func getShortUploadStatus(_ status: String) -> String {
            if status.contains("成功") { return "正常" }
            if status.contains("失败") { return "异常" }
            if status.contains("上传") { return "上传中" }
            return "等待中"
        }

        private func getUploadStatusColor(_ status: String) -> Color {
            if status.contains("成功") { return .green }
            if status.contains("失败") { return .red }
            return .orange
        }

        private func getUptime() -> String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            return formatter.string(from: ProcessInfo.processInfo.systemUptime)
                ?? "未知"
        }

        private func restartAllServices() {
            heartRateMonitor.stopCompleteMonitoring()
            musicPlayer.stop()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                heartRateMonitor.startCompleteMonitoring()
            }
        }
    }

    // MARK: - 通用组件
    struct InfoRow: View {
        let title: String
        let value: String

        var body: some View {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                Spacer()
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    struct StatusRow: View {
        let icon: String
        let color: Color
        let title: String
        let value: String
        let statusColor: Color

        var body: some View {

            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30)
                    .font(.body)

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Text(value)
                    .font(.body)
                    .foregroundColor(statusColor)
                    .fontWeight(.medium)
            }
        }
    }
}
