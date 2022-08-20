
import Foundation

extension NMBaseContent {
 
 //MARK: Accessors for Content Element <.status> field.
 @NSManaged fileprivate var primitiveStatus: String
 
 public static let statusKey = "status"
 public var status: ContentStatus {
  get {
   willAccessValue(forKey: Self.statusKey)
   guard let value = ContentStatus(rawValue: primitiveStatus) else {
    fatalError("Invalid Content Element Status Primitive Value - [\(primitiveStatus)]")
   }
   didAccessValue(forKey: Self.statusKey)
   return value
  }
  
  set {
   
   willChangeValue(forKey: Self.statusKey)
   primitiveStatus = newValue.rawValue
   didChangeValue(forKey: Self.statusKey)
   
  }
 }
 
 //MARK: Silent Accessors for Content Element <.status> field.
 public var silentStatus: ContentStatus {
  get {
   guard let value = ContentStatus(rawValue: primitiveStatus) else {
    fatalError("Invalid Content Element Status Primitive Value - [\(primitiveStatus)]")
   }
   return value
  }
  
  set { primitiveStatus = newValue.rawValue }
 }
}
