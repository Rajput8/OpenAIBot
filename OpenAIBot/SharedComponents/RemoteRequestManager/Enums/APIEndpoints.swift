import Foundation

enum APIEndpoints: String, Codable, CaseIterable {
    case allCountries
    
    public func urlComponent() -> String {
        switch self {
        case .allCountries: return "v3.1/all"
            
        }
    }
}
