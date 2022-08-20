
import Foundation

extension NMBaseSnippet {
 
 @NSManaged fileprivate var primitiveStatus: String
 public static let statusKey = "status"
 
 
 //MARK: Accessors for Snippet MO <.status> field.
 public internal (set) var status: SnippetStatus {
  get {
   willAccessValue(forKey: Self.statusKey)
   guard let value = SnippetStatus(rawValue: primitiveStatus) else {
    fatalError("Invalid Snippet Status Primitive Value - [\(primitiveStatus)]")
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
 
 //MARK: Silent Accessors for Snippet MO <.status> field.
 public internal (set) var silentStatus: SnippetStatus {
  get {
   guard let value = SnippetStatus(rawValue: primitiveStatus) else {
    fatalError("Invalid Snippet Status Primitive Value - [\(primitiveStatus)]")
   }
   return value
  }
  
  set { primitiveStatus = newValue.rawValue }
 }
 
 
}
