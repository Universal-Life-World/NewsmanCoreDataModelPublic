
import Foundation
import CoreData

public protocol NMFileStorageManageable where Self: NSManagedObject
{
 var id: UUID? { get }
 var url: URL? { get }
}


//MARK: Extesion URL getter for Snippets classes.
@available(iOS 13.0, *)
public extension NMFileStorageManageable where Self: NMBaseSnippet
{
 var url: URL? {
  get {
   guard let snippetID = self.id?.uuidString else { return nil }
   return docFolder.appendingPathComponent(snippetID)
  }
 }
}


//MARK: Block based async methods for creating and deleting file storage.
public extension NMFileStorageManageable
{
 private var docFolder: URL {
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


//MARK: Fully async methods for creating and deleting file storage.

@available(iOS 15.0, *)
@available(macOS 12.0.0, *)
public extension NMFileStorageManageable
{
 func removeFileStorage() async throws {
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .storageDelete )
  }
  
  
  let url = try await context.perform { [ unowned self ] () throws -> URL in
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
 }
 
 func withFileStorage() async throws -> Self {
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .storageCreate)
  }
  
  let url = try await context.perform { [ unowned self ] () throws -> URL in
   guard let url = self.url else {
    throw ContextError.noURL(object: self, entity: .object, operation: .storageCreate)
   }
   return url
  }
  
  if FileManager.default.fileExists(atPath: url.path)  { return self }
  
  try await FileManager.createDirectoryOnDisk(at: url)
  
  return self
 }
}
