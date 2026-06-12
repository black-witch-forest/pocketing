import SwiftUI
import SwiftData

@main
struct PocketingApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: CardModel.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    DataSeeder.seedIfNeeded(context: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
