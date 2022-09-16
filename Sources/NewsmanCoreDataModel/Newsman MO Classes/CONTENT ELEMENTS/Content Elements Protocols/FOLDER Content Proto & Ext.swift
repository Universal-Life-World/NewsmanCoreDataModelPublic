
import Foundation
import CoreData

public protocol NMContentFolder where Self: NMBaseContent {
 
 associatedtype Element: NMBaseContent
 associatedtype Snippet: NMContentElementsContainer
 
 var snippet: Snippet?               { get }
 var mixedSnippet: NMMixedSnippet?   { get }
 var folderedElements: [Element]     { get }
 
 func addToContainer(singleElements: [Element])
 func removeFromContainer(singleElements: [Element])
 
}

extension Sequence where Element: NMContentFolder  {
 public func modified(with block: (Element) throws -> () ) rethrows -> [Element] {
  try map{ try $0.modified(with:block) }
 }
 
 public func withSnippetsUpdated(block: (Element.Snippet) throws -> () ) rethrows -> [Element] {
  try map { try $0.withSnippetUpdated(block: block) }
 }
 
 public func withElementsUpdated(block: ([Element.Element]) throws -> () ) rethrows ->  [Element] {
  try map { try $0.withElementsUpdated(block: block) }
 }
 
 public func withEachElementUpdated(block: (Element.Element) throws -> () ) rethrows ->  [Element]
  where Element.Element: NMContentElement {
  try map { try $0.withEachElementUpdated(block: block) }
 }
}

extension NMContentFolder {
 public var container       : NMBaseSnippet? { snippet ?? mixedSnippet }
 public var hasSnippet      : Bool           { container != nil }
 public var isValid         : Bool           { managedObjectContext != nil && isDeleted == false }
 public var isNew           : Bool           { isValid && hasSnippet == false  }
 public var isEmpty         : Bool           { folderedElements.isEmpty }
 public var elementsCount   : Int            { folderedElements.count }
 public var isSingleElement : Bool           { elementsCount == 1 }

 
 
 public func modified(with block: (Self) throws -> () ) rethrows -> Self {
  try block(self)
  return self
 }
 
 public func withElementsUpdated(block: ([Element]) throws -> () ) rethrows -> Self {
  try block(folderedElements)
  return self
 }
 
 public func withEachElementUpdated(block: (Element) throws -> () ) rethrows -> Self
  where Element: NMContentElement {
  _ = try folderedElements.modified(with: block)
  return self
 }
 
 public func withSnippetUpdated(block: (Snippet) throws -> () ) rethrows -> Self {
  guard let snippet = snippet else { return self }
  try block(snippet)
  return self
 }
 
 public func contains(element: Element) -> Bool { folderedElements.contains{ element.id == $0.id } }
 public func contains(element: Element, where predicate: (Element) -> Bool ) -> Bool {
  folderedElements.contains(where: predicate)
 }

 public func canBeMoved(to destination: Snippet) -> Bool { isValid && hasSnippet && destination != self }
 
 public func addToContainer(element: Element){ addToContainer(singleElements: [element]) }
 
 public func addToContainer(element: Element, with predicate: (Element) -> Bool){
  if predicate(element) {
   addToContainer(singleElements: [element])
  }
 }
 
 public func addToContainer(elements: [Element], with predicate: (Element) -> Bool){
  addToContainer(singleElements: elements.filter(predicate))
 }
 
 public func removeFromContainer(element: Element) { removeFromContainer(singleElements: [element])}
 
 public static func registeredFolder(with id: UUID, with context: NSManagedObjectContext) -> Self? {
  context.registeredObjects.compactMap{ $0 as? Self }.first{ $0.id == id && $0.isValid }
 }
 
 public static func existingFolder(with id: UUID, in context: NSManagedObjectContext) -> Self? {
  if let object = registeredFolder(with: id, with: context) { return object }
  let pred = NSPredicate(format: "SELF.id == %@", id as CVarArg )
  let fr = Self.fetchRequest()
  fr.predicate = pred
  return try? context.fetch(fr).first as? Self
 }
 
