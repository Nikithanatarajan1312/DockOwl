import AppKit
import Foundation

enum SoundEffect {
    case takeoff
    case landTree
    case landCloud
    case workComplete
    case breakComplete
}

enum SoundEffects {
    private static let enabledKey = "DockOwl.soundsEnabled"

    static var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: enabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: enabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enabledKey)
        }
    }

    static func play(_ effect: SoundEffect) {
        guard isEnabled else { return }
        NSSound(data: wavData(for: effect))?.play()
    }

    private struct Tone {
        let frequency: Double
        let duration: Double
        let volume: Double
    }

    private static func wavData(for effect: SoundEffect) -> Data {
        let tones: [Tone] = switch effect {
        case .takeoff:
            [
                Tone(frequency: 520, duration: 0.05, volume: 0.22),
                Tone(frequency: 740, duration: 0.06, volume: 0.26),
                Tone(frequency: 980, duration: 0.08, volume: 0.24),
            ]
        case .landTree:
            [
                Tone(frequency: 220, duration: 0.05, volume: 0.28),
                Tone(frequency: 330, duration: 0.07, volume: 0.2),
            ]
        case .landCloud:
            [
                Tone(frequency: 440, duration: 0.04, volume: 0.16),
                Tone(frequency: 360, duration: 0.08, volume: 0.18),
            ]
        case .workComplete:
            [
                Tone(frequency: 523, duration: 0.1, volume: 0.24),
                Tone(frequency: 659, duration: 0.1, volume: 0.24),
                Tone(frequency: 784, duration: 0.14, volume: 0.26),
            ]
        case .breakComplete:
            [
                Tone(frequency: 784, duration: 0.08, volume: 0.2),
                Tone(frequency: 659, duration: 0.08, volume: 0.18),
                Tone(frequency: 523, duration: 0.12, volume: 0.16),
            ]
        }
        return makeWAV(tones: tones)
    }

    private static func makeWAV(tones: [Tone], sampleRate: Int = 22050) -> Data {
        var pcm = Data()
        pcm.reserveCapacity(tones.reduce(0) { $0 + Int(Double(sampleRate) * $1.duration) } * 2)

        for tone in tones {
            let sampleCount = Int(Double(sampleRate) * tone.duration)
            for index in 0..<sampleCount {
                let time = Double(index) / Double(sampleRate)
                let envelope = min(1.0, min(time * 50, (tone.duration - time) * 50))
                let phase = time * tone.frequency * 2 * .pi
                let square = sin(phase) >= 0 ? 1.0 : -1.0
                let sample = Int16(max(-32767, min(32767, square * envelope * tone.volume * 32767)))
                var littleEndian = sample.littleEndian
                pcm.append(Data(bytes: &littleEndian, count: MemoryLayout<Int16>.size))
            }
        }

        var data = Data()
        let byteRate = sampleRate * 2
        let blockAlign: UInt16 = 2
        let bitsPerSample: UInt16 = 16
        let dataSize = UInt32(pcm.count)
        let chunkSize = 36 + dataSize

        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // RIFF
        data.append(contentsOf: withUnsafeBytes(of: chunkSize.littleEndian) { Array($0) })
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // WAVE
        data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // fmt
        data.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) }) // PCM
        data.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) }) // mono
        data.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: UInt32(byteRate).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // data
        data.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Array($0) })
        data.append(pcm)
        return data
    }
}
