import SwiftUI

struct MapTerritoryView: View {
    let nodes: [MapTerritoryNode]
    @Binding var selectedNode: MapTerritoryNode?
    let titleForType: (MapEntryType) -> String
    let iconForType: (MapEntryType) -> String
    let dateText: (MapTerritoryNode) -> String

    var body: some View {
        ZStack {
            MapTerritoryBackground()

            GeometryReader { proxy in
                ZStack {
                    ForEach(nodes) { node in
                        Button {
                            selectedNode = node
                        } label: {
                            MapItemNodeView(
                                icon: iconForType(node.type),
                                title: node.title,
                                isSelected: selectedNode?.id == node.id
                            )
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: node.x * proxy.size.width,
                            y: node.y * proxy.size.height
                        )
                    }
                }
            }
            .padding(.bottom, selectedNode == nil ? 0 : 164)

            VStack {
                Spacer()

                if let selectedNode {
                    selectedNodeCard(selectedNode)
                        .padding(16)
                }
            }
        }
    }

    private func selectedNodeCard(_ node: MapTerritoryNode) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(iconForType(node.type))
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(node.title)
                        .font(.headline)

                    Text("\(titleForType(node.type)) · \(dateText(node))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !node.content.isEmpty {
                Text(node.content)
                    .font(.subheadline)
                    .lineLimit(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct MapTerritoryBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.09, blue: 0.12),
                Color(red: 0.10, green: 0.12, blue: 0.15),
                Color(red: 0.05, green: 0.07, blue: 0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
