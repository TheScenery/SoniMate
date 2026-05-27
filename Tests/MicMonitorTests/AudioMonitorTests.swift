import Testing
import AVFoundation
@testable import MicMonitor

struct AudioMonitorTests {

    @Test func normalizeSilence() {
        let normalized = AudioMonitor.normalizeVolume(0)
        #expect(normalized == 0)
    }

    @Test func normalizeLoudSignal() {
        let normalized = AudioMonitor.normalizeVolume(1.0)
        #expect(abs(normalized - 1.0) < 0.01)
    }

    @Test func normalizeMidSignal() {
        // rms = 0.1 -> 20*log10(0.1) = -20dB -> (-20 - (-60)) / 60 = 40/60 ≈ 0.667
        let normalized = AudioMonitor.normalizeVolume(0.1)
        #expect(abs(normalized - 0.667) < 0.01)
    }

    @Test func computeRMSZeroBuffer() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 512)!
        buffer.frameLength = 512
        let data = buffer.floatChannelData![0]
        data.initialize(repeating: 0, count: 512)

        let rms = AudioMonitor.computeRMS(from: buffer)
        #expect(rms == 0)
    }

    @Test func computeRMSConstantBuffer() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 512)!
        buffer.frameLength = 512
        let data = buffer.floatChannelData![0]
        data.initialize(repeating: 0.5, count: 512)

        let rms = AudioMonitor.computeRMS(from: buffer)
        #expect(abs(rms - 0.5) < 0.001)
    }
}
