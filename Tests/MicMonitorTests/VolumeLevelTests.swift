import Testing
@testable import MicMonitor

struct VolumeLevelTests {

    @Test func quietThreshold() {
        #expect(VolumeLevel.from(normalizedValue: 0.0) == .quiet)
        #expect(VolumeLevel.from(normalizedValue: 0.1) == .quiet)
        #expect(VolumeLevel.from(normalizedValue: 0.29) == .quiet)
    }

    @Test func moderateThreshold() {
        #expect(VolumeLevel.from(normalizedValue: 0.3) == .moderate)
        #expect(VolumeLevel.from(normalizedValue: 0.5) == .moderate)
        #expect(VolumeLevel.from(normalizedValue: 0.69) == .moderate)
    }

    @Test func loudThreshold() {
        #expect(VolumeLevel.from(normalizedValue: 0.7) == .loud)
        #expect(VolumeLevel.from(normalizedValue: 0.9) == .loud)
        #expect(VolumeLevel.from(normalizedValue: 1.0) == .loud)
    }

    @Test func boundaryValues() {
        #expect(VolumeLevel.from(normalizedValue: 0.3) == .moderate)
        #expect(VolumeLevel.from(normalizedValue: 0.7) == .loud)
    }

    @Test func allCasesOrder() {
        let cases = VolumeLevel.allCases
        #expect(cases == [.quiet, .moderate, .loud])
    }
}
