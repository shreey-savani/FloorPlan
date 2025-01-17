import Foundation
import CoreGraphics
import UIKit

/// Represents the structure of a saved scene
struct SceneData: Codable {
    struct ObjectData: Codable {
        let id: String         // Unique identifier for the object
        let type: String       // Type of object (e.g., wall, door)
        let position: CGPoint  // Position in the scene
        let size: CGSize       // Size of the object
        let color: String      // Color in hex format
    }
    
    let objects: [ObjectData]
}

/// Utility to convert UIColor to Hex string
extension UIColor {
    var hexString: String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02lX%02lX%02lX", lround(Double(red * 255)), lround(Double(green * 255)), lround(Double(blue * 255)))
    }
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
