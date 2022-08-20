
import Foundation

extension NMBaseSnippet {
 @NSManaged fileprivate var primitiveAbout: String?
 @NSManaged fileprivate var primitiveNormalizedSearchAbout: String?
 
 public static let aboutKey = "about"
 public static let normalizedSearchAboutKey = "normalizedSearchAbout"
/*
 the publicly exposed key for updating ASCII normalised variant
 of nameTag string for optimized predicate fetching using formats
 ... CONTAINS[n]... BEGINWITH[n]... etc.
*/
 
//MARK: Accessors for Snippet MO <.about> field.
 @objc public var about: String? {
  get {
   willAccessValue(forKey: Self.aboutKey)
   let value = primitiveAbout
   didAccessValue(forKey: Self.aboutKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.aboutKey)
   primitiveAbout = newValue
   primitiveNormalizedSearchAbout = newValue?.normalizedForSearch
   didChangeValue(forKey: Self.aboutKey)
   
  }
 }
 
 //MARK: Silent Accessors for Snippet MO <.about> field.
 @objc public var silentAbout: String? {
  get { primitiveAbout }
  set {
   primitiveAbout = newValue
   primitiveNormalizedSearchAbout = newValue?.normalizedForSearch
  }
 }
 
 

}
