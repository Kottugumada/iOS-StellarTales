import Foundation

struct SpaceObject: Codable, Identifiable {
    let id: UUID
    let title: String
    let summary: String
    let detailedDescription: String
    let imageUrl: String
    let mythology: String
    
    // Astronomical Data
    let type: CelestialType
    let magnitude: Double?
    let distance: Distance?
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
    
    init(id: UUID = UUID(), title: String, summary: String, detailedDescription: String, imageUrl: String, mythology: String, type: CelestialType, magnitude: Double? = nil, distance: Distance? = nil, visibility: VisibilityTimes? = nil, constellation: String? = nil) {
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
} 
