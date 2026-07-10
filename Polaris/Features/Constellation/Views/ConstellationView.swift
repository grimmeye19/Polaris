import SwiftData
import SwiftUI

struct ConstellationView: View {
    @Query(sort: \Moment.occurredAt, order: .forward) private var allMoments: [Moment]
    @Query(sort: \Expedition.startDate, order: .reverse) private var expeditions: [Expedition]

    @StateObject private var viewModel: ConstellationViewModel
    @State private var selectedStar: ConstellationStar?

    init(scope: ConstellationScope) {
        _viewModel = StateObject(wrappedValue: ConstellationViewModel(scope: scope))
    }

    var body: some View {
        let stars = viewModel.stars(allMoments: allMoments)

        ZStack {
            ConstellationBackground()

            if stars.isEmpty {
                emptyState
            } else {
                starField(stars)
                overlay(for: stars)
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyState: some View {
        EmptyStateView(
            title: viewModel.emptyTitle,
            message: viewModel.emptyMessage,
            systemImage: "sparkles"
        )
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func starField(_ stars: [ConstellationStar]) -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(stars) { star in
                    Button {
                        selectedStar = star
                    } label: {
                        StarView(
                            size: star.size,
                            opacity: star.opacity,
                            isSelected: selectedStar?.id == star.id
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(star.title)
                    .position(
                        x: star.x * proxy.size.width,
                        y: star.y * proxy.size.height
                    )
                }
            }
        }
        .padding(.bottom, selectedStar == nil ? 0 : 172)
    }

    private func overlay(for stars: [ConstellationStar]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            header(starCount: stars.count)

            Spacer()

            if let selectedStar {
                selectedStarCard(selectedStar)
                    .padding(16)
            }
        }
    }

    private func header(starCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.headerTitle)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(2)

            Text("\(starCount) estrellas conservadas")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.64))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func selectedStarCard(_ star: ConstellationStar) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(star.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(viewModel.formattedDate(for: star))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(star.summary)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(3)

            Text(star.expeditionName)
                .font(.caption)
                .foregroundStyle(.secondary)

            switch viewModel.scope {
            case .global:
                if let expedition = viewModel.expedition(for: star, in: expeditions) {
                    NavigationLink {
                        ExpeditionDetailView(expedition: expedition)
                    } label: {
                        Label("Ir a Expedición", systemImage: "arrow.right.circle")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                }
            case .expedition:
                if let moment = viewModel.moment(for: star) {
                    NavigationLink {
                        MomentDetailView(moment: moment)
                    } label: {
                        Label("Abrir Momento", systemImage: "arrow.right.circle")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ConstellationBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.03, green: 0.05, blue: 0.10),
                Color(red: 0.06, green: 0.08, blue: 0.15),
                Color(red: 0.01, green: 0.02, blue: 0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        ConstellationView(
            scope: .expedition(Expedition(
                name: "Una etapa importante",
                optionalDescription: "Un cielo minimo para mirar la Historia."
            ))
        )
    }
}
