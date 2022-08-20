import CoreData

@available(iOS 15.0, macOS 12.0, *)
extension NMBaseContent {
 
// public var jsonEncodedData: Data {
//  get async throws {
//   guard let context = managedObjectContext else {
//    throw ContextError.noContext(object: self, entity: .baseContent, operation: .JSONEncodingObject)
//   }
//   return try await context.perform { try JSONEncoder().encode(self) }
//  }
// }
 
 
// @discardableResult
// public static func jsonDecoded(from data: Data,
//                                persist: Bool = false,
//                                using context: NSManagedObjectContext) async throws -> Self {
//  
//  try await context.perform { () throws -> Self in
//   try JSONManagedObjectContextDecoder(context: context).decode(Self.self, from: data)
//  }
//  .withFileStorage()
//  .persisted(persist)
//  
// }
 
}
