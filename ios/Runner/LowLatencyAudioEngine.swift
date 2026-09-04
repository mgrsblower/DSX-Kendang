import AVFoundation
import Foundation

final class LowLatencyAudioEngine {
  private let audioEngine = AVAudioEngine()
  private let audioQueue = DispatchQueue(label: "com.mgr.dsx_drum_kendang.audio")
  private let voiceCount = 16
  private var playerNodes: [AVAudioPlayerNode] = []
  private var buffers: [String: AVAudioPCMBuffer] = [:]
  private var nextVoice = 0
  private var isConfigured = false

  func preload(paths: [String], result: @escaping (Bool) -> Void) {
    audioQueue.async {
      let success = self.prepareAudioEngine()
        && paths.allSatisfy { self.loadBuffer(for: $0) }
      result(success)
    }
  }

  func play(path: String, volume: Float, result: @escaping (Bool) -> Void) {
    audioQueue.async {
      guard self.prepareAudioEngine(), let buffer = self.buffers[path] else {
        result(false)
        return
      }

      let node = self.playerNodes[self.nextVoice]
      self.nextVoice = (self.nextVoice + 1) % self.playerNodes.count
      node.stop()
      node.volume = volume
      node.scheduleBuffer(buffer, at: nil, options: [])
      node.play()
      result(true)
    }
  }

  func release(result: @escaping () -> Void) {
    audioQueue.async {
      self.playerNodes.forEach { $0.stop() }
      self.audioEngine.stop()
      self.buffers.removeAll()
      self.playerNodes.removeAll()
      self.nextVoice = 0
      self.isConfigured = false
      try? AVAudioSession.sharedInstance().setActive(false)
      result()
    }
  }

  private func prepareAudioEngine() -> Bool {
    if isConfigured { return true }

    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try session.setPreferredIOBufferDuration(0.005333)
      try session.setActive(true)

      for _ in 0..<voiceCount {
        let node = AVAudioPlayerNode()
        audioEngine.attach(node)
        audioEngine.connect(node, to: audioEngine.mainMixerNode, format: nil)
        playerNodes.append(node)
      }
      audioEngine.prepare()
      try audioEngine.start()
      isConfigured = true
      return true
    } catch {
      playerNodes.forEach { audioEngine.detach($0) }
      playerNodes.removeAll()
      try? AVAudioSession.sharedInstance().setActive(false)
      return false
    }
  }

  private func loadBuffer(for path: String) -> Bool {
    if buffers[path] != nil { return true }
    guard let url = resolveURL(for: path) else { return false }

    do {
      let file = try AVAudioFile(forReading: url)
      guard let buffer = AVAudioPCMBuffer(
        pcmFormat: file.processingFormat,
        frameCapacity: AVAudioFrameCount(file.length)
      ) else { return false }
      try file.read(into: buffer)
      buffers[path] = buffer
      return true
    } catch {
      return false
    }
  }

  private func resolveURL(for path: String) -> URL? {
    let directURL = URL(fileURLWithPath: path)
    if FileManager.default.fileExists(atPath: directURL.path) { return directURL }

    let flutterAssetURL = Bundle.main.bundleURL
      .appendingPathComponent("flutter_assets", isDirectory: true)
      .appendingPathComponent(path)
    if FileManager.default.fileExists(atPath: flutterAssetURL.path) {
      return flutterAssetURL
    }

    return Bundle.main.url(forResource: path, withExtension: nil)
  }
}
