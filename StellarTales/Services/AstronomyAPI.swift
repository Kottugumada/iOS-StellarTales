import Foundation

// Make sure we're in the same module as SpaceObject
struct AstronomyAPI {
    static let shared = AstronomyAPI()
    
    private let apiKey = AppSecrets.nasaKey
    private let baseUrl = "https://api.nasa.gov"
    
    func fetchSpaceObject(name: String) async throws -> SpaceObject {
        let urlString = "\(baseUrl)/planetary/apod?api_key=\(apiKey)"
        guard let _ = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Remove unused data fetch and decoder since we're returning mock data
        return SpaceObject(
            id: UUID(),
            title: name,
            summary: "Brief overview of \(name)",
            detailedDescription: "Description for \(name)",
            imageUrl: "https://example.com/image.jpg",
            mythology: "Mythology for \(name)",
            type: .determineType(from: name),
            magnitude: nil,
            distance: nil,
            visibility: nil,
            constellation: name
        )
    }
    
    func fetchObjectData(name: String, type: SpaceObject.CelestialType, latitude: Double, longitude: Double) async throws -> AstronomicalData {
        // Combine data from multiple sources
        async let visibilityData = fetchVisibilityData(name: name, lat: latitude, lon: longitude)
        async let objectDetails = fetchObjectDetails(name: name, type: type)
        
        let (visibility, details) = try await (visibilityData, objectDetails)
        
        return AstronomicalData(
            riseTime: visibility.riseTime,
            transitTime: visibility.transitTime,
            setTime: visibility.setTime,
            bestViewingTime: visibility.bestViewingTime,
            magnitude: details.magnitude,
            distance: details.distance
        )
    }
    
    private func fetchVisibilityData(name: String, lat: Double, lon: Double) async throws -> VisibilityData {
        // Default values in case of API failure
        return VisibilityData(
            riseTime: "05:30 AM",
            transitTime: "12:45 PM",
            setTime: "07:30 PM",
            bestViewingTime: "09:00 PM"
        )
        
        // TODO: Implement actual API call
        /*
        let url = "https://api.astronomyapi.com/api/v2/bodies/positions/\(name)"
        // Implement API call here
        */
    }
    
    private func fetchObjectDetails(name: String, type: SpaceObject.CelestialType) async throws -> ObjectDetails {
        // Default values
        return ObjectDetails(
            magnitude: type == .star ? 1.5 : nil,
            distance: 150.0
        )
        
        // TODO: Implement actual API call based on type
    }
    
    func fetchAPOD(count: Int = 10) async throws -> APODData {
        // Get random date within last 30 days to ensure variety
        let calendar = Calendar.current
        let today = Date()
        let randomDays = Int.random(in: 0...30)
        let randomDate = calendar.date(byAdding: .day, value: -randomDays, to: today) ?? today
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: randomDate)
        
        let urlString = "\(baseUrl)/planetary/apod?api_key=\(apiKey)&date=\(dateString)"
        print("Fetching APOD for date: \(dateString)")
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        // Create URLRequest with cache policy
        var request = URLRequest(url: url)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let apod = try decoder.decode(APODData.self, from: data)
            
            // If we get a video, try another random date
            if apod.mediaType != "image" {
                if count > 0 {
                    return try await fetchAPOD(count: count - 1)
                }
            }
            
            return apod
        } catch {
            print("APOD fetch error: \(error)")
            throw error
        }
    }
}

// Add an error enum for better error handling
enum AstronomyAPIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

class AstronomyService: ObservableObject {
    // Define the API key and base URL as properties
    private let nasaApiKey = "4XsTCdb681SD2xI86jRrvvdThScvTdXnUH1wg9rA" 
    private let baseUrl = "https://api.nasa.gov"
    
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchSpaceObject(name: String) async throws -> SpaceObject {
        let urlString = "\(baseUrl)/planetary/apod?api_key=\(nasaApiKey)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        // Create mock object with correct parameter names
        return SpaceObject(
            id: UUID(),
            title: name,
            summary: "Brief overview of \(name)",  // Use summary instead of description
            detailedDescription: "Detailed information about \(name)",
            imageUrl: "https://apod.nasa.gov/apod/image/0601/orion_gendler_sm.jpg",
            mythology: "Ancient stories about \(name)",
            type: .determineType(from: name),
            magnitude: nil,
            distance: nil,
            visibility: nil,
            constellation: name
        )
    }
    
    func searchCelestialObjects(query: String) async throws -> [SpaceObject] {
        isLoading = true
        defer { isLoading = false }
        
        let wikiUrl = "https://en.wikipedia.org/api/rest_v1/page/summary/\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: wikiUrl) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let wikiResponse = try JSONDecoder().decode(WikiResponse.self, from: data)
            
            let spaceObject = SpaceObject(
                id: UUID(),
                title: wikiResponse.title,
                summary: String(wikiResponse.extract.prefix(100)) + "...",
                detailedDescription: wikiResponse.extract,
                imageUrl: wikiResponse.thumbnail?.source ?? "https://apod.nasa.gov/apod/image/0601/orion_gendler_sm.jpg",
                mythology: wikiResponse.extract,
                type: .determineType(from: wikiResponse.title),
                magnitude: nil,
                distance: nil,
                visibility: nil,
                constellation: query
            )
            
            return [spaceObject]
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    private func mockVisibilityTimes() -> SpaceObject.VisibilityTimes {
        SpaceObject.VisibilityTimes(
            rise: "05:30",
            transit: "12:45",
            set: "19:15",
            bestViewingTime: "21:00"
        )
    }
}

extension SpaceObject.CelestialType {
    static func determineType(from title: String) -> SpaceObject.CelestialType {
        let lowercased = title.lowercased()
        if lowercased.contains("constellation") {
            return .constellation
        } else if lowercased.contains("star") {
            return .star
        } else if lowercased.contains("planet") {
            return .planet
        } else if lowercased.contains("galaxy") {
            return .galaxy
        } else if lowercased.contains("nebula") {
            return .nebula
        } else if lowercased.contains("cluster") {
            return .cluster
        }
        return .constellation // default type
    }
}

// Add these structures for Wikipedia API response
struct WikiResponse: Codable {
    let title: String
    let extract: String
    let thumbnail: WikiThumbnail?
}

struct WikiThumbnail: Codable {
    let source: String
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noImageAvailable
    case decodingError(String)
    case networkError(String)  // Add this case
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noImageAvailable:
            return "No image available at this time"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

struct AstronomicalData {
    let riseTime: String
    let transitTime: String
    let setTime: String
    let bestViewingTime: String
    let magnitude: Double?
    let distance: Double?
}

// Add these structures at the bottom of AstronomyAPI.swift

struct VisibilityData {
    let riseTime: String
    let transitTime: String
    let setTime: String
    let bestViewingTime: String
}

struct ObjectDetails {
    let magnitude: Double?
    let distance: Double?
}

// API Response structures
struct AstronomyAPIResponse: Codable {
    let data: AstronomyData
}

struct AstronomyData: Codable {
    let dates: [DateData]
}

struct DateData: Codable {
    let rise: TimeData?
    let set: TimeData?
    let transit: TimeData?
}

struct TimeData: Codable {
    let time: String
}
