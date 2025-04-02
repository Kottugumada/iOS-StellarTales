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
    
    func fetchAPOD() {
        isLoading = true
        error = nil
        
        Task {
            do {
                // Try to fetch with multiple days
                let data = try await AstronomyAPI.shared.fetchAPOD(count: 10)
                self.apodData = data
                self.isLoading = false
            } catch {
                // If that fails, try specific date range
                do {
                    let data = try await fetchRecentImage()
                    self.apodData = data
                    self.isLoading = false
                } catch {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
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