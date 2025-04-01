import Foundation

// Make sure we're in the same module as SpaceObject
struct AstronomyAPI {
    // NASA API key should be stored securely
    private let apiKey = "4XsTCdb681SD2xI86jRrvvdThScvTdXnUH1wg9rA"
    private let baseUrl = "https://api.nasa.gov"
    
    func fetchSpaceObject(name: String) async throws -> SpaceObject {
        let urlString = "\(baseUrl)/planetary/apod?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        
        // Create a mock object for now
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
}

// Add an error enum for better error handling
enum AstronomyAPIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

class AstronomyService: ObservableObject {
    // Define the API key and base URL as properties
    private let nasaApiKey = "4XsTCdb681SD2xI86jRrvvdThScvTdXnUH1wg9rA" // Replace with your actual NASA API key
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
    case serverError(Int)
    case networkError(String)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .noData:
            return "No data received"
        }
    }
}
