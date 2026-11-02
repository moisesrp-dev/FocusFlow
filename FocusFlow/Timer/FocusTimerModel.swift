
import Foundation
import Observation

@Observable
@MainActor
final class FocusTimerModel {

    // MARK: - Configuration

    private(set) var durationSeconds: Int = 25 * 60
    private(set) var completed = false

    // MARK: - Timer State

    private var startedAt: Date?
    private var elapsedBeforePause: TimeInterval = 0
    private var drainState: DrainState?

    private struct DrainState {
        let startedAt: Date
        let fromProgress: Double
    }

    var isRunning: Bool {
        startedAt != nil
    }

    var isDraining: Bool {
        drainState != nil
    }

    // MARK: - Time Calculations

    func elapsedTime(at date: Date) -> TimeInterval {
        let runningTime = startedAt.map {
            max(0, date.timeIntervalSince($0))
        } ?? 0

        return min(
            Double(durationSeconds),
            elapsedBeforePause + runningTime
        )
    }

    func remainingSeconds(at date: Date) -> Int {
        max(
            0,
            Int(ceil(
                Double(durationSeconds) - elapsedTime(at: date)
            ))
        )
    }

    // MARK: - Water Animation

    func visualProgress(at date: Date) -> Double {

        // Reverse the animation during Drain.
        if let drain = drainState {
            let elapsed = date.timeIntervalSince(drain.startedAt)

            let t = min(max(elapsed, 0), 1)

            // Smooth ease-in/ease-out over 1 second.
            let eased = t * t * (3 - 2 * t)

            return drain.fromProgress * (1 - eased)
        }

        // Normal timer progress: 0 = empty, 1 = full.
        return min(
            max(
                elapsedTime(at: date) /
                Double(max(durationSeconds, 1)),
                0
            ),
            1
        )
    }

    // MARK: - Playback

    func toggle(at date: Date) {
        guard !isDraining else { return }

        if let start = startedAt {

            // Pause and preserve accumulated time.
            elapsedBeforePause = min(
                Double(durationSeconds),
                elapsedBeforePause +
                    max(0, date.timeIntervalSince(start))
            )

            startedAt = nil

        } else {

            // Restart a completed timer.
            if completed {
                elapsedBeforePause = 0
                completed = false
            }

            // Resume or start.
            startedAt = date
        }
    }

    // MARK: - Completion

    func isFinished(at date: Date) -> Bool {
        isRunning &&
        elapsedTime(at: date) >= Double(durationSeconds)
    }

    func finishIfNeeded(at date: Date) {
        guard isFinished(at: date) else { return }

        elapsedBeforePause = Double(durationSeconds)
        startedAt = nil
        completed = true
    }

    // MARK: - Drain

    func canDrain(at date: Date) -> Bool {
        !isDraining && elapsedTime(at: date) > 0
    }

    func drain(at date: Date) {
        guard canDrain(at: date) else { return }

        let progress = visualProgress(at: date)

        // Freeze the timer.
        elapsedBeforePause = elapsedTime(at: date)
        startedAt = nil

        // Begin the 1-second reverse animation.
        drainState = DrainState(
            startedAt: date,
            fromProgress: progress
        )
    }

    func isDrainFinished(at date: Date) -> Bool {
        guard let drain = drainState else {
            return false
        }

        return date.timeIntervalSince(drain.startedAt) >= 1
    }

    func finishDrainIfNeeded(at date: Date) {
        guard isDrainFinished(at: date) else { return }

        reset()
    }

    // MARK: - Reset

    func reset() {
        startedAt = nil
        elapsedBeforePause = 0
        drainState = nil
        completed = false
    }

    // MARK: - Configuration

    func setDuration(_ seconds: Int) {
        // Supports HH:MM:SS up to 99:59:59.
        guard seconds > 0,
              seconds <= 359_999 else {
            return
        }

        durationSeconds = seconds
        reset()
    }

    private struct SavedTimer: Codable {
        let duration: Int
        let elapsed: TimeInterval
        let startedAt: Date?
        let completed: Bool
    }

    private let storageKey = "FlowFocus.TimerState"

    init() {
        guard let data = UserDefaults.standard.data(
            forKey: storageKey
        ),
        let saved = try? JSONDecoder().decode(
            SavedTimer.self,
            from: data
        ) else {
            return
        }

        durationSeconds = saved.duration
        elapsedBeforePause = saved.elapsed
        startedAt = saved.startedAt
        completed = saved.completed

        finishIfNeeded(at: .now)
    }

    private func saveState() {
        let snapshot = SavedTimer(
            duration: durationSeconds,
            elapsed: elapsedBeforePause,
            startedAt: startedAt,
            completed: completed
        )

        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )
        }
    }
}

