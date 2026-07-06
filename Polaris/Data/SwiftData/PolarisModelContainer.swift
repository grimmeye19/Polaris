import SwiftData

enum PolarisModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            Expedition.self,
            Moment.self,
            MapEntry.self,
            NavigatorLetter.self,
            Provision.self,
            Mantra.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Unable to create Polaris SwiftData container: \(error)")
        }
    }()
}
