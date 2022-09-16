import Foundation

extension NMBaseSnippet {
 
 @NSManaged fileprivate var primitiveContentElementsGroupingType: String
 public static let contentElementsGroupingTypeKey = "contentElementsGroupingType"
 public typealias ContentGroupType = NMBaseContent.ContentGroupTypeAny
 
  //MARK: Accessors for Snippet MO <.contentElementsGroupingType> field.
 
 public var contentElementsGroupingType: ContentGroupType {
  get {
   willAccessValue(forKey: Self.contentElementsGroupingTypeKey)
   let value = ContentGroupType(from: primitiveContentElementsGroupingType)
   didAccessValue(forKey: Self.contentElementsGroupingTypeKey)
   return value
  }
  
  set {
   willChangeValue(forKey: Self.statusKey)
   primitiveContentElementsGroupingType = newValue.rawString
   didChangeValue(forKey: Self.statusKey)
   
  }
 }
 
 //MARK: Silent Accessors for Snippet MO <contentElementsGroupingType> field.
 
 public internal (set) var silentContentElementsGroupingType: ContentGroupType {
  get { .init(from: primitiveContentElementsGroupingType) }
  set { primitiveContentElementsGroupingType = newValue.rawString }
 }
 
 
}
