
import Foundation

extension NMBaseContent {
 
 //MARK: Accessors for Content Element MO <.priority> field.
 @NSManaged fileprivate var primitivePriority: String
 public static let priorityKey = "priority"
 public var priority: ContentPriority {
  get {
   willAccessValue(forKey: Self.priorityKey)
   guard let value = ContentPriority(rawValue: primitivePriority) else {
    fatalError("Invalid Content Element Priority Primitive Property Value - [\(primitivePriority)]")
   }
   didAccessValue(forKey: Self.priorityKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.priorityKey)
   primitivePriority = newValue.rawValue
   didChangeValue(forKey: Self.priorityKey)
   
  }
 }
 
 
 //MARK: Silent Accessors for Content Element MO <.priority> field.
 public var silentPriority: ContentPriority {
  get {
   guard let value = ContentPriority(rawValue: primitivePriority) else {
    fatalError("Invalid Content Element Priority Primitive Property Value - [\(primitivePriority)]")
   }
   return value
  }
  
  set { primitivePriority = newValue.rawValue }
 }
 
}
