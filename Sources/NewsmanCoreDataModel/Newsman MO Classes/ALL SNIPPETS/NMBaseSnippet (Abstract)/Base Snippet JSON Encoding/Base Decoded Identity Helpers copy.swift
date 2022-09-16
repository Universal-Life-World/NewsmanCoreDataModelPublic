
import Foundation

infix operator <=> : ComparisonPrecedence // strong equivalence with relationship
infix operator <-> : ComparisonPrecedence // base equivalence without relationship (only scalar fields)

extension NMBaseSnippet {
 
 public enum IdentityKeys: String, CaseIterable {
  
  case  id, status, type, nameTag, date, about, priority,
        archivedTimeStamp, ck_metadata, hiddenSectionsBitset,
        latitude, location, longitude /*,geoLocation2D is not exposable in objC for KVC*/,
        contentElementsGroupingType, contentElementsSortingType, contentElementsSortOrder,
        isDeletable, isDragAnimating, isDraggable, isHiddenFromSection, isHideableFromSection,
        isSelected, contentElementsInRow, dateSearchFormatIndex, isTrashable,
        /*lastAccessedTimeStamp, lastModifiedTimeStamp,*/ trashedTimeStamp, publishedTimeStamp,
        isContentCopyable, isContentEditable, isContentPublishable, isContentSharable, isMergeable,
        isShowingSnippetDetailedCell, sectionAlphaIndex, sectionPriorityIndex, sectionTypeIndex,
        showsContentElementsPositions, showsHiddenContentElements
  
 }
 
 public static func <=> (o1: NMBaseSnippet, o2: NMBaseSnippet) -> Bool {
  o1.isIdentical(to: o2, using: IdentityKeys.allCases)
 }
 
 public static func <-> (o1: NMBaseSnippet, o2: NMBaseSnippet) -> Bool {
  o1.isBaseIdentical(to: o2, using: IdentityKeys.allCases)
 }
 
  // base equivalence without relationship (only scalar fields)
 public func isBaseIdentical<Key>(to object: NMBaseSnippet, using keys: [Key]) -> Bool
 where Key: RawRepresentable, Key.RawValue == String {
  let rawKeys = keys.map { $0.rawValue }
  let thisObject = NSDictionary(dictionary: dictionaryWithValues(forKeys: rawKeys))
  let toObject = NSDictionary(dictionary: object.dictionaryWithValues(forKeys: rawKeys))
  
//  print ("THIS OBJECT")
//  thisObject.forEach {
//   print ("key:\($0.key) value: \($0.value)")
//  }
//
//  print ("OTHER OBJECT")
//  toObject.forEach {
//   print ("key:\($0.key) value: \($0.value)")
//  }
  return thisObject == toObject
 }
 
  // strong equivalence with child relationship but without parent
 public func isIdentical<Key>(to object: NMBaseSnippet, using keys: [Key]) -> Bool
  where Key: RawRepresentable, Key.RawValue == String {
  
  guard isBaseIdentical(to: object, using: keys) else { return false }
  
  switch (self, object) {
   case let (s1 as NMPhotoSnippet, s2 as NMPhotoSnippet):
    guard s1.folders.count == s2.folders.count  else { return false }
    guard s1.singleContentElements.count == s2.singleContentElements.count  else { return false }
    guard (s1.folders.allSatisfy{ e1 in s2.folders.contains{ $0 <=> e1 } }) else { return false }
    return s1.singleContentElements.allSatisfy{ e1 in s2.singleContentElements.contains{ $0 <=> e1 } }
    
   case let (s1 as NMAudioSnippet, s2 as NMAudioSnippet):
    guard s1.folders.count == s2.folders.count  else { return false }
    guard s1.singleContentElements.count == s2.singleContentElements.count  else { return false }
    guard (s1.folders.allSatisfy{ e1 in s2.folders.contains{ $0 <=> e1 } }) else { return false }
    return s1.singleContentElements.allSatisfy{ e1 in s2.singleContentElements.contains{ $0 <=> e1 } }
    
   case let (s1 as NMVideoSnippet, s2 as NMVideoSnippet):
    guard s1.folders.count == s2.folders.count  else { return false }
    guard s1.singleContentElements.count == s2.singleContentElements.count  else { return false }
    guard (s1.folders.allSatisfy{ e1 in s2.folders.contains{ $0 <=> e1 } }) else { return false }
    return s1.singleContentElements.allSatisfy{ e1 in s2.singleContentElements.contains{ $0 <=> e1 } }
    
   case let (s1 as NMTextSnippet,  s2 as NMTextSnippet):
    guard s1.folders.count == s2.folders.count  else { return false }
    guard s1.singleContentElements.count == s2.singleContentElements.count  else { return false }
    guard (s1.folders.allSatisfy{ e1 in s2.folders.contains{ $0 <=> e1 } }) else { return false }
    return s1.singleContentElements.allSatisfy{ e1 in s2.singleContentElements.contains{ $0 <=> e1 } }
    
   case let (s1 as NMMixedSnippet, s2 as NMMixedSnippet):
    guard s1.folders.count == s2.folders.count  else { return false }
    guard s1.singleContentElements.count == s2.singleContentElements.count  else { return false }
    guard (s1.folders.allSatisfy{ e1 in s2.folders.contains{ $0 <=> e1 } }) else { return false }
    return s1.singleContentElements.allSatisfy{ e1 in s2.singleContentElements.contains{ $0 <=> e1 } }
    
   default: return false
  }
  

 }
 
}
