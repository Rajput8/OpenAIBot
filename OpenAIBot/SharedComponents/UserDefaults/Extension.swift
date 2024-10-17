import UIKit

extension UserDefaults {
    
    subscript<V: Codable>(key: StoredKeys<V>) -> V? {
        get {
            guard let data = self.data(forKey: key.name) else { return nil }
            return try? JSONDecoder().decode(V.self, from: data)
        }
        set {
            guard let value = newValue,
                  let data = try? JSONEncoder().encode(value)
            else {
                self.set(nil, forKey: key.name)
                return
            }
            self.set(data, forKey: key.name)
        }
    }
    
    subscript(key: StoredKeys<URL>) -> URL? {
        get {
            return self.url(forKey: key.name)
        }
        
        set {
            self.set(newValue, forKey: key.name)
        }
    }
    
    subscript(key: StoredKeys<String>) -> String? {
        get {
            return self.string(forKey: key.name)
        }
        
        set {
            self.set(newValue, forKey: key.name)
        }
    }
    
    subscript(key: StoredKeys<Data>) -> Data? {
        get {
            return self.data(forKey: key.name)
        }
        
        set {
            self.set(newValue, forKey: key.name)
        }
    }
    
    subscript(key: StoredKeys<Bool>) -> Bool {
        get {
            return self.bool(forKey: key.name)
        }
        
        set {
            self.set(newValue, forKey: key.name)
        }
    }
    
    subscript(key: StoredKeys<Int>) -> Int {
        get {
            return self.integer(forKey: key.name)
        }
        
        set {
            self.set(newValue, forKey: key.name)
        }
    }
    
    subscript(key: StoredKeys<Float>) -> Float {
        get {
            return self.float(forKey: key.name)
        }
        
        set {
            self.set(newValue, forKey: key.name)
        }
    }
    
    subscript(key: StoredKeys<Double>) -> Double {
        get {
            return self.double(forKey: key.name)
        }
        
        set {
            self.set(newValue, forKey: key.name)
        }
    }
    
    func resetUserDefaults() {
        let dictionary = self.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            self.removeObject(forKey: key)
        }
    }
    
    func deleteData(key: Keyname) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        // self.removeObject(forKey: key.rawValue)
    }
}
