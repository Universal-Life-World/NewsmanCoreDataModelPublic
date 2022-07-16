

import Foundation
import CloudKit

@available(iOS 13.0, *)
public extension NMFileStorageManageable where Self: NMContentElementsContainer {
 //Sync URL getter to obtain Snippets resource folder URL.
 var url: URL? {
  guard let snippetID = id?.uuidString else { return nil }
  return docFolder.appendingPathComponent(snippetID)
  
 }
}


@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable where Self: NMContentElementsContainer {
 
//Async URL getter to obtain Snippets resource folder URL with waiting:
// 1) its own current unfinished file manager task.
// 2) its own child folders unfinished file manager task group.
// 3) its own child unfoldered content elements unfinished file manager task group.
 
 var resourceSnippetURL: URL {
  get async throws {
   
   try Task.checkCancellation()
   
   guard let context = managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .object, operation: .resourceFileAccess)
   }
   
   try await fileManagerTask?.value //wait for task group unfinished tasks!
   
   guard let snippetURL = (await context.perform { self.url }) else {
    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .resourceFileAccess)
   }
   
   return snippetURL
  }
 }
 
 
 
}

@available(iOS 15.0, macOS 12.0, *)
extension NMFileStorageManageable
 where Self: NMContentElementsContainer,
       Self.Element: NMContentElement & NMFileStorageManageable,
       Self.Folder: NMContentFolder & NMFileStorageManageable,
       Self.Element == Self.Folder.Element {

 
 public var unfolderedAsync: [Element]? {
  get async {
   await managedObjectContext?.perform { self.singleContentElements.filter{ !$0.isFoldered } }
  }
 }
 
 public var foldersAsync: [Folder]? {
  get async {
   await managedObjectContext?.perform { self.folders }
  }
 }
 
 public func fileManagerFoldersTaskGroup() async throws {
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   await foldersAsync?.forEach{ folder in
    group.addTask { try await folder.fileManagerTaskGroup() }
   }
   
   try await group.waitForAll()
  }
 }
 
 public func fileManagerUnfolderedTaskGroup() async throws {
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   await unfolderedAsync?.forEach{ element in
    group.addTask { try await element.fileManagerTaskGroup() }
   }
   
   try await group.waitForAll()
  }
 }
 
 public func fileManagerChildrenTaskGroup() async throws {
  try await fileManagerFoldersTaskGroup()
  try await fileManagerUnfolderedTaskGroup()
 }
 
 
 
 
}
