import SwiftUI

enum PolarisTheme {
    enum ColorToken {
        static let background = Color(.systemGroupedBackground)
        static let surface = Color(.secondarySystemGroupedBackground)
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        static let accent = Color.indigo
        static let quietAccent = Color.indigo.opacity(0.12)
        static let night = Color(red: 0.05, green: 0.07, blue: 0.12)
        static let star = Color(red: 0.92, green: 0.96, blue: 1.0)
    }

    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
    }
}
