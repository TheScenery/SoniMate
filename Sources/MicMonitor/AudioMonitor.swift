import AVFoundation
import AppKit

class AudioMonitor {

    var onVolumeChange: ((VolumeLevel, Float) -> Void)?

    private let engine = AVAudioEngine()
    private var isRunning = false

    var isAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }

    func start() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .notDetermined:
            requestPermission { [weak self] granted in
                if granted { self?.startCapture() }
            }
        case .authorized:
            startCapture()
        case .denied, .restricted:
            onVolumeChange?(.quiet, 0)
        @unknown default:
            onVolumeChange?(.quiet, 0)
        }
    }

    func stop() {
        guard isRunning else { return }
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        isRunning = false
    }

    private func requestPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    private func startCapture() {
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }

        do {
            try engine.start()
            isRunning = true
        } catch {
            onVolumeChange?(.quiet, 0)
        }
    }

    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return }

        let rms = Self.computeRMS(from: buffer)
        let normalized = Self.normalizeVolume(rms)

        let level = VolumeLevel.from(normalizedValue: normalized)
        onVolumeChange?(level, normalized)
    }

    static func normalizeVolume(_ rms: Float) -> Float {
        let minDb: Float = -60
        let maxDb: Float = 0

        let db = rms > 0 ? 20 * log10(rms) : minDb
        let clamped = max(minDb, min(maxDb, db))
        return (clamped - minDb) / (maxDb - minDb)
    }

    static func computeRMS(from buffer: AVAudioPCMBuffer) -> Float {
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return 0 }
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        var sum: Float = 0
        for i in 0..<frameLength {
            let sample = channelData[i]
            sum += sample * sample
        }
        return sqrt(sum / Float(frameLength))
    }
}
