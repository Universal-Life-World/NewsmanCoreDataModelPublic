
import Foundation
import XCTest

@available(iOS 15.0, macOS 12.0, *)
public extension NMContentElement where Self.Snippet.Folder == Self.Folder,
                                        Self.Folder.Element == Self,
                                        Self.Snippet.Element == Self,
                                        Self.Snippet == Self.Folder.Snippet {
 
 
 //MARK: MOVE THIS SINGLE ELEMENT FROM SOURCE SNIPPET INTO DESTINATION ONE
 
 func move (to destination: Snippet,
            persist: Bool = true,
            with updates: ((Self) throws -> ())? = nil) async throws
  where Self: NMFileStorageManageable & NMUndoManageable, Self.Folder: NMFileStorageManageable {
  
   await NMUndoSession.open()
   
   try await moved(to: destination, persist: persist, with: updates)
   
   if let currentSession = await NMUndoSession.current {
    await undoManager.registerUndoSession(currentSession)
   }
   
   await NMUndoSession.close()
 }
 
 
 
 @discardableResult func moved(to destination: Snippet,
                               persist: Bool = true,
                               with updates: ((Self) throws -> ())? = nil) async throws -> Self
 
 where Self: NMFileStorageManageable & NMUndoManageable, Self.Folder: NMFileStorageManageable {
  
  try Task.checkCancellation()
  
  
  guard let movedContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .move)
  }
  
//  var undoRegTask: Task<Void, Never>?
  
//  let folder = await movedContext.perform { self.folder }
  
  let folder = try await movedContext.perform { [ unowned self ] () throws -> Folder? in
   
   try Task.checkCancellation()
   
   guard destination.isValid else {
    throw ContextError.isInvalid(object: destination, entity: .snippet, operation: .move)
   }
   
   guard let parentSnippet = snippet else {
    throw ContextError.noSnippet(object: self, entity: .singleContentElement, operation: .move)
   }
   
   guard parentSnippet.isValid else {
    throw ContextError.isInvalid(object: parentSnippet, entity: .snippet, operation: .move)
   }
   
   guard isValid else {
    throw ContextError.isInvalid(object: self, entity: .singleContentElement, operation: .move)
   }
   
   
   guard let sourceURL = self.url else {
    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .move)
    
   }
   
    //print ("MOVE from [\(parentSnippet.nameTag)] to [\(destination.nameTag)]")
   
   
   if parentSnippet != destination { destination.addToContainer(element: self) }
   
   let folder = self.folder
   folder?.removeFromContainer(element: self)
   let folderID = folder?.id
   
   NMUndoSession.register { [unowned self, weak parentSnippet, unowned movedContext] in
     await movedContext.perform {
//      print ("UNDO ACTION... \(parentSnippet!.singleContentElements.count)")
      parentSnippet?.addToContainer(element: self)
      if let folderID = folderID,
         let folder = parentSnippet?.folders.first(where: {$0.id == folderID}){
       folder.addToContainer(element: self)
      }
      //folder?.addToContainer(element: self)
//      XCTAssertEqual(self.snippet, parentSnippet)
//      print ("UNDO ACTION FINISHED... \(parentSnippet!.singleContentElements.count)")
      
     }
    
    } with: { [unowned self, weak destination, weak parentSnippet, unowned movedContext ] in
     await movedContext.perform {
      destination?.addToContainer(element: self)
      if let folderID = folderID,
         let folder = parentSnippet?.folders.first(where: {$0.id == folderID}){
       folder.removeFromContainer(element: self)
      }
     
     }
    }
   
   
  
   
   guard let destURL = self.url else {
    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .move)
   }
   
   try updates?(self) //MO must be updated with move opeation in one atomic await perform block!
   
   let oldTask = fileManagerTask
   let sourceFolderTask = folder?.fileManagerTask
   let sourceSnippetTask = parentSnippet.fileManagerTask
   let destSnippetTask = destination.fileManagerTask
   
   let newTask = Task.detached {
    try Task.checkCancellation()
    
    try await oldTask?.value            //await that previous file manager task has finished...
    try await sourceFolderTask?.value   //await that current active source folder task has finished...
    try await sourceSnippetTask?.value  //await that current source snippet task has finished...
    try await destSnippetTask?.value    //await that current dest snippet file manager task has finished...
    
     //try await Task.sleep(nanoseconds: .random(in: 5000...15000))
     //create some latency for testing...
    try await FileManager.moveItemOnDisk(from: sourceURL, to: destURL)
    
    
    
   }
   
   fileManagerTask = newTask
   
   return folder
   
  }
  
