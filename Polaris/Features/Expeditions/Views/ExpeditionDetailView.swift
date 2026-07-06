import SwiftUI

struct ExpeditionDetailView: View {
    let expedition: Expedition

    @State private var showsCreateMoment = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                memoryActions
                metadata
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Expedicion")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    ExpeditionSettingsView(expedition: expedition)
                } label: {
                    Label("Ajustes", systemImage: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showsCreateMoment) {
            CreateMomentView(expedition: expedition)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(expedition.name)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            if let description = expedition.optionalDescription, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Esta Expedicion todavia no tiene descripcion.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            StatusBadge(status: expedition.status)
        }
    }

    private var memoryActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memoria")
                .font(.headline)

            Button {
                showsCreateMoment = true
            } label: {
                Label("Registrar Momento", systemImage: "square.and.pencil")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(expedition.status == .closed)

            NavigationLink {
                HistoryView(expedition: expedition)
            } label: {
                Label("Ver Historia", systemImage: "book.pages")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            NavigationLink {
                MapView(expedition: expedition)
            } label: {
                Label("Ver Mapa", systemImage: "map")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            NavigationLink {
                ConstellationView(scope: .expedition(expedition))
            } label: {
                Label("Ver Constelacion", systemImage: "sparkles")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var metadata: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Datos de la Expedicion")
                .font(.headline)

            DetailRow(title: "Inicio", value: dateFormatter.string(from: expedition.startDate))
            DetailRow(title: "Creada", value: dateFormatter.string(from: expedition.createdAt))

            if let closedAt = expedition.closedAt {
                DetailRow(title: "Cierre", value: dateFormatter.string(from: closedAt))
            }
        }
    }
}

private struct StatusBadge: View {
    let status: ExpeditionStatus

    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(status == .active ? .blue : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(status == .active ? Color.blue.opacity(0.12) : Color.secondary.opacity(0.12))
            )
    }

    private var statusText: String {
        switch status {
        case .active:
            "Activa"
        case .closed:
            "Cerrada"
        }
    }
}

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 16)

            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        ExpeditionDetailView(
            expedition: Expedition(
                name: "Una etapa importante",
                optionalDescription: "Un viaje observado con calma.",
                startDate: Date()
            )
        )
    }
}
