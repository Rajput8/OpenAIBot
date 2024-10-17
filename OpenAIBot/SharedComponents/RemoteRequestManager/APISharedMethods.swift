import Foundation

class APISharedMethods {
    
    static var shared = APISharedMethods()
    
    func basicAuth(_ userName: String, _ password: String) -> String {
        let credentialString = "\(userName):\(password)"
        guard let credentialData = credentialString.data(using: String.Encoding.utf8)
        else { return "" }
        let base64Credentials = credentialData.base64EncodedString(options: [])
        return base64Credentials
    }
    
    func convertStringAnyDictToStringDict(_ dict: [String: Any]) -> [String: String] {
        var newDict = [String: String]()
        for (key, value) in dict { newDict[key] = "\(value)" }
        return newDict
    }
    
    func convertModelToData<T: Codable>(_ value: T) -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(value)
            return jsonData
        } catch {
            LogHandler.reportLogOnConsole(
                nil,
                "unable_to_generate_data_from_model".localized()
            )
        }
        return nil
    }
}
