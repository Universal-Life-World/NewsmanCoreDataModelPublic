
import Foundation
import CoreData

public protocol NMFileStorageManageable where Self: NSManagedObject
{
 var id: UUID? { get set }
}

public extension NMFileStorageManageable
{
 
 private var docFolder: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
 
 var url: URL?
 {
  get {
   guard let snippetID = self.id?.uuidString else { return nil }
   
   return docFolder.appendingPathComponent(snippetID)
  }
 }
 
 func removeFileStorage(handler: @escaping (Result<Void, Error>) -> ())
 {
  guard let url = self.url else {
   handler(.failure(ContextError.noURL(object: self, entity: .snippet, operation: .storageDelete)))
   return
  }
 
  FileManager.removeItemFromDisk(at: url, completion: handler)
 
 }
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 func removeFileStorage() async throws
 {
  guard let url = self.url else {
   throw ContextError.noURL(object: self, entity: .snippet, operation: .storageDelete)
  }
  
  try await FileManager.removeItemFromDisk(at: url)
 }
 

 
 
 func initFileStorage(handler: @escaping (Result<Void, Error>) -> ())
 {
  guard let url = self.url else {
   handler(.failure(ContextError.noURL(object: self, entity: .snippet, operation: .storageCreate)))
   return
  }
 
  FileManager.createDirectoryOnDisk(at: url, completion: handler)
 }
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 func initFileStorage() async throws
 {
  guard let url = self.url else {
   throw ContextError.noURL(object: self, entity: .snippet, operation: .storageCreate)
  }
  
  try await FileManager.createDirectoryOnDisk(at: url)
 }
 
 
}
