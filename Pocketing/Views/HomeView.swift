import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var courses: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("POCKETING")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(NeoColors.black)
                        .tracking(4)

                    Text("MICRO-LEARN CS")
                        .font(NeoFonts.caption)
                        .foregroundColor(NeoColors.black.opacity(0.6))
                        .tracking(3)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(NeoColors.yellow)
                .overlay(
                    Rectangle()
                        .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
                )
                .shadow(color: NeoColors.black, radius: 0, x: NeoMetrics.shadowOffset, y: NeoMetrics.shadowOffset)

                // Mix All button
                NavigationLink(value: "MIX_ALL") {
                    Text("⚡ MIX ALL")
                        .font(NeoFonts.button)
                        .foregroundColor(NeoColors.hotPink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(NeoColors.white)
                        .overlay(
                            Rectangle()
                                .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
                        )
                        .shadow(color: NeoColors.black, radius: 0, x: NeoMetrics.shadowOffset, y: NeoMetrics.shadowOffset)
                }

                // Course grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: NeoMetrics.gridSpacing),
                    GridItem(.flexible(), spacing: NeoMetrics.gridSpacing)
                ], spacing: NeoMetrics.gridSpacing) {
                    ForEach(courses, id: \.self) { course in
                        NavigationLink(value: course) {
                            VStack(spacing: 8) {
                                Text(courseEmoji(for: course))
                                    .font(.system(size: 32))
                                Text(course.uppercased())
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(NeoColors.black)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(NeoColors.accent(for: course))
                            .overlay(
                                Rectangle()
                                    .stroke(NeoColors.black, lineWidth: NeoMetrics.borderWidth)
                            )
                            .shadow(color: NeoColors.black, radius: 0, x: NeoMetrics.shadowOffset, y: NeoMetrics.shadowOffset)
                        }
                    }
                }
            }
            .padding(NeoMetrics.gridSpacing)
        }
        .background(NeoColors.white)
        .onAppear {
            loadCourses()
        }
    }

    private func loadCourses() {
        let descriptor = FetchDescriptor<CardModel>()
        let allCards = (try? modelContext.fetch(descriptor)) ?? []
        courses = Array(Set(allCards.map { $0.course })).sorted()
    }

    private func courseEmoji(for course: String) -> String {
        switch course.lowercased() {
        case "concurrency": return "⚡"
        case "data structures": return "🏗️"
        case "operating systems": return "💻"
        default: return "📚"
        }
    }
}
