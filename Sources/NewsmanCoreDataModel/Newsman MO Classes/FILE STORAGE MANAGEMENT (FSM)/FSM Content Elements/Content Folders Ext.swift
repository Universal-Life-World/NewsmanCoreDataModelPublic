
import Foundation

@available(iOS 13.0, *)
public extension NMFileStorageManageable where Self: NMContentFolder {
 var url: URL? {
  
  guard let folderID = id?.uuidString else { return nil }
  guard let snippetID = (snippet ?? mixedSnippet)?.id?.uuidString else { return nil }
  let snippetURL = docFolder.appendingPathComponent(snippetID)
  return snippetURL.appendingPathComponent(folderID)

 }
 
}


@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable where Self: NMContentFolder, Snippet: NMFileStorageManageable  {
 
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


@available(iOS 15.0, macOS 12.0, *)
extension NMFileStorageManageable
 where Self: NMContentFolder,
       Self.Element: NMContentElement & NMFileStorageManageable,
       Self.Snippet: NMFileStorageManageable,
       Self.Element == Self.Snippet.Element,
       Self.Snippet == Self.Element.Snippet {
 
 public var folderedElementsAsync: [Element]? {
  get async { await managedObjectContext?.perform { self.folderedElements } }
 }
 
 public func fileManagerFolderedGroup() async throws {
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   await folderedElementsAsync?.forEach{ element in
    group.addTask { try await element.fileManagerTaskGroup() }
   }
   
   try await group.waitForAll()
  }
 }
 
 
 
}



