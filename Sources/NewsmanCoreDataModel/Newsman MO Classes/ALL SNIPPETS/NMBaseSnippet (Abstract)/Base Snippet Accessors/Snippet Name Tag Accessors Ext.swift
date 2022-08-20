import Foundation

extension NMBaseSnippet {
 
 @NSManaged fileprivate var primitiveNameTag: String?
 @NSManaged fileprivate var primitiveSectionAlphaIndex: String?
 @NSManaged fileprivate var primitiveNormalizedSearchNameTag: String?
 
 public static let nameTagKey = "nameTag"
 public static let normalizedSearchNameTagKey = "normalizedSearchNameTag"
  /*
   the publicly exposed key for updating ASCII normalised variant
   of nameTag string for optimized predicate fetching
   using formats ... CONTAINS[n]... BEGINWITH[n]... etc.
  */
 
//MARK: Accessors for Snippet MO <.nameTag> field.
 @objc public var nameTag: String? {
  get {
   willAccessValue(forKey: Self.nameTagKey)
   let value = primitiveNameTag
   didAccessValue(forKey: Self.nameTagKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.nameTagKey)
   primitiveNameTag = newValue
   primitiveSectionAlphaIndex = String(nameTag?.prefix(1) ?? "")
   primitiveNormalizedSearchNameTag = newValue?.normalizedForSearch
   didChangeValue(forKey: Self.nameTagKey)
   
  }
 }
 
 //MARK: Silent Accessors for Snippet MO <.nameTag> field.
 @objc public var silentNameTag: String? {
  get { primitiveNameTag }
  set {
   primitiveNameTag = newValue
   primitiveSectionAlphaIndex = String(nameTag?.prefix(1) ?? "")
   primitiveNormalizedSearchNameTag = newValue?.normalizedForSearch
  }
 }
 
}
