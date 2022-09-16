
import CoreData

@available(iOS 15.0, macOS 12.0, *)
extension Encodable where Self: NSManagedObject {
 public var jsonEncodedData: Data {
  get async throws {
   guard let context = managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .baseContent, operation: .JSONEncodingObject)
   }
   return try await context.perform { try JSONEncoder().encode(self) }
  }
 }
}


@available(iOS 15.0, macOS 12.0, *)
extension Decodable where Self: NMUndoManageable & NMFileStorageManageable {
 @discardableResult
 public static func jsonDecoded(from data: Data,
                                persist: Bool = false,
                                using context: NSManagedObjectContext) async throws -> Self {
  
  try await context.perform { () throws -> Self in
   try JSONManagedObjectContextDecoder(context: context).decode(Self.self, from: data)
  }.withRecoveredUndoManager()
   .withFileStorage()
   .persisted(persist)
  
 }
}
