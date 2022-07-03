
import Foundation

public protocol NMContentFolder where Self: NMBaseContent {
 
 associatedtype Element: NMBaseContent
 associatedtype Snippet: NMContentElementsContainer
 
 var snippet: Snippet?               { get }
 var mixedSnippet: NMMixedSnippet?   { get }
 var folderedElements: [Element]     { get }
 
 func addToContainer(singleElements: [Element])
 func removeFromContainer(singleElements: [Element])
 
}

extension NMContentFolder {
 public var container: NMBaseSnippet? { snippet ?? mixedSnippet }
 public var hasSnippet: Bool { container != nil }
 public var isValid: Bool { managedObjectContext != nil && isDeleted == false }
 public var isNew: Bool { isValid && hasSnippet == false  }
 public var isEmpty: Bool { folderedElements.isEmpty }
 public var elementsCount: Int { folderedElements.count }
 public var isSingleElement: Bool { elementsCount == 1 }

 public func canBeMoved(to destination: Snippet) -> Bool { isValid && hasSnippet && destination != self }
 
 public func addToContainer(element: Element){ addToContainer(singleElements: [element]) }
 public func removeFromContainer(element: Element) { removeFromContainer(singleElements: [element])}
 
 
 
}


@available(iOS 15.0, macOS 12.0, *)
extension NMContentFolder where Self: NMFileStorageManageable {
 
 public var folderedElementsAsync: [Element]? {
  get async {
   await managedObjectContext?.perform { self.folderedElements }
  }
 }
 
 public func fileManagerFolderedGroup() async throws {
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   await folderedElementsAsync?.forEach{ element in
    group.addTask { try await element.fileManagerTask?.value }
   }
   
   try await group.waitForAll()
  }
 }
 
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerFolderedGroup()
  
 }
 
}

@available(iOS 15.0, macOS 12.0, *)
extension NMContentFolder
 where Self.Element: NMContentElement,
       Self.Snippet == Self.Element.Snippet,
       Self.Snippet.Folder == Self,
       Self.Snippet.Element == Self.Element,
       Self.Element.Folder == Self {
 
 func autoremoveIfNeeded() async throws
  where Self.Element: NMFileStorageManageable, Self: NMFileStorageManageable {
  
  print(#function, objectID)
   
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .folderContentElement, operation: .storageDelete )
  }
  
  if await context.perform({ self.isDeleted }) { return }
  if await context.perform({ self.isEmpty }) { try await self.delete(); return }
  
  guard await context.perform({self.isSingleElement}) else { return }
  
  let single = await context.perform{ self.folderedElements.first! }
  try await single.unfolder()
  
 }
}

@available(iOS 13.0, *)
public extension NMFileStorageManageable where Self: NMContentFolder {
 var url: URL? {
  get {
   
   guard let folderID = id?.uuidString else { return nil }
   guard let snippetID = (snippet ?? mixedSnippet)?.id?.uuidString else { return nil }
   
   let snippetURL = docFolder.appendingPathComponent(snippetID)
   
   return snippetURL.appendingPathComponent(folderID)
  }
 }
}

@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable
 where Self: NMContentFolder,
       Self.Snippet: NMFileStorageManageable {
 
 var resourceFolderURL: URL {
  
  get async throws {
   
   try Task.checkCancellation()
   
   guard let context = managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .object, operation: .resourceFileAccess)
   }
   
   try await fileManagerTask?.value
   
   guard let folderID = (await context.perform { self.id?.uuidString }) else {
    throw ContextError.noID(object: self, entity: .folderContentElement, operation: .resourceFileAccess)
   }
   
   guard let snippet = (await context.perform {self.snippet}) else {
    throw ContextError.noSnippet(object: self, entity: .folderContentElement, operation: .resourceFileAccess)
   }
   
   return try await snippet.resourceSnippetURL.appendingPathComponent(folderID)
  }
 }
}