//  await undoRegTask?.value
  try await fileManagerTask?.value  //await that current file manager task has finished...
  try await folder?.autoremoveIfNeeded()
  
 
  return self//try await self.updated(updates)
  
 }
 
 
  //MARK: MOVE THIS SINGLE ELEMENT FROM SOURCE SNIPPET INTO DESTINATION FOLDER.
 
 
 func move (to destination: Folder,
            persist: Bool = true,
            with updates: ((Self) throws -> ())? = nil) async throws
 where Self: NMFileStorageManageable, Self.Folder: NMFileStorageManageable {
  
  try await moved(to: destination, persist: persist, with: updates)
  
 }
 
 @discardableResult func moved(to destination: Folder,
                               persist: Bool = true,
                               with updates: ((Self) throws -> ())? = nil) async throws -> Self
 
 where Self: NMFileStorageManageable, Self.Folder: NMFileStorageManageable {
  
  try Task.checkCancellation()
  

  guard let movedContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .move)
  }
  
   //  let folder = await movedContext.perform { self.folder }
  
  let folder = try await movedContext.perform { [ unowned self ] () throws -> Folder? in
   
   try Task.checkCancellation()
   
   guard destination.isValid else {
    throw ContextError.isInvalid(object: destination, entity: .folderContentElement, operation: .move)
   }
   
   guard let parentSnippet = self.snippet else {
    throw ContextError.noSnippet(object: self, entity: .singleContentElement, operation: .move)
   }
   
   guard parentSnippet.isValid else {
    throw ContextError.isInvalid(object: parentSnippet, entity: .snippet, operation: .move)
   }
   
   guard let destFolderSnippet = destination.snippet else {
    throw ContextError.noSnippet(object: destination, entity: .folderContentElement, operation: .move)
   }
   
   guard parentSnippet.isValid else {
    throw ContextError.isInvalid(object: parentSnippet, entity: .snippet, operation: .move)
   }
   
   let folder = self.folder
   
   guard folder != destination || parentSnippet != destFolderSnippet else {
    try updates?(self)
    return nil 
   }
   
   guard isValid else {
    throw ContextError.isInvalid(object: self, entity: .singleContentElement, operation: .move)
   }
   
   guard let sourceURL = self.url else {
    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .move)
    
   }
   
    //print ("MOVE from [\(parentSnippet.nameTag)] to [\(destination.nameTag)]")
   
   
   if parentSnippet != destFolderSnippet { destFolderSnippet.addToContainer(element: self) }
   
   if destination != folder { destination.addToContainer(element: self) }
   
   
   guard let destURL = self.url else {
    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .move)
   }
   
   try updates?(self) //MO must be updated with move opeation in one atomic await perform block!
   
   let oldTask = fileManagerTask
   let sourceFolderTask = folder?.fileManagerTask
   let sourceSnippetTask = parentSnippet.fileManagerTask
   let destFolderTask = destination.fileManagerTask

   
   let newTask = Task.detached {
    try Task.checkCancellation()
    
    try await oldTask?.value            //await that previous file manager task has finished...
    try await sourceFolderTask?.value   //await that current active source folder task has finished...
    try await sourceSnippetTask?.value  //await that current source snippet task has finished...
    try await destFolderTask?.value    //await that current dest folder file manager task has finished...
    
     //try await Task.sleep(nanoseconds: .random(in: 5000...15000))
     //create some latency for testing...
    try await FileManager.moveItemOnDisk(from: sourceURL, to: destURL)
    
    
    
   }
   
   fileManagerTask = newTask
   
   return folder
   
  }
  
  try await fileManagerTask?.value  //await that current file manager task has finished...
  try await folder?.autoremoveIfNeeded()
  
  return self//try await self.updated(updates)
  
 }
 
 
  //MARK: MERGE THIS SINGLE ELEMENT WITH OTHER ONE AND FORM FOLDER.
 
 
