import SwiftUI

struct HistoryView: View {
    let expedition: Expedition

    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        Group {
            let moments = viewModel.sortedMoments(for: expedition)

            if moments.isEmpty {
                emptyState
            } else {
                List {
                    Section("Momentos") {
                        ForEach(moments) { moment in
                            NavigationLink {
                                MomentDetailView(moment: moment)
                            } label: {
                                MomentHistoryRowView(
                                    moment: moment,
                                    title: viewModel.title(for: moment),
                                    occurredAtText: viewModel.formattedOccurredAt(for: moment)
                                )
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Historia")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer()

            EmptyStateView(
                title: viewModel.emptyTitle,
                message: viewModel.emptyMessage,
                systemImage: "book.pages"
            )

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
    }
}

private struct MomentHistoryRowView: View {
    let moment: Moment
    let title: String
    let occurredAtText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(occurredAtText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !moment.exteriorText.isEmpty {
                HistoryTextBlock(title: "Exterior", text: moment.exteriorText)
            }

            if !moment.interiorText.isEmpty {
                HistoryTextBlock(title: "Interior", text: moment.interiorText)
            }

            if !moment.freeNotes.isEmpty {
                HistoryTextBlock(title: "Notas", text: moment.freeNotes)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct HistoryTextBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(
            expedition: Expedition(
                name: "Una etapa importante",
                optionalDescription: "Un viaje observado con calma."
            )
        )
    }
}
