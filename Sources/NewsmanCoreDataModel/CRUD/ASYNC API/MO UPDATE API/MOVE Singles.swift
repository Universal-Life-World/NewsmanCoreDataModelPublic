
import Foundation
import CoreData

@available(iOS 15.0, macOS 12.0, *)
public extension NMContentElement where Self:    NMFileStorageManageable & NMUndoManageable,
                                        Snippet: NMFileStorageManageable & NMUndoManageable,
                                        Folder:  NMFileStorageManageable & NMUndoManageable,
                                        Snippet.Folder == Folder,
                                        Folder.Element == Self,
                                        Snippet.Element == Self,
                                        Snippet == Folder.Snippet {
 
 
 //MARK: MOVE THIS SINGLE ELEMENT FROM SOURCE SNIPPET INTO DESTINATION ONE
 
 func move (to destination: Snippet,
            persist: Bool = true,
            with updates: ((Self) throws -> ())? = nil) async throws {
 
  
  try await withOpenUndoSession(of: self){
   try await moved(to: destination, persist: persist, with: updates)
  }
  
//   await NMUndoSession.open(target: self)  //OPEN UNDO/REDO SESSION!
//
//   try await moved(to: destination, persist: persist, with: updates)
//
// if let currentSession = await NMUndoSession.current {
//  await undoManager.registerUndoSession(currentSession) //attach current open session to MO undo manager!
// }
//
//   await NMUndoSession.close() //CLOSE UNDO/REDO SESSION AFTER MOVE!
 }
 
 
 @discardableResult func moved(to destination: Snippet,
                               persist: Bool = true,
                               with updates: ((Self) throws -> ())? = nil) async throws -> Self {
  
  try Task.checkCancellation()
  
  
  guard let movedContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .move)
  }
  
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
   
   try destination.addToContainer(undoTarget: self) // move self with undo/redo!
    
   let folder = self.folder //fix the strong ref to folder before element removal from it!
   
   try folder?.removeFromContainer(undoTarget: self) // unfolder self with undo/redo!
 
   guard let destURL = self.url else {
    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .move)
   }
   
   try updates?(self) //MO must be updated with move operation in one atomic await perform block!
   
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
    
     //try await Task.sleep(nanoseconds: .random(in: 5000...15000)) //create some latency for testing...
    
    try await FileManager.moveItemOnDisk(undoTargetURL: sourceURL, to: destURL) //move with undo/redo!

    
   }
   
   fileManagerTask = newTask
   
   return folder
   
  }
  
  try await fileManagerTask?.value  //await that current file manager task has finished...
  
  try await folder?.autoremoveIfNeeded()
  
  return try await self.persisted(persist)
 
  
 }
 
 
  //MARK: MOVE THIS SINGLE ELEMENT FROM SOURCE SNIPPET INTO DESTINATION FOLDER.
 
 
 func move (to destination: Folder,
            persist: Bool = true,
            with updates: ((Self) throws -> ())? = nil) async throws {
  
  try await moved(to: destination, persist: persist, with: updates)
  
 }
 
 @discardableResult func moved(to destination: Folder,
                               persist: Bool = true,
                               with updates: ((Self) throws -> ())? = nil) async throws -> Self {
  
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

