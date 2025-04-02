import Foundation

class GeminiService {
    static let shared = GeminiService()
    
    private let apiKey = AppSecrets.geminiKey
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    enum ContentType {
        case mythology
        case scientific
        case observationTips
        case astronomicalData
        
        var prompt: (String) -> String {
            switch self {
            case .mythology:
                return { objectName in
                    """
                    Tell me about the mythology and historical significance of \(objectName) in astronomy. 
                    Include both ancient cultural stories and early astronomical observations. 
                    Keep the response concise but informative, around 150 words.
                    Format in simple text without special characters.
                    """
                }
            case .scientific:
                return { objectName in
                    """
                    Provide detailed scientific information about \(objectName) including:
                    - Physical characteristics
                    - Composition
                    - Notable features
                    - Recent discoveries
                    Keep it concise but technical, around 150 words.
                    Format in simple text without special characters.
                    """
                }
            case .observationTips:
                return { objectName in
                    """
                    Provide practical observation tips for viewing \(objectName):
                    - Best equipment to use
                    - Optimal viewing conditions
                    - What features to look for
                    - Common challenges and solutions
                    Keep it practical and specific, around 150 words.
                    Format in simple text without special characters.
                    """
                }
            case .astronomicalData:
                return { objectName in
                    """
                    Provide specific astronomical data for \(objectName):
                    - Distance from Earth (in light years or AU)
                    - Apparent magnitude
                    - Absolute magnitude
                    - Constellation location
                    - Right ascension and declination
                    - Physical characteristics (size, mass, temperature)
                    Format as short, precise measurements without explanatory text.
                    Use numerical values where possible.
                    """
                }
            }
        }
    }
    
    func fetchContent(for objectName: String, type: ContentType) async throws -> String {
        print("🔍 Starting \(type) fetch for: \(objectName)")
        
        let prompt = type.prompt(objectName)
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ Failed to serialize request body")
            throw GeminiError.invalidRequest
        }
        
        let urlString = "\(baseURL)?key=\(apiKey)"
        print("🌐 Attempting to call URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL formed")
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Response is not HTTPURLResponse")
                throw GeminiError.invalidResponse
            }
            
            print("📡 Response status code: \(httpResponse.statusCode)")
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📝 Raw response: \(responseString)")
            }
            
            guard httpResponse.statusCode == 200 else {
                print("❌ Bad status code: \(httpResponse.statusCode)")
                throw GeminiError.invalidResponse
            }
            
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            let extractedText = extractText(from: geminiResponse)
            print("✅ Successfully extracted text: \(extractedText.prefix(50))...")
            return extractedText
            
        } catch {
            print("❌ Network or decoding error: \(error)")
            throw error
        }
    }
    
    private func extractText(from response: GeminiResponse) -> String {
        guard let text = response.candidates.first?.content.parts.first?.text else {
            print("⚠️ No text found in response")
            return "No information available"
        }
        return text
    }
}

// Response models
struct GeminiResponse: Codable {
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let content: Content
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}

enum GeminiError: LocalizedError {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidRequest:
            return "Invalid request"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        }
    }
} 