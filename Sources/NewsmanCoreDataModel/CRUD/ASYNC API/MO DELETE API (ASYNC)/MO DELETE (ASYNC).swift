
import Foundation

@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable {
 
 // Deletes MO from context and removes its file storage folder from disk if withFileStorageRecovery == false (default) otherwise moves this folder entirely into the temporary recovery directory at recovery URL path.
 
 func delete( withFileStorageRecovery: Bool = false ) async throws {
  
  print(#function, objectID)
  
  try await removeWithFileStorage(withFileStorageRecovery)
 }
 
 
 // helper async remover from context with file storage.
 func removeWithFileStorage(_ withFileStorageRecovery: Bool = false) async throws {
  
  print(#function, objectID)
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .storageDelete )
  }
  
  try await fileManagerTaskGroup()  //WAIT FOR ALL FILE MANAGER CHILD TASKS TO COMPLETE!!!
  
  let (url, recoveryURL) = try await context.perform { [ unowned self ] () throws -> (URL, URL) in

   defer { context.delete(self) } // finally mark for deletion from context!
   
   guard let url = self.url, let recoveryURL = self.recoveryURL else {
    throw ContextError.noURL(object: self, entity: .object, operation: .storageDelete)
   }
   
   return (url, recoveryURL)
  }
  
  guard FileManager.default.fileExists(atPath: url.path) else {
   throw ContextError.dataDeleteFailure(at: url, object: self, entity: .object, operation: .storageDelete,
                                        description: "Deleteting Object File Folder Failed!")
  }
  
  
  if withFileStorageRecovery {
   try await FileManager.moveItemOnDisk(from: url, to: recoveryURL) // recovery variant
  } else {
   try await FileManager.removeItemFromDisk(at: url) // total removal unrecoverably
  }
  print("DELETE DONE!", #function, objectID)
 }
 
}






@available(iOS 13.0,  *)
public extension NMFileStorageManageable {
 func delete()  {
  guard let context = managedObjectContext else { return }
  context.persist { [ unowned self ] () in
   context.delete(self)
  } handler: { result  in
    
  }
 }
}


@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable {
 
}