 @available(iOS 15.0, macOS 12.0, *)
 public static func existingFolder(with id: UUID, in context: NSManagedObjectContext) async throws -> Self? {
  try await context.perform {
   if let object = registeredFolder(with: id, with: context) { return object }
   let pred = NSPredicate(format: "SELF.id == %@", id as CVarArg )
   let fr = Self.fetchRequest()
   fr.predicate = pred
   return try context.fetch(fr).first as? Self
  }
 }//public static func existingFolder...async
 
 
 @available(iOS 15.0, macOS 12.0, *)
 public subscript<Value>(keyPath: KeyPath<Self, Value>) -> Value {
  get async throws {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .contentFolder,
                                 operation: .gettingObjectKeyPath)}
   return await context.perform { self[keyPath: keyPath] }
  }
 }
 
 @available(iOS 15.0, macOS 12.0, *)
 public var snippetID: UUID {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentFolder, operation: .gettingSnippetID)
   }
   
   return try await context.perform {
    guard let snippetID = self.snippet?.id else {
     throw ContextError.noSnippet(object: self, entity: .contentFolder, operation: .gettingSnippetID)
    }
    return snippetID
   } //try await context.perform...
  } //get async throws...
 } //snippetID...
 
 @available(iOS 15.0, macOS 12.0, *)
 public var snippetAsync: Snippet {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentFolder, operation: .gettingSnippet)
   }
   
   return try await context.perform {
    guard let snippet = self.snippet  else {
     throw ContextError.noSnippet(object: self, entity: .contentFolder, operation: .gettingSnippet)
    }
    return snippet
   } //try await context.perform...
  } //get async throws...
 } //snippet...
 
 
 @available(iOS 15.0, macOS 12.0, *)
 public var mixedSnippetAsync: NMMixedSnippet {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentFolder, operation: .gettingSnippet)
   }
   
   return try await context.perform {
    guard let snippet = self.mixedSnippet  else {
     throw ContextError.noSnippet(object: self, entity: .contentFolder, operation: .gettingSnippet)
    }
    return snippet
   } //try await context.perform...
  } //get async throws...
 } //snippet...
 
 @available(iOS 15.0, macOS 12.0, *)
 public var folderedElementsAsync: [Element] {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentFolder, operation: .gettingFolderElements)
   }
   
   return await context.perform { self.folderedElements }
  } //get async throws...
 } //snippet...
 
 @available(iOS 15.0, macOS 12.0, *)
 public var folderedElementsIDsAsync: [UUID] {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentFolder, operation: .gettingFolderElementsIDs)
   }
   
   return await context.perform { self.folderedElements.compactMap(\.id) }
  } //get async throws...
 } //snippet...
 
 @available(iOS 15.0, macOS 12.0, *)
 public var folderID: UUID {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentFolder, operation: .gettingObjectID)
   }
   
   return try await context.perform {
    guard let folderID = self.id else {
     throw ContextError.noID(object: self, entity: .contentFolder, operation: .gettingObjectID)
    }
    return folderID
   } //try await context.perform...
  } //get async throws...
 } //folderID..
 
}//ext...




@available(iOS 15.0, macOS 12.0, *)
extension NMContentFolder where Self: NMUndoManageable & NMFileStorageManageable,
                                Element: NMContentElement & NMUndoManageable & NMFileStorageManageable,
                                Snippet: NMUndoManageable & NMFileStorageManageable,
                                Snippet == Element.Snippet,
                                Snippet.Folder == Self,
                                Snippet.Element == Element,
                                Element.Folder == Self {
 
 func autoremoveIfNeeded() async throws {
  
  print(#function, objectID)
   
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .folderContentElement, operation: .autoremoveFolder )
  }
  
  if await context.perform({ self.isDeleted }) { return }
 
  if await context.perform({ self.isEmpty }) {
   try await self.deleteFromContext() // delete object with undo/redo...
   return
  }
         
  guard await context.perform({ self.isSingleElement }) else { return }
  
  let single = await context.perform{ self.folderedElements.first! }
   
  try await single.unfolder()
  
 }
}



