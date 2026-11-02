
import SwiftUI

struct TimerHeaderView: View {

    var body: some View {
        HStack {
            Text("FlowFocus")
                .font(.system(
                    size: 27,
                    weight: .bold
                ))

            Spacer()
        }
        .padding(.top, 12)
    }
}

#Preview {
    TimerHeaderView()
        .padding()
}
