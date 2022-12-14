
import Foundation

//MARK: Fully async methods for creating storage.

@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable {

 //MARK: Creates MO File Storage if not exists async at URL otherwise recover existing storage from recovery URL for undo operations.
 
 func withFileStorage() async throws -> Self {
  
  try Task.checkCancellation()
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .storageCreate)
  }
  
  let (url, recoveryURL) = try await context.perform { [ unowned self ] () throws -> (URL, URL)  in
   guard let url = self.url, let recoveryURL = self.recoveryURL else {
    
    print ("""
           NO URL <<<CONTEXT ERROR>>> THROWN HERE IN \(#function),
           MO URL: [\(String(describing: self.url))],
           MO RECOVERY URL: [\(String(describing: self.recoveryURL))]
           """)
    
    throw ContextError.noURL(object: self, entity: .object, operation: .storageCreate)
   }
   
   return (url, recoveryURL)
  }
  
  if FileManager.default.fileExists(atPath: url.path)  { return self }
  
  fileManagerTask = Task.detached {
   if FileManager.default.fileExists(atPath: recoveryURL.path) {
    try await FileManager.moveItemOnDisk(from: recoveryURL, to: url)
   } else {
    try await FileManager.createDirectoryOnDisk(at: url)
   }
  }
  
  try await fileManagerTask?.value
  
  return self
 }
 
 
}
