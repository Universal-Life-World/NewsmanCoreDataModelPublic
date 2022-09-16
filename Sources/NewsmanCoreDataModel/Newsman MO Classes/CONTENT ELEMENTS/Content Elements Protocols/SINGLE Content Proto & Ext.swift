import Foundation

public protocol NMContentElement where Self: NMBaseContent {
 
 associatedtype Snippet: NMContentElementsContainer
 associatedtype Folder: NMContentFolder
 
 var snippet: Snippet?              { get }
 var folder: Folder?                { get }
 var mixedSnippet: NMMixedSnippet?  { get }
 var mixedFolder: NMMixedFolder?    { get }
 
 
 
}

extension Sequence where Element: NMContentElement  {
 public func modified(with block: (Element) throws -> () ) rethrows -> [Element] {
  try map{ try $0.modified(with:block) }
 }
 
 public func withSnippetsUpdated(block: (Element.Snippet) throws -> () ) rethrows -> [Element] {
  try map { try $0.withSnippetUpdated(block: block) }
 }
 
 public func withFoldersUpdated(block: (Element.Folder) throws -> () ) rethrows ->  [Element] {
  try map { try $0.withFolderUpdated(block: block) }
 }
 
 public func withContainersUpdated(block: (Element.Snippet, Element.Folder?) throws -> () ) rethrows -> [Element] {
  try map { try $0.withContainersUpdated(block: block) }
 }
}

extension NMContentElement {
 
 public var container: NMBaseSnippet?       { snippet ?? mixedSnippet }
 public var nestedContainer: NMBaseContent? { folder ?? mixedFolder   }
 public var isFoldered: Bool { nestedContainer != nil }
 public var hasSnippet: Bool { container != nil }
 public var isValid: Bool { managedObjectContext != nil && isDeleted == false }
 public var isNew: Bool { isValid && hasSnippet == false && isFoldered == false }
 public func canBeMoved(to destination: Snippet) -> Bool { isValid && hasSnippet && destination != self }
 
 public func modified(with block: (Self) throws -> () ) rethrows -> Self {
  try block(self)
  return self 
 }

 public func withSnippetUpdated(block: (Snippet) throws -> () ) rethrows -> Self {
  guard let snippet = snippet else { return self }
  try block(snippet)
  return self
 }

 public func withFolderUpdated(block: (Folder) throws -> () ) rethrows -> Self {
  guard let folder = folder else { return self }
  try block(folder)
  return self
 }
 
 public func withContainersUpdated(block: (Snippet, Folder?) throws -> () ) rethrows -> Self {
  guard let snippet = snippet else { return self }
  try block(snippet, folder)
  return self
 }

 @available(iOS 15.0, macOS 12.0, *)
 public subscript<Value>(keyPath: KeyPath<Self, Value>) -> Value {
  get async throws {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .singleContentElement,
                                 operation: .gettingObjectKeyPath)}
   return await context.perform { self[keyPath: keyPath] }
  }
 }
 
 @available(iOS 15.0, macOS 12.0, *)
 public var snippetAsync: Snippet {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .gettingSnippet)
   }
   
   return try await context.perform {
    guard let snippet = self.snippet else {
     throw ContextError.noSnippet(object: self, entity: .singleContentElement, operation: .gettingSnippet)
    }
    return snippet
   } //try await context.perform...
  } //get async throws...
 } //snippetID...
 
 @available(iOS 15.0, macOS 12.0, *)
 public var mixedSnippetAsync: NMMixedSnippet {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .gettingSnippet)
   }
   
   return try await context.perform {
    guard let snippet = self.mixedSnippet else {
     throw ContextError.noSnippet(object: self, entity: .singleContentElement, operation: .gettingSnippet)
    }
    return snippet
   } //try await context.perform...
  } //get async throws...
 } //snippetID...
 
 @available(iOS 15.0, macOS 12.0, *)
 public var snippetID: UUID {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .gettingSnippetID)
   }
   
   return try await context.perform {
    guard let snippetID = self.snippet?.id else {
     throw ContextError.noSnippet(object: self, entity: .singleContentElement, operation: .gettingSnippetID)
    }
    return snippetID
   } //try await context.perform...
  } //get async throws...
 } //snippetID...
 
 
 @available(iOS 15.0, macOS 12.0, *)
 public var folderAsync: Folder? {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .gettingFolder)
   }
   return await context.perform { self.folder }
  } //get async throws...
 } //folder..

 
 @available(iOS 15.0, macOS 12.0, *)
 public var folderID: UUID? {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .gettingFolderID)
   }
   return await context.perform { self.folder?.id }
  } //get async throws...
 } //folderID..

 
 @available(iOS 15.0, macOS 12.0, *)
 public var elementID: UUID {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .gettingObjectID)
   }
   
   return try await context.perform {
    guard let elementID = self.id else {
     throw ContextError.noID(object: self, entity: .singleContentElement, operation: .gettingObjectID)
    }
    return elementID
   } //try await context.perform...
  } //get async throws...
 } //folderID..
 
}



