
import Foundation

@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable {
 
 func delete() async throws {
  print(#function, objectID)
  try await removeWithFileStorage()
 }
 
 func removeWithFileStorage() async throws {
  print(#function, objectID)
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .storageDelete )
  }
  
  //WAIT FOR ALL FILE MANAGER CHILD TASKS TO COMPLETE!!!
  try await fileManagerTaskGroup()
  
  let url = try await context.perform { [ unowned self ] () throws -> URL in
//   print (self)
   
   defer { context.delete(self) }
   
   guard let url = self.url else {
    throw ContextError.noURL(object: self, entity: .object, operation: .storageDelete)
   }
   return url
  }
  
  
  guard FileManager.default.fileExists(atPath: url.path) else {
   throw ContextError.dataDeleteFailure(at: url,
                                        object: self,
                                        entity: .object,
                                        operation: .storageDelete,
                                        description: "Deleteting Object File Folder")
  }
  
  
  
  try await FileManager.removeItemFromDisk(at: url)
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
