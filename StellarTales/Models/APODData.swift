import Foundation

// Single source of truth for APODData
struct APODData: Codable {
    let copyright: String?
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: String?
    let serviceVersion: String
    let title: String
    let url: String
} 