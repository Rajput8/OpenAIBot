import Foundation

enum APIFailureTypes: Error, Equatable {
    case manuallyOffline
    case connectivityError
    case httpError
    case authentication
    case serverError
    case encoding
    case parsingError
    case invalidRequest
    case invalidResponse
    case invalidURL
    case nullData
    case invalidData
    case unAuthorizedUser
    case errorMessageWithError(_ error: Error?, _ errorDesc: String?)
    case errorMessage(_ errorDesc: String)
    case networkError(Error)
    case requestFailed(Error)
    case unknownError(Error)
    // Custom error type to handle specific errors related to API fetch
    case usersFetchError(Error)
    case commentsFetchError(Error)
    
    static func == (lhs: APIFailureTypes, rhs: APIFailureTypes) -> Bool {
        return true
    }

    static func requestErrorMsg(_ error: APIFailureTypes) -> String {
        switch error {
        case .errorMessageWithError(_, let errDesc): return errDesc ?? ""
        case .errorMessage(let errDesc): return errDesc
        default: return ""
        }
    }
}
