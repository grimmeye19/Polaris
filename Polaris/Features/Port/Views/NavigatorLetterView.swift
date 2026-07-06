import SwiftData
import SwiftUI

struct NavigatorLetterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var letters: [NavigatorLetter]
    @StateObject private var viewModel = NavigatorLetterViewModel()
    @State private var saveErrorMessage: String?
    @State private var showsSavedConfirmation = false
    @FocusState private var isEditorFocused: Bool

    init() {
        _letters = Query(sort: \NavigatorLetter.updatedAt, order: .reverse)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                editor
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Carta al Navegante")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    saveLetter()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .alert("Carta guardada", isPresented: $showsSavedConfirmation) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text("Tu Carta permanece en el Puerto.")
        }
        .alert("No se pudo guardar", isPresented: showsSaveError) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text(saveErrorMessage ?? "Intenta de nuevo.")
        }
        .onAppear {
            viewModel.loadIfNeeded(from: currentLetter)
        }
    }

    private var currentLetter: NavigatorLetter? {
        letters.first
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Una voz desde la claridad")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.guidance)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.updatedAtText(for: currentLetter))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $viewModel.content)
                .focused($isEditorFocused)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(minHeight: 320)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemGroupedBackground))
                )

            if viewModel.content.isEmpty {
                Text(viewModel.placeholder)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                    .allowsHitTesting(false)
            }
        }
    }

    private var showsSaveError: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    saveErrorMessage = nil
                }
            }
        )
    }

    private func saveLetter() {
        do {
            try viewModel.save(existing: currentLetter, in: modelContext)
            isEditorFocused = false
            showsSavedConfirmation = true
        } catch {
            saveErrorMessage = "La Carta no pudo conservarse localmente."
        }
    }
}

#Preview {
    NavigationStack {
        NavigatorLetterView()
    }
    .modelContainer(PolarisModelContainer.shared)
}
