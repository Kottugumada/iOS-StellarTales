import SwiftUI

struct CelestialObjectDetailView: View {
    let object: SpaceObject
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image Section
                AsyncImageView(url: object.imageUrl)
                    .frame(height: 300)
                    .overlay {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .overlay(alignment: .bottomLeading) {
                        Text(object.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                    }
                
                // Quick Facts Card
                VStack(spacing: 16) {
                    // Type and Basic Info
                    HStack {
                        Label(object.type.rawValue.capitalized, systemImage: iconForType(object.type))
                            .foregroundColor(.blue)
                        Spacer()
                        if let magnitude = object.magnitude {
                            Label("Magnitude: \(String(format: "%.1f", magnitude))", systemImage: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .font(.headline)
                    
                    // Summary
                    Text(object.summary)
                        .font(.body)
                        .lineSpacing(4)
                    
                    // Visibility Times
                    if let visibility = object.visibility {
                        VisibilityTimesView(times: visibility)
                    }
                    
                    // Distance Info
                    if let distance = object.distance {
                        DistanceView(distance: distance)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding()
                
                // Detailed Information Sections
                Group {
                    // Mythology Section
                    InfoSection(
                        title: "Mythology & History",
                        content: object.mythology,
                        icon: "book.fill"
                    )
                    
                    // Scientific Description
                    InfoSection(
                        title: "Scientific Details",
                        content: object.detailedDescription,
                        icon: "telescope.fill"
                    )
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.top)
    }
    
    private func iconForType(_ type: SpaceObject.CelestialType) -> String {
        switch type {
        case .star: return "star.fill"
        case .constellation: return "sparkles"
        case .planet: return "globe"
        case .galaxy: return "hurricane"
        case .nebula: return "cloud.fill"
        case .cluster: return "star.circle.fill"
        }
    }
}

struct VisibilityTimesView: View {
    let times: SpaceObject.VisibilityTimes
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Today's Visibility")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                TimeCard(label: "Rise", time: times.rise, icon: "sunrise.fill")
                TimeCard(label: "Transit", time: times.transit, icon: "sun.max.fill")
                TimeCard(label: "Set", time: times.set, icon: "sunset.fill")
            }
            
            Label("Best viewing: \(times.bestViewingTime)", systemImage: "eye.fill")
                .font(.subheadline)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TimeCard: View {
    let label: String
    let time: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(time)
                .font(.subheadline)
                .bold()
        }
        .frame(maxWidth: .infinity)
    }
}

struct DistanceView: View {
    let distance: SpaceObject.Distance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Distance from Earth")
                .font(.headline)
            
            if let ly = distance.lightYears {
                Text("• \(String(format: "%.1f", ly)) light years")
                    .font(.subheadline)
            }
            if let pc = distance.parsecs {
                Text("• \(String(format: "%.1f", pc)) parsecs")
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(content)
                .font(.body)
                .lineSpacing(6)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding(.vertical, 8)
    }
} 