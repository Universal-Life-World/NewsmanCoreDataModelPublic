
import Foundation

extension NMBaseSnippet {
  
 @NSManaged fileprivate var primitiveSectionDateIndex: String
 public static let sectionDateIndexKey = "sectionDateIndex"
 
//MARK: Accessors for Snippet Date Group Index
 
 public internal (set) var sectionDateIndexGroup: DateGroup {
  get {
   willAccessValue(forKey: Self.sectionDateIndexKey)
   guard let enumValue = DateGroup(rawValue: primitiveSectionDateIndex) else {
    fatalError("Invalid Snippet Creation Date Group Primitive value - [\(primitiveSectionDateIndex)]")
   }
   didAccessValue(forKey: Self.sectionDateIndexKey)
   return enumValue
  }
  
  set {
   willChangeValue(forKey: Self.sectionDateIndexKey)
   primitiveSectionDateIndex = newValue.rawValue
   didChangeValue(forKey: Self.sectionDateIndexKey)
   
  }
 }
 

 //MARK: Silent Accessors for Snippet Date Group Index
 public internal (set) var silentSectionDateIndexGroup: DateGroup {
  get {
   guard let enumValue = DateGroup(rawValue: primitiveSectionDateIndex) else {
    fatalError("Invalid Snippet Creation Date Group Primitive value - [\(primitiveSectionDateIndex)]")
   }
   return enumValue
  }
  set { primitiveSectionDateIndex = newValue.rawValue }
 }
 
 func updateDateGroupAfterFetch(){
  
  guard let dateCreated = date else { fatalError("Snippet Creation Date MUST NOT BE NIL!") }
  
  let fetchDate = Date()
  let newSectionDateIndex = DateGroup.current(of: dateCreated, at: fetchDate).rawValue
  if primitiveSectionDateIndex != newSectionDateIndex {
   primitiveSectionDateIndex = newSectionDateIndex
  }
 }
 
 
}
