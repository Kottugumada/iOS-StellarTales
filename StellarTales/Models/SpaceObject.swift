import Foundation

struct SpaceObject: Identifiable {
    let id: UUID
    let title: String
    let summary: String
    var detailedDescription: String
    let imageUrl: String
    var mythology: String
    
    // Astronomical Data
    let type: CelestialType
    let magnitude: Double?
    let distance: Double?
    let visibility: VisibilityTimes?
    let constellation: String?
    
    struct Distance: Codable {
        let lightYears: Double?
        let parsecs: Double?
    }
    
    struct VisibilityTimes: Codable {
        let rise: String
        let transit: String
        let set: String
        let bestViewingTime: String
    }
    
    enum CelestialType: String, Codable {
        case star, constellation, planet, galaxy, nebula, cluster
    }
    
    init(id: UUID = UUID(), title: String, summary: String, detailedDescription: String, imageUrl: String, mythology: String, type: CelestialType, magnitude: Double? = nil, distance: Double? = nil, visibility: VisibilityTimes? = nil, constellation: String? = nil) {
        self.id = id
        self.title = title
        self.summary = summary
        self.detailedDescription = detailedDescription
        self.imageUrl = imageUrl
        self.mythology = mythology
        self.type = type
        self.magnitude = magnitude
        self.distance = distance
        self.visibility = visibility
        self.constellation = constellation
    }
    
    mutating func fetchMythology() async {
        do {
            let geminiMythology = try await GeminiService.shared.fetchContent(
                for: title,
                type: .mythology
            )
            self.mythology = geminiMythology
        } catch {
            self.mythology = "Unable to fetch mythology at this time."
        }
    }
    
    mutating func fetchDetailedDescription() async {
        do {
            let scientificDetails = try await GeminiService.shared.fetchContent(
                for: title,
                type: .scientific
            )
            self.detailedDescription = scientificDetails
        } catch {
            self.detailedDescription = "Unable to fetch scientific details at this time."
        }
    }
} 
