

import Foundation
 
//MARK: Fully async methods for creating storage.

@available(iOS 15.0, macOS 12.0.0, *)
public extension NMFileStorageManageable {
 
 func withFileStorage() async throws -> Self {
  
  try Task.checkCancellation()
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .storageCreate)
  }
  
  let url = try await context.perform { [ unowned self ] () throws -> URL in
   guard let url = self.url else {
    throw ContextError.noURL(object: self, entity: .object, operation: .storageCreate)
   }
   print (#function, url.path, id!)
   return url
  }
  
  
  if FileManager.default.fileExists(atPath: url.path)  {
   return self
   
  }
  
  fileManagerTask = Task.detached{
   try await FileManager.createDirectoryOnDisk(at: url)
  }
  
  try await fileManagerTask?.value
  
  return self
 }
 
 
}
