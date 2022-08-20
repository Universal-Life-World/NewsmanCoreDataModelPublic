
import Foundation

extension NMBaseSnippet {
 
 @NSManaged fileprivate var primitivePriority: String
 public static let priorityKey = "priority"
  
 //MARK: Accessors for Snippet MO <.priority> field.
 public var priority: SnippetPriority {
  get {
   willAccessValue(forKey: Self.priorityKey)
   guard let value = SnippetPriority(rawValue: primitivePriority) else {
    fatalError("Invalid Snippet Priority Primitive Property Value - [\(primitivePriority)]")
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
 
//MARK: Silent Accessors for Snippet MO <.priority> field.
 public var silentPriority: SnippetPriority {
  get {
   guard let value = SnippetPriority(rawValue: primitivePriority) else {
    fatalError("Invalid Snippet Priority Primitive Property Value - [\(primitivePriority)]")
   }
   return value
  }
  
  set { primitivePriority = newValue.rawValue }
 }
 
}
