import SwiftUI
import CoreLocation

struct AstronomicalDataCard: View {
    let title: String
    let value: String
    let color: Color
    @State private var aiGeneratedData: String?
    @State private var isLoading = false
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main content
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Button(action: {
                    if aiGeneratedData == nil && !isLoading {
                        Task {
                            await fetchAIData()
                        }
                    }
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(color)
                }
            }
            
            // Expanded AI content
            if isExpanded {
                if isLoading {
                    ProgressView()
                        .padding(.top, 4)
                } else if let aiData = aiGeneratedData {
                    Text(aiData)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                        .transition(.opacity)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func fetchAIData() async {
        isLoading = true
        do {
            let data = try await GeminiService.shared.fetchContent(
                for: title,
                type: .astronomicalData
            )
            await MainActor.run {
                aiGeneratedData = data
                isLoading = false
            }
        } catch {
            await MainActor.run {
                aiGeneratedData = "Unable to fetch additional data."
                isLoading = false
            }
        }
    }
}

// Preview provider for SwiftUI canvas
struct AstronomicalDataCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AstronomicalDataCard(
                title: "Distance",
                value: "642.5 light years",
                color: .blue
            )
            AstronomicalDataCard(
                title: "Magnitude",
                value: "2.3",
                color: .purple
            )
        }
        .padding()
    }
} 