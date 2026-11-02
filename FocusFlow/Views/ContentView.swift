
import SwiftUI

struct ContentView: View {

    // MARK: - State

    @State private var timer = FocusTimerModel()
    @State private var showTimePicker = false
    @State private var completionSound = CompletionSoundPlayer()

    private let blue = Color(
        red: 0.03,
        green: 0.60,
        blue: 1.0
    )

    // MARK: - Main View

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0,
                paused: !timer.isRunning && !timer.isDraining
            )
        ) { timeline in

            let now = timeline.date
            let progress = timer.visualProgress(at: now)
            let remaining = timer.remainingSeconds(at: now)

            GeometryReader { geometry in

                let capsuleHeight = min(
                    geometry.size.height * 0.51,
                    410
                )

                VStack(spacing: 0) {

                    TimerHeaderView()

                    Spacer(minLength: 18)

                    WaterCapsule(
                        progress: progress,
                        phase: now.timeIntervalSinceReferenceDate
                    )
                    .frame(
                        width: capsuleHeight * 0.46,
                        height: capsuleHeight
                    )

                    TimerControlsView(
                        remaining: remaining,
                        isRunning: timer.isRunning,
                        isCompleted: timer.completed,
                        isDraining: timer.isDraining,
                        blue: blue,
                        onPlayPause: toggleTimer,
                        onDrain: drainTimer,
                        onEditTime: openTimePicker
                    )
                }
                .padding(.horizontal, 28)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .contentShape(Rectangle())
                .simultaneousGesture(swipeUpGesture)
            }
            .background {
                ReservoirBackground(
                    progress: progress,
                    phase: now.timeIntervalSinceReferenceDate,
                    blue: blue
                )
                .ignoresSafeArea()
            }
            .onChange(of: timer.isFinished(at: now)) {
                _, finished in

                if finished {
                    timer.finishIfNeeded(at: .now)
                }
            }
            .onChange(of: timer.isDrainFinished(at: now)) {
                _, finished in

                if finished {
                    timer.finishDrainIfNeeded(at: .now)
                }
            }
        }
        .sheet(isPresented: $showTimePicker) {
            CustomDurationPicker(
                durationSeconds: Binding(
                    get: {
                        timer.durationSeconds
                    },
                    set: { seconds in
                        FocusNotificationManager.cancel()
                        timer.setDuration(seconds)
                    }
                )
            )
            .presentationDetents([.fraction(0.75)])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: timer.completed) { _, completed in
            if completed {
                completionSound.play()
            } else {
                completionSound.stop()  
            }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Gestures

    private var swipeUpGesture: some Gesture {
        DragGesture(minimumDistance: 25)
            .onEnded { gesture in

                let vertical = gesture.translation.height
                let horizontal = gesture.translation.width

                if vertical < -55 &&
                   abs(vertical) > abs(horizontal) {
                    openTimePicker()
                }
            }
    }

    // MARK: - Timer Actions

    private func toggleTimer() {
        timer.toggle(at: .now)
        updateCompletionNotification()
    }

    private func drainTimer() {
        completionSound.stop()
        FocusNotificationManager.cancel()
        timer.drain(at: .now)
    }

    private func openTimePicker() {
        guard !timer.isRunning,
              !timer.isDraining else {
            return
        }

        showTimePicker = true
    }

    // MARK: - Notifications

    private func updateCompletionNotification() {
        guard timer.isRunning else {
            FocusNotificationManager.cancel()
            return
        }

        let remaining = max(
            0,
            Double(timer.durationSeconds)
                - timer.elapsedTime(at: .now)
        )

        let endDate = Date.now.addingTimeInterval(remaining)

        Task {
            await FocusNotificationManager.schedule(
                endDate: endDate
            )
        }
    }
}

#Preview {
    ContentView()
}
