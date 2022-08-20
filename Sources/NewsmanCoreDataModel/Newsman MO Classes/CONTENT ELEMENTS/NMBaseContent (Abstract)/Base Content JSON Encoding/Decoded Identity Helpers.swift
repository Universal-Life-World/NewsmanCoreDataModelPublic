
import Foundation

infix operator <=> : ComparisonPrecedence // strong equivalence with relationship
infix operator <-> : ComparisonPrecedence // base equivalence without relationship (only scalar fields)

extension NMBaseContent {
 
 public enum IdentityKeys: String, CaseIterable {
  
  case  id, tag, date, latitude, location, longitude, positions, priority, type,
        archivedTimeStamp, arrowMenuPosition, arrowMenuScaleFactor,
        arrowMenuTouchPoint, ck_metadata, colorFlag,  hiddenSectionsBitset,
        isArrowMenuShowing, isCopyable, isDeletable,
        isDragAnimating, isDraggable, isFolderable, isHiddenFromSection,
        isRateable, isSelectable, isSelected, isTrashable,
        /*lastAccessedTimeStamp, lastModifiedTimeStamp, */
        lastRatedTimeStamp, publishedTimeStamp, ratedCount, rating, trashedTimeStamp
  
 }
 
 public static func <=> (o1: NMBaseContent, o2: NMBaseContent) -> Bool {
  o1.isIdentical(to: o2, using: IdentityKeys.allCases)
 }
 
 public static func <-> (o1: NMBaseContent, o2: NMBaseContent) -> Bool {
  o1.isBaseIdentical(to: o2, using: IdentityKeys.allCases)
 }
 
  // base equivalence without relationship (only scalar fields)
 public func isBaseIdentical<Key>(to object: NMBaseContent, using keys: [Key]) -> Bool
 where Key: RawRepresentable, Key.RawValue == String {
  let rawKeys = keys.map { $0.rawValue }
  let thisObject = NSDictionary(dictionary: dictionaryWithValues(forKeys: rawKeys))
  let toObject = NSDictionary(dictionary: object.dictionaryWithValues(forKeys: rawKeys))
  
  return thisObject == toObject
 }
 
  // strong equivalence with child relationship but without parent
 public func isIdentical<Key>(to object: NMBaseContent, using keys: [Key]) -> Bool
 where Key: RawRepresentable, Key.RawValue == String {
  
  guard isBaseIdentical(to: object, using: keys) else { return false }
  
  switch (self, object) {
   case let (f1 as NMPhotoFolder, f2 as NMPhotoFolder):
    guard f1.folderedElements.count == f2.folderedElements.count  else { return false }
    return f1.folderedElements.allSatisfy{ e1 in f2.folderedElements.contains{ $0 <=> e1 } }
    
   case let (f1 as NMAudioFolder, f2 as NMAudioFolder):
    guard f1.folderedElements.count == f2.folderedElements.count  else { return false }
    return f1.folderedElements.allSatisfy{ e1 in f2.folderedElements.contains{ $0 <=> e1 } }
    
   case let (f1 as NMVideoFolder, f2 as NMVideoFolder):
    guard f1.folderedElements.count == f2.folderedElements.count  else { return false }
    return f1.folderedElements.allSatisfy{ e1 in f2.folderedElements.contains{ $0 <=> e1 } }
    
   case let (f1 as NMTextFolder,  f2 as NMTextFolder):
    guard f1.folderedElements.count == f2.folderedElements.count  else { return false }
    return f1.folderedElements.allSatisfy{ e1 in f2.folderedElements.contains{ $0 <=> e1 } }
    
   case let (f1 as NMMixedFolder, f2 as NMMixedFolder):
    guard f1.folderedElements.count == f2.folderedElements.count  else { return false }
    return f1.folderedElements.allSatisfy{ e1 in f2.folderedElements.contains{ $0 <=> e1 } }
    
   default: break
  }
  
  return true
 }
 
}
