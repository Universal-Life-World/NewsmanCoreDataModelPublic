import Foundation

public protocol NMContentElement where Self: NMBaseContent {
 
 associatedtype Snippet: NMContentElementsContainer
 associatedtype Folder: NMContentFolder
 
 var snippet: Snippet?              { get }
 var folder: Folder?                { get }
 var mixedSnippet: NMMixedSnippet?  { get }
 var mixedFolder: NMMixedFolder?    { get }
 
 
 
}

extension NMContentElement {
 
 public var container: NMBaseSnippet?       { snippet ?? mixedSnippet }
 public var nestedContainer: NMBaseContent? { folder ?? mixedFolder   }
 public var isFoldered: Bool { nestedContainer != nil }
 public var hasSnippet: Bool { container != nil }
 public var isValid: Bool { managedObjectContext != nil && isDeleted == false }
 public var isNew: Bool { isValid && hasSnippet == false && isFoldered == false }
 public func canBeMoved(to destination: Snippet) -> Bool { isValid && hasSnippet && destination != self }
 

}






@available(iOS 13.0, *)
public extension NMFileStorageManageable where Self: NMContentElement {
 var url: URL? {
  get {
   
   guard let elementID = id?.uuidString else { return nil }
   guard let snippetID = (snippet ?? mixedSnippet)?.id?.uuidString else { return nil }
   
   let snippetURL = docFolder.appendingPathComponent(snippetID)
   
   guard let folderID = (folder ?? mixedFolder)?.id?.uuidString else {
    return snippetURL.appendingPathComponent(elementID)
   }
   
   return snippetURL.appendingPathComponent(folderID).appendingPathComponent(elementID)
  }
 }
}


@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable
 where Self: NMContentElement,
       Self.Folder.Snippet: NMFileStorageManageable,
       Self.Folder: NMFileStorageManageable,
       Self.Snippet: NMFileStorageManageable {
 
 var resourceContentURL: URL {
  get async throws {
   
   try Task.checkCancellation()
   
   guard let context = managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .resourceFileAccess)
   }
   
   try await fileManagerTask?.value
   
   guard let ID = (await context.perform { self.id?.uuidString }) else {
    throw ContextError.noID(object: self, entity: .folderContentElement, operation: .resourceFileAccess)
   }
   
   
   guard let snippet = (await context.perform{ self.snippet }) else {
    throw ContextError.noSnippet(object: self, entity: .singleContentElement, operation: .resourceFileAccess)
   }
   
   guard let folder = (await context.perform{ self.folder }) else {
    return try await snippet.resourceSnippetURL.appendingPathComponent(ID)
   }
  
   
   return try await folder.resourceFolderURL.appendingPathComponent(ID)
  }
 }
}

