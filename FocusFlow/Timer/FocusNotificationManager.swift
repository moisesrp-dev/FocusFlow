
import Foundation
import UserNotifications

enum FocusNotificationManager {

    private static let identifier = "focus-complete"

    static func schedule(endDate: Date) async {
        let center = UNUserNotificationCenter.current()

        do {
            let allowed = try await center.requestAuthorization(
                options: [.alert, .sound]
            )

            guard allowed else { return }

            center.removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )

            let remaining = endDate.timeIntervalSinceNow
            guard remaining > 0 else { return }

            let content = UNMutableNotificationContent()
            content.title = "Focus Complete"
            content.body = "Your capsule is full. Time to take a break!"
            content.sound = UNNotificationSound(
                named: UNNotificationSoundName(
                    rawValue: "focus-complete.wav"
                )
            )

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: remaining,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            try await center.add(request)

        } catch {
            print("Notification error: \(error)")
        }
    }

    static func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )
    }
}
