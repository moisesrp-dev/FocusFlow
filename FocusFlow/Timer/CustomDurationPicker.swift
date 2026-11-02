
import SwiftUI

struct CustomDurationPicker: View {

    @Binding var durationSeconds: Int
    @Environment(\.dismiss) private var dismiss

    @State private var enteredDigits = ""
    @State private var hasStartedTyping = false

    private let blue = Color(
        red: 0.03, green: 0.60, blue: 1.0
    )

    private let keys = [
        "1", "2", "3",
        "4", "5", "6",
        "7", "8", "9",
        "00", "0", "delete"
    ]

    // MARK: - Time

    private var displayDigits: String {
        let raw: String

        if hasStartedTyping {
            raw = enteredDigits
        } else {
            let h = durationSeconds / 3600
            let m = (durationSeconds % 3600) / 60
            let s = durationSeconds % 60

            raw = String(
                format: "%02d%02d%02d", h, m, s
            )
        }

        return String(
            repeating: "0",
            count: max(0, 6 - raw.count)
        ) + raw
    }

    private var formattedTime: String {
        let d = displayDigits

        return "\(d.prefix(2)):" +
               "\(d.dropFirst(2).prefix(2)):" +
               "\(d.suffix(2))"
    }

    private var selectedSeconds: Int? {
        let d = displayDigits

        let h = Int(d.prefix(2)) ?? 0
        let m = Int(d.dropFirst(2).prefix(2)) ?? 0
        let s = Int(d.suffix(2)) ?? 0

        guard m < 60, s < 60 else { return nil }

        let total = h * 3600 + m * 60 + s
        return total > 0 ? total : nil
    }

    // MARK: - Layout

    var body: some View {
        VStack(spacing: 0) {

            // Top controls
            HStack {
                headerButton("Cancel") {
                    dismiss()
                }

                Spacer()

                headerButton("Clear") {
                    clearInput()
                }
            }
            .padding(.top, 12)

            Spacer(minLength: 30)

            // Large digital time
            Text(formattedTime)
                .font(.system(
                    size: 52,
                    weight: .semibold,
                    design: .rounded
                ))
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .contentTransition(.numericText())

            Spacer(minLength: 35)

            // Compact number pad
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(
                        .flexible(),
                        spacing: 12
                    ),
                    count: 3
                ),
                spacing: 12
            ) {
                ForEach(keys, id: \.self) { key in
                    numberButton(key)
                }
            }
            .frame(maxWidth: 320)

            Spacer(minLength: 28)

            // Confirm
            Button {
                guard let seconds = selectedSeconds else {
                    return
                }

                durationSeconds = seconds
                dismiss()
            } label: {
                Text("Set Duration")
                    .font(.system(
                        size: 17,
                        weight: .semibold
                    ))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        selectedSeconds == nil
                            ? Color.gray : blue
                    )
                    .clipShape(Capsule())
            }
            .disabled(selectedSeconds == nil)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.light)
    }

    // MARK: - Header Buttons

    private func headerButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(.black)
                .padding(.horizontal, 18)
                .frame(height: 62)
                .background(.white)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(
                            Color.black.opacity(0.08),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Number Buttons

    private func numberButton(_ key: String) -> some View {
        Button {
            handleKey(key)
        } label: {
            Group {
                if key == "delete" {
                    Image(systemName: "delete.left")
                } else {
                    Text(key)
                }
            }
            .font(.system(
                size: 26,
                weight: .medium,
                design: .rounded
            ))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(white: 0.94))
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .contentShape(
                RoundedRectangle(cornerRadius: 20)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            key == "delete" ? "Backspace" :
            key == "00" ? "Double zero" : key
        )
    }

    // MARK: - Input

    private func handleKey(_ key: String) {
        if key == "delete" {
            if !hasStartedTyping {
                clearInput()
            } else if !enteredDigits.isEmpty {
                enteredDigits.removeLast()
            }
            return
        }

        if !hasStartedTyping {
            enteredDigits = ""
            hasStartedTyping = true
        }

        guard enteredDigits.count + key.count <= 6 else {
            return
        }

        enteredDigits += key
    }

    private func clearInput() {
        enteredDigits = ""
        hasStartedTyping = true
    }
}

#Preview {
    CustomDurationPicker(
        durationSeconds: .constant(25 * 60)
    )
}
