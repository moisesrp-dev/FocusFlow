
import SwiftUI

/// Generates a reusable, animated 2D water surface.
enum WaterWave {

    /// Creates a water-filled path with a gently moving surface.
    ///
    /// - Parameters:
    ///   - size: Available drawing area.
    ///   - fillFraction: Water level from 0 (empty) to 1 (full).
    ///   - phase: Current animation time.
    ///   - amplitude: Maximum wave height in points.
    ///   - speed: Horizontal wave animation speed.
    ///   - cycles: Number of waves across the drawing width.
    ///
    /// - Returns: A closed Path filled from the bottom upward.
    static func path(
        in size: CGSize,
        fillFraction: Double,
        phase: TimeInterval,
        amplitude: CGFloat = 5,
        speed: Double = 1.6,
        cycles: Double = 1
    ) -> Path {

        let fill = min(max(fillFraction, 0), 1)

        guard size.width > 0,
              size.height > 0,
              fill > 0 else {
            return Path()
        }

        // Completely full: no visible waves.
        if fill >= 1 {
            return Path(
                CGRect(origin: .zero, size: size)
            )
        }

        // The water surface moves upward as fill increases.
        let waterLevel = size.height * CGFloat(1 - fill)

        // Gradually flatten waves near empty and full.
        let availableSpace = min(
            waterLevel,
            size.height - waterLevel
        )

        let waveHeight = min(
            amplitude,
            availableSpace * 0.5
        )

        var path = Path()

        // Draw approximately one point every 2 screen points.
        let steps = max(
            1,
            Int(ceil(size.width / 2))
        )

        for step in 0...steps {

            let x = size.width
                * CGFloat(step)
                / CGFloat(steps)

            let position = Double(x / size.width)
                * .pi * 2 * cycles

            // Two combined sine waves create organic movement.
            let primaryWave = sin(
                position + phase * speed
            )

            let secondaryWave = 0.25 * sin(
                position * 2 - phase * speed * 0.65
            )

            let y = waterLevel
                + waveHeight
                * CGFloat(
                    (primaryWave + secondaryWave) / 1.25
                )

            if step == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        // Close the shape along the bottom.
        path.addLine(
            to: CGPoint(
                x: size.width,
                y: size.height
            )
        )

        path.addLine(
            to: CGPoint(
                x: 0,
                y: size.height
            )
        )

        path.closeSubpath()

        return path
    }
}

