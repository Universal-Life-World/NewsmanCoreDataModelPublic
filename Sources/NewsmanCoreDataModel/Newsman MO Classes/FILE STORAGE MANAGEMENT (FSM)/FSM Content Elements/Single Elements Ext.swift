
import Foundation

@available(iOS 13.0, *)
public extension NMFileStorageManageable where Self: NMContentElement {
 var url: URL? {
 
  guard let elementID = id?.uuidString else { return nil }
  guard let snippetID = (snippet ?? mixedSnippet)?.id?.uuidString else { return nil }
  
  let snippetURL = docFolder.appendingPathComponent(snippetID)
  
  guard let folderID = (folder ?? mixedFolder)?.id?.uuidString else {
   return snippetURL.appendingPathComponent(elementID)
  }
  
  return snippetURL.appendingPathComponent(folderID).appendingPathComponent(elementID)
  
 }
 
}




@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable
where Self: NMContentElement,
      Self.Folder.Snippet: NMFileStorageManageable,
      Self.Folder: NMFileStorageManageable,
      Self.Snippet: NMFileStorageManageable {
 
  //Async URL getter to obtain Folders resource folder URL with waiting for unfinished file manager task.
 var resourceContentURL: URL {
  get async throws {
   
   try Task.checkCancellation()
   
   guard let context = managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .resourceFileAccess)
   }
   
   try await fileManagerTaskGroup()
   
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



