
import SwiftUI

struct TimerControlsView: View {

    // MARK: - Properties

    let remaining: Int
    let isRunning: Bool
    let isCompleted: Bool
    let isDraining: Bool

    let blue: Color

    let onPlayPause: () -> Void
    let onDrain: () -> Void
    let onEditTime: () -> Void

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {

            countdown
                .padding(.top, 24)

            playbackControl
                .padding(.top, 28)

            Spacer(minLength: 24)

            timePickerHandle
                .padding(.bottom, 8)
        }
    }

    // MARK: - Countdown

    private var countdown: some View {
        Button(action: onEditTime) {
            Text(formattedTime(remaining))
                .font(.system(
                    size: 56,
                    weight: .medium,
                    design: .rounded
                ))
                .monospacedDigit()
                .foregroundStyle(.black)
                .contentTransition(.numericText())
        }
        .disabled(isRunning || isDraining)
        .accessibilityLabel("Edit timer duration")
    }

    // MARK: - Playback / Drain

    private var playbackControl: some View {
        Group {
            if isCompleted {
                drainButton
            } else {
                playPauseButton
            }
        }
    }

    private var playPauseButton: some View {
        Button(action: onPlayPause) {
            Image(
                systemName: isRunning
                    ? "pause.fill"
                    : "play.fill"
            )
            .font(.system(
                size: 28,
                weight: .bold
            ))
            .foregroundStyle(blue)
            .frame(width: 76, height: 76)
            .background(Color.white)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(.black, lineWidth: 2)
            }
        }
        .disabled(isDraining)
        .accessibilityLabel(
            isRunning ? "Pause" : "Play"
        )
    }

    private var drainButton: some View {
        Button(action: onDrain) {
            Label(
                isDraining ? "Draining..." : "Drain",
                systemImage: "drop"
            )
            .font(.system(
                size: 19,
                weight: .semibold
            ))
            .foregroundStyle(.white)
            .frame(width: 160, height: 76)
            .background(blue)
            .clipShape(Capsule())
        }
        .disabled(isDraining)
        .accessibilityLabel("Drain water")
    }

    // MARK: - Time Picker Handle

    private var timePickerHandle: some View {
        Button(action: onEditTime) {
            Image(systemName: "arrow.up")
                .font(.system(
                    size: 25,
                    weight: .light
                ))
                .foregroundStyle(.black.opacity(0.6))
                .frame(width: 76, height: 54)
                .contentShape(Rectangle())
        }
        .disabled(isRunning || isDraining)
        .accessibilityLabel("Set timer duration")
    }

    // MARK: - Formatting

    private func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        if hours > 0 {
            return String(
                format: "%02d:%02d:%02d",
                hours,
                minutes,
                remainingSeconds
            )
        }

        return String(
            format: "%02d:%02d",
            minutes,
            remainingSeconds
        )
    }
}

#Preview {
    TimerControlsView(
        remaining: 25 * 60,
        isRunning: false,
        isCompleted: false,
        isDraining: false,
        blue: .blue,
        onPlayPause: {},
        onDrain: {},
        onEditTime: {}
    )
    .padding()
}
