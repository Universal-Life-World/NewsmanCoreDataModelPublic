
import Foundation
import CoreData

public protocol NMFileStorageManageable where Self: NSManagedObject {
 var id: UUID? { get }
 var url: URL? { get }
 var fileManagerTask: Task<Void, Error>? { get set }
 func fileManagerTaskGroup() async throws
 
}

@available(iOS 13.0, *)
public extension NMFileStorageManageable where Self: NMBaseSnippet {
 var url: URL? {
  get {
   guard let snippetID = id?.uuidString else { return nil }
   return docFolder.appendingPathComponent(snippetID)
  }
 }
}



