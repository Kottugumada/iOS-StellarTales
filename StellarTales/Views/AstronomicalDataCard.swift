import SwiftUI
import CoreLocation

struct AstronomicalDataCard: View {
    let object: SpaceObject
    @State private var astronomicalData: AstronomicalData?
    @State private var isLoading = true
    let locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Location and Time Header
            HStack {
                Label {
                    Text(locationManager.locationName ?? "Location Unknown")
                } icon: {
                    Image(systemName: "location.fill")
                }
                Spacer()
                Button {
                    // Show location picker
                } label: {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                }
            }
            .padding(.bottom, 8)
            
            if isLoading {
                ProgressView()
                    .frame(height: 200)
            } else if let data = astronomicalData {
                // Visibility Times
                HStack(spacing: 20) {
                    VisibilityTimeCard(
                        title: "Rises",
                        time: data.riseTime,
                        icon: "sunrise.fill",
                        color: Color.orange
                    )
                    VisibilityTimeCard(
                        title: "Transit",
                        time: data.transitTime,
                        icon: "sun.max.fill",
                        color: Color.yellow
                    )
                    VisibilityTimeCard(
                        title: "Sets",
                        time: data.setTime,
                        icon: "sunset.fill",
                        color: Color.purple
                    )
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Object Details
                VStack(spacing: 12) {
                    if let magnitude = data.magnitude {
                        DetailRow(
                            title: "Magnitude",
                            value: String(format: "%.1f", magnitude),
                            icon: "star.fill",
                            color: Color.yellow
                        )
                    }
                    
                    if let distance = data.distance {
                        DetailRow(
                            title: "Distance",
                            value: formatDistance(distance),
                            icon: "ruler.fill",
                            color: Color.blue
                        )
                    }
                    
                    DetailRow(
                        title: "Best Viewing",
                        value: data.bestViewingTime,
                        icon: "eye.fill",
                        color: Color.green
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
        .onAppear {
            fetchAstronomicalData()
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        let lightYears = distance
        let parsecs = distance / 3.26156
        return String(format: "%.1f ly (%.1f pc)", lightYears, parsecs)
    }
    
    private func fetchAstronomicalData() {
        Task {
            do {
                let coordinates = locationManager.location?.coordinate
                let data = try await AstronomyAPI.shared.fetchObjectData(
                    name: object.title,
                    type: object.type,
                    latitude: coordinates?.latitude ?? 0,
                    longitude: coordinates?.longitude ?? 0
                )
                await MainActor.run {
                    self.astronomicalData = data
                    self.isLoading = false
                }
            } catch {
                print("Error fetching astronomical data: \(error)")
                self.isLoading = false
            }
        }
    }
}

// Renamed to avoid conflict
struct VisibilityTimeCard: View {
    let title: String
    let time: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(time)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
} 