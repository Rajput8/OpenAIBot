import Foundation
import UIKit

extension String {
    
    func localized(bundle: Bundle = .main,
                   tableName: String = LocalizableFiles.generalPurpose.filename) -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
    func createAttributedString() -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        let components = self.split(separator: "**", omittingEmptySubsequences: false)
        
        for (index, part) in components.enumerated() {
            let trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
            let isBold = index % 2 == 1 // Bold if this is an odd index
            
            let textAttributes: [NSAttributedString.Key: Any]
            if isBold {
                textAttributes = [.font: UIFont.boldSystemFont(ofSize: 14)]
            } else {
                textAttributes = [.font: UIFont.systemFont(ofSize: 14)]
            }
            
            let attributedPart = NSAttributedString(string: trimmed, attributes: textAttributes)
            attributedString.append(attributedPart)
        }
        
        return attributedString
    }
}

enum LocalizableFiles {
    case generalPurpose
    var filename: String {
        switch self {
        case .generalPurpose: return "LocalizableMessage"
        }
    }
}
