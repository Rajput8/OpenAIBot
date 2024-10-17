import Foundation

struct StoredKeys<Value> {
    
    let name: String
    
    init(_ name: Keyname) {
        self.name = name.rawValue
    }
    
    static var bearerToken: StoredKeys<String> {
        return StoredKeys<String>(Keyname.bearerToken)
    }
}
