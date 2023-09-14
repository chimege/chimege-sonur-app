import libsonic
import Foundation

class Sonic {
    var stream: sonicStream;
    
    init(sampleRate: Int32, rate: Float, pitch: Float, volume: Float) {
        self.stream = sonicCreateStream(sampleRate, 1);
        sonicSetQuality(self.stream, 1)
        sonicSetSpeed(self.stream, rate)
        sonicSetPitch(self.stream, pitch)
        sonicSetVolume(self.stream, volume)
    }
    
    func readProcessedSamples() -> [Float32] {
        var processedSamples = [Float32]()
        processedSamples.reserveCapacity(22050)
        while sonicSamplesAvailable(stream) > 0 {
            let bufferSize = 22050 / 2
            var buffer = [Float32](repeating: 0, count: bufferSize)
            let readCount = Int(sonicReadFloatFromStream(stream, &buffer, Int32(bufferSize)))
            if readCount > 0 {
                processedSamples.append(contentsOf: buffer[0...(readCount-1)])
            }
        }
        
        return processedSamples
    }
    
    func process(samples: [Float32]) {
        sonicWriteFloatToStream(stream, samples, Int32(samples.count));
    }
    
    func flush() {
        sonicFlushStream(stream)
    }
    
    deinit {
        sonicDestroyStream(self.stream);
    }
}
