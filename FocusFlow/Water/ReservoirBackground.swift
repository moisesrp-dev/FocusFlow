
import SwiftUI

struct ReservoirBackground: View {

    // MARK: - Properties

    /// Capsule progress: 0 = empty, 1 = full.
    let progress: Double

    /// Animation time shared with WaterCapsule.
    let phase: TimeInterval

    /// Water color.
    let blue: Color

    // MARK: - View

    var body: some View {
        Canvas { context, size in

            // White is revealed as water recedes.
            context.fill(
                Path(CGRect(
                    origin: .zero,
                    size: size
                )),
                with: .color(.white)
            )

            // Background and capsule have opposite levels.
            let backgroundFill = 1 - progress

            // Generate the animated water surface.
            let water = WaterWave.path(
                in: size,
                fillFraction: backgroundFill,
                phase: phase,
                amplitude: 5,
                speed: 1.2,
                cycles: 1
            )

            // Draw the blue water.
            context.fill(
                water,
                with: .color(blue)
            )
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

// MARK: - Previews

#Preview("Full Background") {
    ReservoirBackground(
        progress: 0,
        phase: 0,
        blue: .cyan
    )
}

#Preview("Half Background") {
    ReservoirBackground(
        progress: 0.5,
        phase: 0,
        blue: .cyan
    )
}

#Preview("Empty Background") {
    ReservoirBackground(
        progress: 1,
        phase: 0,
        blue: .cyan
    )
}

