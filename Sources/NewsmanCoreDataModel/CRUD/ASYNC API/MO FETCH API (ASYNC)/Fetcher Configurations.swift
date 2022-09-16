import Foundation
import CoreData

public enum NMSortOrder<Root, Value>: Equatable where Root: NSManagedObject {
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

public enum NMPredicateSearchMode{
 case normalized
 case cdInsensitive
 case cdSensitive
 
 var predicateFormat: String {
  switch self {
   case .normalized:    return "%K CONTAINS[n] %@"
   case .cdInsensitive: return "%K CONTAINS[cd] %@"
   case .cdSensitive:   return "%K CONTAINS %@"
  }
 }
}

public enum NMPredicateOperation {
 case and // disjuction
 case or  // conjuction
 case xor // exclusive OR
 case not // negation
 
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
 let sortDescriptors: [ NSSortDescriptor ]
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
 
 public func applying(predicate: NSPredicate, operation: NMPredicateOperation = .or) -> Self {
  
  .init(fetchPredicate: operation.predicate(subpredicates: [fetchPredicate, predicate]),
        sortDescriptors: sortDescriptors,
        sectionNameKeyPath: sectionNameKeyPath,
        cacheResults: cacheResults)
 }
 
 public func applying(subpredicates: [NSPredicate], operation: NMPredicateOperation = .or) -> Self {
  
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
 
 public func applying<Root, Value> (newSortOrder: NMSortOrder<Root, Value>) -> Self {
  .init(fetchPredicate: fetchPredicate,
        sortDescriptors: [newSortOrder.sortDescriptor],
        sectionNameKeyPath: sectionNameKeyPath,
        cacheResults: cacheResults)
 }
 
 

 
 
 public func applying(searchStrings: [String],  for keyPaths: [String],
                      searchMode: NMPredicateSearchMode = .cdInsensitive) -> Self {
  
  
  let preds = searchStrings.map{ searchString -> NSPredicate in
   let preds = keyPaths.map{ NSPredicate(format: searchMode.predicateFormat, $0, searchString) }
   
   return NSCompoundPredicate(orPredicateWithSubpredicates: preds)
  }
  
  return .init(fetchPredicate: fetchPredicate * NSCompoundPredicate(orPredicateWithSubpredicates: preds),
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
 
 @MainActor func apply<Root, Value> (newSortOrder: NMSortOrder<Root, Value>) {
  configuration = configuration.applying(newSortOrder: newSortOrder)
 }
 
 @MainActor func apply(predicate: NSPredicate, operation: NMPredicateOperation = .or){
  configuration = configuration.applying(predicate: predicate, operation: operation)
 }
 
 @MainActor func apply(subpredicates: [NSPredicate], operation: NMPredicateOperation = .or){
  configuration = configuration.applying(subpredicates: subpredicates, operation: operation)
 }
 
 @MainActor func apply(newPredicate: NSPredicate) {
  configuration = configuration.applying(newPredicate: newPredicate)
 }
 
 @MainActor func apply(searchStrings: [String],
                       keyPaths: [String],
                       searchMode: NMPredicateSearchMode = .cdInsensitive) {
  
  if let preSearchConfiguration = preSearchConfiguration {
   configuration = preSearchConfiguration.applying(searchStrings: searchStrings,
                                                   for: keyPaths,
                                                   searchMode: searchMode)
  } else {
   preSearchConfiguration = configuration
   configuration = configuration.applying(searchStrings: searchStrings,
                                          for: keyPaths,
                                          searchMode: searchMode)
  }
 }
 
 @MainActor func apply(searchString: String,
                       separators: CharacterSet = .whitespaces,
                       searchMode: NMPredicateSearchMode = .cdInsensitive,
                       keyPaths: String...) {
  
  let strings = searchString.components(separatedBy: separators)
 
  apply(searchStrings: strings, keyPaths: keyPaths, searchMode: searchMode)
 }
 
 @MainActor func apply(searchString: String,
                       separators: CharacterSet = .whitespaces,
                       searchMode: NMPredicateSearchMode = .cdInsensitive,
                       keyPaths: [String]) {
  
  let strings = searchString.components(separatedBy: separators)
  apply(searchStrings: strings, keyPaths: keyPaths, searchMode: searchMode)
 }
 
 @MainActor func apply(overallSearchString: String, separators: CharacterSet = .whitespaces){
 
  
  let stringKeyPaths = T.entity()
                        .attributesByName
                        .values
                        .filter{ $0.type == .string && $0.name.hasPrefix(.normalizedFieldNamePrefix) }
                        .map{ $0.name }
  
 
  guard let normalizedSearchString = overallSearchString.normalizedForSearch else {
   apply(searchString: overallSearchString, separators: separators, keyPaths: stringKeyPaths)
   return
   
  }
  
  apply(searchString: normalizedSearchString,
        separators: separators,
        searchMode: .normalized,
        keyPaths: stringKeyPaths)
  
  
  
  
  
 }
}

