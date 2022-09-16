
import Foundation

infix operator <=> : ComparisonPrecedence // strong equivalence with relationship
infix operator <-> : ComparisonPrecedence // base equivalence without relationship (only scalar fields)

extension NMBaseContent {
 
// @available(iOS 15.0, macOS 12.0, *)
// public var asyncDTO: DTO {
//  get async throws {
//
//   guard let context = self.managedObjectContext else {
//    throw ContextError.noContext(object: self, entity: .baseContent, operation: .gettingObjectDTO)
//   }
//
//   return await context.perform { self.dto }
//  } //get async throws...
// }
 
// public struct DTO: Equatable {
//  let fields: NSDictionary
//  let children: Set<NSDictionary>?
//
//  public subscript (key: IdentityKeys) -> Any? { fields[key.rawValue] }
//  public subscript (ID: UUID, key: IdentityKeys) -> Any? {
//   children?.first{$0.contains{$0.key as? String == IdentityKeys.id.rawValue &&
//                               $0.value as? UUID == ID}}?[key.rawValue]
//  }
// }
 
// public var dto: DTO {
//  
//  let fields = NSDictionary(dictionary: dictionaryWithValues(forKeys: IdentityKeys.allCases.map{$0.rawValue}))
//  switch self {
//   case let folder as NMPhotoFolder:
//    let children = Set(folder.folderedElements.map{$0.dto.fields})
//    return .init(fields: fields, children: children)
//   case let folder as NMAudioFolder:
//    let children = Set(folder.folderedElements.map{$0.dto.fields})
//    return .init(fields: fields, children: children)
//   case let folder as NMTextFolder:
//    let children = Set(folder.folderedElements.map{$0.dto.fields})
//    return .init(fields: fields, children: children)
//   case let folder as NMVideoFolder:
//    let children = Set(folder.folderedElements.map{$0.dto.fields})
//    return .init(fields: fields, children: children)
//   case let folder as NMMixedFolder:
//    let children = Set(folder.folderedElements.map{$0.dto.fields})
//    return .init(fields: fields, children: children)
//   default:
//    return .init(fields: fields, children: nil)
//  }
// }
 
 public enum IdentityKeys: String, CaseIterable {
  
  case  id, tag, date, location, 
        latitude, longitude, /*, geoLocation2D is not exposable in objC for KVC*/
        positions, priority, type,
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
    
   default:  return false
  }
  
 
 }
 
}
