import Foundation

class Properties {
    
    static let properties = Properties()
    
    let properties: NSDictionary
    
    init() {
        
        let propertiesPath = NSBundle.mainBundle().pathForResource("Properties", ofType: "plist")!
        properties = NSDictionary(contentsOfFile: propertiesPath)!
    }
}