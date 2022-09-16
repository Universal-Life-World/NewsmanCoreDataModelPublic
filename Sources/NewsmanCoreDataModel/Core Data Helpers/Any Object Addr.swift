
import Foundation
public extension NSObject {
 
 var address: String { "\(Unmanaged.passUnretained(self).toOpaque())" }
 
}
