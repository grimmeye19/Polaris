import SwiftUI

struct StormStartView: View {
    @StateObject private var viewModel = StormViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                steps
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.title)
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text(viewModel.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var steps: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.steps) { step in
                StormStepRow(step: step)
            }
        }
    }
}

private struct StormStepRow: View {
    let step: StormProtocolStep

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(step.id)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.indigo.opacity(0.8)))

            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .font(.headline)

                Text(step.prompt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}
