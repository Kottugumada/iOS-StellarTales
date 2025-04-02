import Foundation

@MainActor
class APODViewModel: ObservableObject {
    @Published var apodData: APODData?
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        Task {
            await fetchAPOD()
        }
    }
    
    func fetchAPOD() async {
        isLoading = true
        error = nil
        apodData = nil  // Clear existing data to ensure view updates
        
        do {
            let newData = try await AstronomyAPI.shared.fetchAPOD()
            // Ensure we're getting a different image
            if newData.url != apodData?.url {
                apodData = newData
            } else {
                // Try again if we got the same image
                return await fetchAPOD()
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func fetchRecentImage() async throws -> APODData {
        // Try last 7 days one by one
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        
        for daysAgo in 0...7 {
            do {
                // Use the existing fetchAPOD method
                let apod = try await AstronomyAPI.shared.fetchAPOD(count: 1)
                if apod.mediaType == "image" {
                    return apod
                }
            } catch {
                continue // Try next day if current day fails
            }
        }
        
        throw APIError.noImageAvailable
    }
} 