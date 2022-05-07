import Foundation
import CoreData

public enum NMSortOrder<Root, Value> where Root: NSManagedObject {
 public typealias SortKeyPath = KeyPath<Root, Value>
 case ascending(keyPath: SortKeyPath)
 case descending(keyPath: SortKeyPath)
 
 public var sortDescriptor: NSSortDescriptor{
  switch self {
   case let .ascending(keyPath: path):  return .init(keyPath: path, ascending: true)
   case let .descending(keyPath: path): return .init(keyPath: path, ascending: false)
  }
  
 }
}

public enum NMPredicateOperation {
 case and
 case or
 case xor
 case not
 
 public func predicate(subpredicate: NSPredicate) -> NSPredicate {
  switch self {
   case .not: return NSCompoundPredicate(notPredicateWithSubpredicate: subpredicate)
   default:   return subpredicate
  }
 }
 
 public func predicate(subpredicates: [NSPredicate]) -> NSPredicate {
  
  if subpredicates.isEmpty { return .never }
  
  switch self {
   case .and: return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
   case .or:  return NSCompoundPredicate(orPredicateWithSubpredicates:  subpredicates)
   case .xor: return NSCompoundPredicate(xorPredicateWithSubpredicates: subpredicates)
   default:   return .never
    
  }
 }
}

@available(iOS 15.0, macOS 12.0, *)
public struct NMSnapshotFetchControllerConfiguration: Equatable {
 let fetchPredicate: NSPredicate
 let sortDescriptors: [NSSortDescriptor]
 let sectionNameKeyPath: String?
 let cacheResults: Bool
 
 public func applying<Root, Value> (sortOrder: NMSortOrder<Root, Value>) -> Self {
  .init(fetchPredicate: fetchPredicate,
        sortDescriptors: sortDescriptors + [sortOrder.sortDescriptor],
        sectionNameKeyPath: sectionNameKeyPath,
        cacheResults: cacheResults)
 }
 
 public var togglingSortOrder: Self {
  let reversed = sortDescriptors.map{ NSSortDescriptor(key: $0.key, ascending: !$0.ascending) }
  return .init(fetchPredicate: fetchPredicate,
               sortDescriptors: reversed ,
               sectionNameKeyPath: sectionNameKeyPath,
               cacheResults: cacheResults)
 }
 
 public func applying(predicate: NSPredicate, operation: NMPredicateOperation = .and) -> Self {
  
  .init(fetchPredicate: operation.predicate(subpredicates: [fetchPredicate, predicate]),
        sortDescriptors: sortDescriptors,
        sectionNameKeyPath: sectionNameKeyPath,
        cacheResults: cacheResults)
 }
 
 public func applying(subpredicates: [NSPredicate], operation: NMPredicateOperation = .and) -> Self {
  
  .init(fetchPredicate: operation.predicate(subpredicates: [fetchPredicate] + subpredicates),
        sortDescriptors: sortDescriptors,
        sectionNameKeyPath: sectionNameKeyPath,
        cacheResults: cacheResults)
 }
 
 public func applying(newPredicate: NSPredicate) -> Self {
  
  .init(fetchPredicate: newPredicate,
        sortDescriptors: sortDescriptors,
        sectionNameKeyPath: sectionNameKeyPath,
        cacheResults: cacheResults)
 }
}

@available(iOS 15.0, macOS 12.0, *)
public extension NMSnapshotFetchController {
 
 @MainActor func toggleSortOrder(){
  configuration = configuration.togglingSortOrder
 }
 
 @MainActor func apply<Root, Value> (sortOrder: NMSortOrder<Root, Value>) {
  configuration = configuration.applying(sortOrder: sortOrder)
 }
 
 @MainActor func apply(predicate: NSPredicate, operation: NMPredicateOperation = .and){
  configuration = configuration.applying(predicate: predicate)
 }
 
 @MainActor func apply(subpredicates: [NSPredicate], operation: NMPredicateOperation = .and){
  configuration = configuration.applying(subpredicates: subpredicates)
 }
 
 @MainActor func apply(newPredicate: NSPredicate) {
  configuration = configuration.applying(newPredicate: newPredicate)
 }
}

