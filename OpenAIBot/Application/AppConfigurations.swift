import Foundation

final class AppConfiguration {
    
    static var shared = AppConfiguration()
    
    enum AppEnvironments: CaseIterable {
        case local
        case qaTesting
        case betaTesting
        case development
        case production
        case unspecified
        
        var mode: String {
            switch self {
            case .local: return "Local"
            case .qaTesting: return "QATesting"
            case .betaTesting: return "BetaTesting"
            case .development: return "Development"
            case .production: return "Production"
            case .unspecified: return "Unspecified"
            }
        }
    }
    
    func fetchValueFromPlist(plist: String = "AppPrivateInfo", key: String) -> Any? {
        guard let path = Bundle.main.path(forResource: plist, ofType: "plist")
        else {
            LogHandler.reportLogOnConsole(nil, "given_info_plist_not_found".localized())
            return nil
        }
        
        guard let dict = NSDictionary(contentsOfFile: path) else { return nil }
        return dict[key]
    }
    
    fileprivate var appEnvironment: AppEnvironments {
        guard
            let details = fetchValueFromPlist(key: "App_Environment") as? NSDictionary
        else { return .unspecified }
        for (key, value) in details {
            if
                let statusFlag = value as? Bool,
                statusFlag == true {
                let env = key as? String ?? ""
                for environment in AppEnvironments.allCases where environment.mode == env {
                    return environment
                }
                return .unspecified
            }
        }
        return .unspecified
    }
    
    var baseURL: String? {
        let key = "\(appEnvironment.mode)_Base_URL"
        return fetchValueFromPlist(key: key) as? String
    }
}
