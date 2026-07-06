import SwiftUI

struct MomentDetailView: View {
    let moment: Moment
    @State private var showsEditMoment = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(dateFormatter.string(from: moment.occurredAt))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Exterior") {
                MomentDetailTextBlock(
                    text: moment.exteriorText,
                    emptyText: "Sin hechos exteriores registrados."
                )
            }

            Section("Interior") {
                MomentDetailTextBlock(
                    text: moment.interiorText,
                    emptyText: "Sin registro interior."
                )
            }

            Section {
                MomentDetailTextBlock(
                    text: moment.freeNotes,
                    emptyText: "Sin notas libres."
                )
            } header: {
                Text("Notas libres")
            } footer: {
                Text("Notas para recordar. No se presentan como hechos.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Momento")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") {
                    showsEditMoment = true
                }
            }
        }
        .sheet(isPresented: $showsEditMoment) {
            EditMomentView(moment: moment)
        }
    }

    private var title: String {
        guard let title = moment.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Momento"
        }

        return title
    }
}

private struct MomentDetailTextBlock: View {
    let text: String
    let emptyText: String

    var body: some View {
        if text.isEmpty {
            Text(emptyText)
                .foregroundStyle(.secondary)
        } else {
            Text(text)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        MomentDetailView(
            moment: Moment(
                expedition: Expedition(name: "Una etapa importante"),
                occurredAt: Date(),
                exteriorText: "Llegamos al puerto antes de que cerrara la tarde.",
                interiorText: "Senti alivio y una calma dificil de explicar.",
                freeNotes: "Recordar la luz sobre el agua."
            )
        )
    }
}
