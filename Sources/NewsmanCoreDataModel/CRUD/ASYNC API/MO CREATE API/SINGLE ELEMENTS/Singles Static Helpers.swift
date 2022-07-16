
import Foundation
import CoreData

//MARK: CREATE USING STATIC ASYNC FACTORY HELPER FUNCTIONS.

@available(iOS 15.0, macOS 12.0, *)
public extension NMContentElement where Self.Snippet.Folder == Self.Folder,
                                        Self.Folder.Element == Self,
                                        Self.Snippet.Element == Self,
                                        Self.Snippet == Self.Folder.Snippet {
 
 
 @discardableResult
 static func create(snippet: Snippet, folder: Folder?, persist: Bool = true,
                    with updates: ((Self) throws -> ())? = nil) async throws -> Self {
  try await snippet.createSingle(persist: persist, in: folder, with: updates)
 }
 
 // Helper for possible recovery with existing UUID.
 @discardableResult
 static func create(with ID: UUID, snippet: Snippet, folder: Folder?, persist: Bool = true,
                    with updates: ((Self) throws -> ())? = nil) async throws -> Self {

  try await snippet.createSingle(with: ID, persist: persist, in: folder, with: updates)
 }
 
 @discardableResult
 static func create(_ N: Int, snippet: Snippet, folder: Folder?, persist: Bool = true,
                    with updates: (([Self]) throws -> ())? = nil) async throws -> [Self] {
  
  try await snippet.createSingles(persist: persist, in: folder, with: updates)
 }
 
  // Helper for possible recovery with existing UUIDs.
 @discardableResult
 static func create(with IDs: [UUID], snippet: Snippet, folder: Folder?, persist: Bool = true,
                    with updates: (([Self]) throws -> ())? = nil) async throws -> [Self] {
  
  IDs.isEmpty ? [] : try await snippet.createSingles(from: IDs, persist: persist, in: folder, with: updates)
 }
 
}
