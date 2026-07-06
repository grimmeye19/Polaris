import SwiftUI

struct StarView: View {
    let size: CGFloat
    let opacity: Double
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(isSelected ? 0.22 : 0.10))
                .frame(width: size * 3.1, height: size * 3.1)
                .blur(radius: 3)

            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: size, height: size)
                .shadow(color: Color.white.opacity(isSelected ? 0.90 : 0.44), radius: isSelected ? 8 : 4)

            if isSelected {
                Circle()
                    .stroke(Color.white.opacity(0.70), lineWidth: 1)
                    .frame(width: size * 2.4, height: size * 2.4)
            }
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            StarView(size: 7, opacity: 0.62, isSelected: false)
            StarView(size: 9, opacity: 0.78, isSelected: false)
            StarView(size: 12, opacity: 0.96, isSelected: true)
        }
    }
}
