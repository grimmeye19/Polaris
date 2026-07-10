import Foundation

struct StormProtocolStep: Identifiable {
    let id: Int
    let title: String
    let prompt: String
}

enum StormProtocol {
    static let steps: [StormProtocolStep] = [
        StormProtocolStep(
            id: 1,
            title: "Qué ocurrió",
            prompt: "Nombra el hecho principal sin interpretarlo todavía."
        ),
        StormProtocolStep(
            id: 2,
            title: "Qué observé",
            prompt: "Separa lo observado de lo imaginado."
        ),
        StormProtocolStep(
            id: 3,
            title: "Qué estoy suponiendo",
            prompt: "Escribe las suposiciones que estan presentes."
        ),
        StormProtocolStep(
            id: 4,
            title: "Revisar Historia",
            prompt: "Vuelve a los Momentos de esta Expedición."
        ),
        StormProtocolStep(
            id: 5,
            title: "Revisar Corrientes",
            prompt: "Mira los patrones descriptivos disponibles."
        ),
        StormProtocolStep(
            id: 6,
            title: "Revisar Puerto",
            prompt: "Recuerda tus recursos personales."
        ),
        StormProtocolStep(
            id: 7,
            title: "Qué queda abierto",
            prompt: "Deja nombrado lo que aún necesita tiempo."
        ),
    ]
}
