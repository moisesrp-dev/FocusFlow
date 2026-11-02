
import AVFoundation

@MainActor
final class CompletionSoundPlayer {

    private var player: AVAudioPlayer?

    func play() {
        guard let url = Bundle.main.url(
            forResource: "focus-complete",
            withExtension: "wav"
        ) else {
            print("Missing focus-complete.wav")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()

            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )

            try session.setActive(true)

            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)

            // Repeat indefinitely until Drain is tapped.
            player?.numberOfLoops = -1

            player?.prepareToPlay()
            player?.play()

        } catch {
            print("Sound playback failed: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: [.notifyOthersOnDeactivation]
        )
    }
}
