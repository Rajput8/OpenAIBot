import Foundation
import Combine

// API Constants
struct APIConstants {
    typealias Handler<T: Decodable> = (Result<T, APIFailureTypes>) -> Void
    static var deviceType = DeviceType.iOS.rawValue
    static var deviceUUID: String?
    static var authUsername = ""
    static var authPassword = ""
    static var bearerToken = ""
    static var observation: NSKeyValueObservation? // manage upload and download packet on remote server
    static var remoteRequestSession: URLSession {
        let config = URLSessionConfiguration.default
        let session = URLSession.init(configuration: config)
        return session
    }
}

// Error Constant
struct ErrorConstant {
    static var unexpectedError = "unexpected_error".localized()
}

enum DeviceType: Int {
    case iOS = 2
    case android = 1
}
