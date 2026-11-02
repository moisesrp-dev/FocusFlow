
import SwiftUI

struct WaterCapsule: View {

    // MARK: - Properties

    /// Water level: 0 = empty, 1 = full.
    let progress: Double

    /// Animation time used by WaterWave.
    let phase: TimeInterval

    private let waterColor = Color(
        red: 0.03,
        green: 0.60,
        blue: 1.0
    )

    private let borderWidth: CGFloat = 3

    // MARK: - View

    var body: some View {
        Capsule()
            .fill(.white)
            .overlay {
                Canvas { context, size in

                    let water = WaterWave.path(
                        in: size,
                        fillFraction: progress,
                        phase: phase
                    )

                    context.fill(
                        water,
                        with: .color(waterColor)
                    )
                }
                .clipShape(Capsule())
            }
            .overlay {
                Capsule()
                    .stroke(
                        .black,
                        lineWidth: borderWidth
                    )
            }
            .accessibilityLabel(
                "Water level"
            )
            .accessibilityValue(
                "\(Int(min(max(progress, 0), 1) * 100)) percent"
            )
    }
}

// MARK: - Preview

#Preview("Empty") {
    WaterCapsule(
        progress: 0,
        phase: 0
    )
    .frame(width: 170, height: 370)
    .padding()
}

#Preview("Half Full") {
    WaterCapsule(
        progress: 0.5,
        phase: 0
    )
    .frame(width: 170, height: 370)
    .padding()
}

#Preview("Full") {
    WaterCapsule(
        progress: 1,
        phase: 0
    )
    .frame(width: 170, height: 370)
    .padding()
}

