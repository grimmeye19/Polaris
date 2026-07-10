import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String?
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        title: String,
        message: String,
        systemImage: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PolarisTheme.Spacing.md) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(PolarisTheme.ColorToken.accent)
            }

            VStack(alignment: .leading, spacing: PolarisTheme.Spacing.sm) {
                Text(title)
                    .font(PolarisTypography.sectionTitle)
                    .fontWeight(.semibold)

                Text(message)
                    .font(PolarisTypography.body)
                    .foregroundStyle(PolarisTheme.ColorToken.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Label(actionTitle, systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, PolarisTheme.Spacing.xs)
            }
        }
        .padding(PolarisTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: PolarisTheme.Radius.sm, style: .continuous)
                .fill(PolarisTheme.ColorToken.surface)
        )
    }
}
