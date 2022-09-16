
import Foundation

extension NMBaseContent {
 
//MARK: Accessors for Content Element <.tag> field.
 @NSManaged fileprivate var primitiveTag: String?
 @NSManaged fileprivate var primitiveNormalizedSearchTag: String?
 
 public static let tagKey = "tag"
 public static let normalizedSearchTagKey = "normalizedSearchTag"
 /*
  the publicly exposed key for updating ASCII normalised
  variant of nameTag string for optimized predicatefetching using formats
  ... CONTAINS[n]... BEGINWITH[n]... etc.
 */
 
 @objc public var tag: String? {
  get {
   willAccessValue(forKey: Self.tagKey)
   let value = primitiveTag
   didAccessValue(forKey: Self.tagKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.tagKey)
   primitiveTag = newValue
   didChangeValue(forKey: Self.tagKey)
   
   willChangeValue(forKey: Self.normalizedSearchTagKey)
   primitiveNormalizedSearchTag = newValue?.normalizedForSearch
   didChangeValue(forKey: Self.normalizedSearchTagKey)
   
  }
 }
 
 //MARK: Silent Accessors for Content Element <.tag> field.
 public var silentTag: String? {
  get { primitiveTag }
  set {
   primitiveTag = newValue
   primitiveNormalizedSearchTag = newValue?.normalizedForSearch
  }
 }
}
