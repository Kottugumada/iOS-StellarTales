import SwiftUI

struct InfoCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CelestialObjectDetailView: View {
    let spaceObject: SpaceObject
    @State private var mythology: String = "Loading mythology..."
    @State private var scientificDetails: String = "Loading scientific details..."
    @State private var observationTips: String = "Loading observation tips..."
    @State private var isLoadingMythology = true
    @State private var isLoadingScientific = true
    @State private var isLoadingTips = true
    @State private var errorMessage: String?
    
    init(spaceObject: SpaceObject) {
        self.spaceObject = spaceObject
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Section
                AsyncImage(url: URL(string: spaceObject.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(_):
                        Image(systemName: "star.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Quick Facts Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Facts")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if let constellation = spaceObject.constellation {
                            AstronomicalDataCard(
                                title: "Constellation",
                                value: constellation,
                                color: .blue
                            )
                        }
                        if let distance = spaceObject.distance {
                            AstronomicalDataCard(
                                title: "Distance",
                                value: "\(distance) light years",
                                color: .purple
                            )
                        }
                        if let magnitude = spaceObject.magnitude {
                            AstronomicalDataCard(
                                title: "Magnitude",
                                value: String(format: "%.1f", magnitude),
                                color: .orange
                            )
                        }
                        if let visibility = spaceObject.visibility {
                            InfoCard(title: "Visibility",
                                   value: """
                                   Rise: \(visibility.rise)
                                   Transit: \(visibility.transit)
                                   Set: \(visibility.set)
                                   Best: \(visibility.bestViewingTime)
                                   """,
                                   color: .green)
                        }
                    }
                }
                
                // Scientific Details Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Scientific Details")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if isLoadingScientific {
                        ProgressView()
                            .padding()
                    } else {
                        Text(scientificDetails)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
                
                // Mythology & History Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mythology & History")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if isLoadingMythology {
                        ProgressView()
                            .padding()
                    } else {
                        Text(mythology)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
                
                // Observation Tips Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Observation Tips")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if isLoadingTips {
                        ProgressView()
                            .padding()
                    } else {
                        Text(observationTips)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(spaceObject.title)
        .task {
            await fetchAllContent()
        }
    }
    
    private func fetchAllContent() async {
        await withTaskGroup(of: Void.self) { group in
            // Fetch scientific details
            group.addTask {
                do {
                    let details = try await GeminiService.shared.fetchContent(
                        for: spaceObject.title,
                        type: .scientific
                    )
                    await MainActor.run {
                        scientificDetails = details
                        isLoadingScientific = false
                    }
                } catch {
                    await MainActor.run {
                        scientificDetails = "Unable to fetch scientific details."
                        isLoadingScientific = false
                    }
                }
            }
            
            // Fetch mythology
            group.addTask {
                do {
                    let myth = try await GeminiService.shared.fetchContent(
                        for: spaceObject.title,
                        type: .mythology
                    )
                    await MainActor.run {
                        mythology = myth
                        isLoadingMythology = false
                    }
                } catch {
                    await MainActor.run {
                        mythology = "Unable to fetch mythology."
                        isLoadingMythology = false
                    }
                }
            }
            
            // Fetch observation tips
            group.addTask {
                do {
                    let tips = try await GeminiService.shared.fetchContent(
                        for: spaceObject.title,
                        type: .observationTips
                    )
                    await MainActor.run {
                        observationTips = tips
                        isLoadingTips = false
                    }
                } catch {
                    await MainActor.run {
                        observationTips = "Unable to fetch observation tips."
                        isLoadingTips = false
                    }
                }
            }
        }
    }
} 