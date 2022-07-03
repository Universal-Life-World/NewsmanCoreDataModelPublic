

import Foundation
import CoreData

//MARK: Block based async methods for creating and deleting file storage.
public extension NMFileStorageManageable {
 var docFolder: URL {
  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
 }
 
 func removeFileStorage(handler: @escaping (Result<Void, Error>) -> ()) {
  guard let url = self.url else {
   handler(.failure(ContextError.noURL(object: self, entity: .object, operation: .storageDelete)))
   return
  }
  
  
  guard FileManager.default.fileExists(atPath: url.path) else {
   handler(.failure(ContextError.dataDeleteFailure(at: url,
                                                   object: self,
                                                   entity: .object,
                                                   operation: .storageDelete,
                                                   description: "Deleteting Object File Folder")))
   return
  }
  
  FileManager.removeItemFromDisk(at: url, completion: handler)
  
 }
 
 
 func initFileStorage(handler: @escaping (Result<Void, Error>) -> ()) {
  guard let url = self.url else {
   handler(.failure(ContextError.noURL(object: self, entity: .object, operation: .storageCreate)))
   return
  }
  
  if FileManager.default.fileExists(atPath: url.path) {
   handler(.success(()))
   return
  }
  
  FileManager.createDirectoryOnDisk(at: url, completion: handler)
 }
 
}


