import Foundation

@available(iOS 15.0, macOS 12.0, *)
public extension NMContentElement where Self.Snippet.Folder == Self.Folder,
                                        Self.Folder.Element == Self,
                                        Self.Snippet.Element == Self,
                                        Self.Snippet == Self.Folder.Snippet {
 
 
 //MARK: UNFOLDER SINGLE ELEMENT INTO THIS SNIPPET.
 
 func unfolder(persist: Bool = true,
               with updates: ((Self) throws -> ())? = nil) async throws
 where Self: NMFileStorageManageable, Self.Folder: NMFileStorageManageable {
  
  try await unfoldered(persist: persist, with: updates)
  
 }
 
 @discardableResult func unfoldered(persist: Bool = true,
                                    with updates: ((Self) throws -> ())? = nil) async throws -> Self
 
 where Self: NMFileStorageManageable, Self.Folder: NMFileStorageManageable {
  
  print(#function, objectID)
  
  try Task.checkCancellation()
 
  
  guard let unfolderedContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .unfolder)
  }
  
//  let folder = await unfolderedContext.perform { self.folder }
  
 let folder = try await unfolderedContext.perform { [ unowned self ] () throws -> Folder? in
   
   try Task.checkCancellation()

   guard let folder = self.folder else {
    try updates?(self)
    return nil
   }
   
   guard let parentSnippet = snippet else {
    throw ContextError.noSnippet(object: self, entity: .singleContentElement, operation: .unfolder)
   }
   
   guard parentSnippet.isValid else {
    throw ContextError.isInvalid(object: parentSnippet, entity: .snippet, operation: .unfolder)
   }
   
   guard isValid else {
    throw ContextError.isInvalid(object: self, entity: .singleContentElement, operation: .unfolder)
   }
   
   
   guard let sourceURL = self.url else {
    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .unfolder)
    
   }
   
    //print ("MOVE from [\(parentSnippet.nameTag)] to [\(destination.nameTag)]")
  
   folder.removeFromContainer(element: self)
   
   guard let destURL = self.url else {
    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .unfolder)
   }
   
   try updates?(self) //MO must be updated with move opeation in one atomic await perform block!
   
   let oldTask = fileManagerTask
   let sourceFolderTask = folder.fileManagerTask
   let sourceSnippetTask = parentSnippet.fileManagerTask
  
   let newTask = Task.detached {
    try Task.checkCancellation()
    
    try await oldTask?.value            //await that previous file manager task has finished...
    try await sourceFolderTask?.value   //await that current active source folder task has finished...
    try await sourceSnippetTask?.value  //await that current source snippet task has finished...
    
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
 
 
}

