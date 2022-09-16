
import Foundation


@available(iOS 15.0, macOS 12.0, *)
extension NMContentFolder where Self.Element: NMContentElement,
                                Self.Element == Snippet.Element,
                                Self.Element.Folder == Self,
                                Self.Snippet.Folder == Self,
                                Self.Element.Snippet == Self.Snippet {
 @discardableResult
 static func create(snippet: Snippet, persist: Bool = true,
                    with updates: ((Self) throws -> ())? = nil) async throws -> Self {
  
  try await snippet.createFolder(persist: persist, with: updates)
 }
 
  // Helper for possible recovery with existing UUID.
 @discardableResult
 static func create(with ID: UUID, snippet: Snippet, persist: Bool = true,
                    with updates: ((Self) throws -> ())? = nil) async throws -> Self
  where Self: NMUndoManageable & NMFileStorageManageable{
  
  try await snippet.createFolder(with: ID, persist: persist, with: updates)
 }
 
 @discardableResult
 static func create(_ N: Int, snippet: Snippet, persist: Bool = true,
                    with updates: (([Self]) throws -> ())? = nil) async throws -> [Self] {
  
  try await snippet.createFolders(persist: persist, with: updates)
 }
 
  // Helper for possible recovery with existing UUIDs.
 @discardableResult
 static func create(with IDs: [UUID], snippet: Snippet, persist: Bool = true,
                    with updates: (([Self]) throws -> ())? = nil) async throws -> [Self] {
  
  IDs.isEmpty ? [] : try await snippet.createFolders(from: IDs, persist: persist, with: updates)
 }
}


