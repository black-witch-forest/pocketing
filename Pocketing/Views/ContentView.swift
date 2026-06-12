import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
                .navigationDestination(for: String.self) { courseValue in
                    if courseValue == "MIX_ALL" {
                        ArenaView(course: nil)
                    } else {
                        ArenaView(course: courseValue)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