// func merge <E: NMContentElement>(with destination: E,
//                                  persist: Bool = true,
//                                  with updates: ((Folder) throws -> ())? = nil) async throws -> Folder
//
// where Self: NMFileStorageManageable, Self.Folder: NMFileStorageManageable {
//
//  try Task.checkCancellation()
//
//
//  guard let movedContext = self.managedObjectContext else {
//   throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .mergeWith)
//  }
//
//   //  let folder = await movedContext.perform { self.folder }
//
//  let sourceFolder = try await movedContext.perform { [ unowned self ] () throws -> Folder? in
//
//   try Task.checkCancellation()
//
//   guard destination.isValid else {
//    throw ContextError.isInvalid(object: destination, entity: .singleContentElement, operation: .mergeWith)
//   }
//
//   guard let parentSnippet = self.snippet else {
//    throw ContextError.noSnippet(object: self, entity: .singleContentElement, operation: .mergeWith)
//   }
//
//   guard parentSnippet.isValid else {
//    throw ContextError.isInvalid(object: parentSnippet, entity: .snippet, operation: .mergeWith)
//   }
//
//   guard let destElementSnippet = destination.snippet else {
//    throw ContextError.isInvalid(object: destination, entity: .singleContentElement, operation: .mergeWith)
//   }
//
//   guard destElementSnippet.isValid else {
//    throw ContextError.isInvalid(object: destElementSnippet, entity: .snippet, operation: .mergeWith)
//   }
//
//   let sourceFolder = self.folder
//
//   guard isValid else {
//    throw ContextError.isInvalid(object: self, entity: .singleContentElement, operation: .mergeWith)
//   }
//
//   guard let sourceURL = self.url else {
//    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .mergeWith)
//
//   }
//
//    //print ("MOVE from [\(parentSnippet.nameTag)] to [\(destination.nameTag)]")
//
//
//
//
//   guard let destURL = self.url else {
//    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .move)
//   }
//
//   try updates?(self) //MO must be updated with move opeation in one atomic await perform block!
//
//   let oldTask = fileManagerTask
//   let sourceFolderTask = folder?.fileManagerTask
//   let sourceSnippetTask = parentSnippet.fileManagerTask
//   let destFolderTask = destination.fileManagerTask
//
//
//   let newTask = Task.detached {
//    try Task.checkCancellation()
//
//    try await oldTask?.value            //await that previous file manager task has finished...
//    try await sourceFolderTask?.value   //await that current active source folder task has finished...
//    try await sourceSnippetTask?.value  //await that current source snippet task has finished...
//    try await destFolderTask?.value    //await that current dest folder file manager task has finished...
//
//     //try await Task.sleep(nanoseconds: .random(in: 5000...15000))
//     //create some latency for testing...
//    try await FileManager.moveItemOnDisk(from: sourceURL, to: destURL)
//
//
//
//   }
//
//   fileManagerTask = newTask
//
//   return folder
//
//  }
//
//  try await fileManagerTask?.value  //await that current file manager task has finished...
//  try await folder?.autoremoveIfNeeded()
//
//  return self//try await self.updated(updates)
//
// }
//
 
}

