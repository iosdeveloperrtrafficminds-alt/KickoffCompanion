//
//  AIService.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import Foundation

struct AIChant: Codable, Identifiable {
    let id = UUID()
    var title: String
    var chant: String
}

final class GeminiService {
    private let apiKey = "AIzaSyDeKZRT21892LO6NjoSWdWgq3OfXeiOG1c"
    private let modelName = "gemini-1.5-flash"
    private lazy var apiURL: URL? = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "generativelanguage.googleapis.com"
        components.path = "/v1beta/models/\(modelName):generateContent"
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        return components.url
    }()

    enum GeminiError: Error, LocalizedError {
        case invalidURL, requestEncodingFailed, networkError(Error)
        case apiError(String), decodingError(Error), noContentGenerated
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "The API URL is invalid."
            case .requestEncodingFailed: return "Failed to encode the request."
            case .networkError: return "A network error occurred. Please check your connection."
            case .apiError(let message): return "The AI service returned an error: \(message)"
            case .decodingError: return "Failed to understand the AI's response. Please try again."
            case .noContentGenerated: return "The AI could not generate a chant for this topic. Please try again."
            }
        }
    }
    
    func generateChant(topic: String) async -> Result<AIChant, GeminiError> {
        guard let url = apiURL else { return .failure(.invalidURL) }
        
        let prompt = createPrompt(topic: topic)
        let requestPayload = GeminiAPIRequest(contents: [Content(parts: [Part(text: prompt)])])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do { request.httpBody = try JSONEncoder().encode(requestPayload) } catch { return .failure(.requestEncodingFailed) }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.apiError("HTTP Status \((response as? HTTPURLResponse)?.statusCode ?? 0)"))
            }
            
            let geminiResponse = try JSONDecoder().decode(GeminiAPIResponse.self, from: data)
            guard let textContent = geminiResponse.candidates?.first?.content.parts.first?.text else {
                return .failure(.noContentGenerated)
            }

            return parseChant(from: textContent, topic: topic)
            
        } catch let error as DecodingError { return .failure(.decodingError(error)) }
          catch { return .failure(.networkError(error)) }
    }
    
    private func createPrompt(topic: String) -> String {
        return """
        You are a creative expert in writing short, powerful, and catchy football (soccer) chants. Your ONLY task is to generate one chant based on the provided topic.

        **Topic:** "\(topic)"

        **Instructions:**
        1.  Create one chant, typically 4-6 lines long.
        2.  The chant must be energetic, rhythmic, and easy to shout.
        3.  Strictly focus on the provided topic. Do not write about anything else.

        **Output Format:**
        Your response MUST be a single, valid JSON object. Do not include any text, explanations, or markdown formatting. Your entire response must be the raw JSON object itself.

        The JSON structure MUST be as follows:
        {
          "chant": "string (the full chant, use \\n for new lines)"
        }
        """
    }
    
    private func parseChant(from jsonString: String, topic: String) -> Result<AIChant, GeminiError> {
        let cleanedString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "")
        guard let data = cleanedString.data(using: .utf8) else { return .failure(.decodingError(NSError())) }
        
        do {
            let decodedResponse = try JSONDecoder().decode(ChantResponse.self, from: data)
            let chant = AIChant(title: topic, chant: decodedResponse.chant)
            return .success(chant)
        } catch {
            return .failure(.decodingError(error))
        }
    }
}

private extension GeminiService {
    struct ChantResponse: Decodable { let chant: String }
    struct GeminiAPIRequest: Encodable { let contents: [Content] }
    struct Content: Encodable { let parts: [Part] }
    struct Part: Encodable { let text: String }
    struct GeminiAPIResponse: Decodable { let candidates: [Candidate]? }
    struct Candidate: Decodable { let content: ResponseContent }
    struct ResponseContent: Decodable { let parts: [ResponsePart] }
    struct ResponsePart: Decodable { let text: String? }
}
