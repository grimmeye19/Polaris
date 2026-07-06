import SwiftUI

struct MapItemNodeView: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.92))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white.opacity(isSelected ? 0.22 : 0.12))
                        .shadow(color: Color.black.opacity(0.22), radius: 8)
                )
                .overlay {
                    if isSelected {
                        Circle()
                            .stroke(Color.white.opacity(0.72), lineWidth: 1)
                    }
                }

            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(1)
                .frame(width: 72)
        }
        .contentShape(Rectangle())
    }
}
