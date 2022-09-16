
import Foundation

public struct FolderDTO: DTORepresentable, Equatable, Hashable {
 
 public let snippetID: UUID?
 public let fields: NSDictionary
 public let elements: Set<ContentElementDTO>
 
}

extension NMContentFolder where Element: NMContentElement {
 
 @available(iOS 15.0, macOS 12.0, *)
 public var asyncDTO: FolderDTO {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .folderContentElement, operation: .gettingObjectDTO)
   }
   
   return await context.perform { self.dto }
  } //get async throws...
 }
 
 public var dto: FolderDTO {
  let fields = NSDictionary(dictionary: dictionaryWithValues(forKeys: IdentityKeys.allCases.map{$0.rawValue}))
  let elements = Set(folderedElements.map(\.dto))
  return .init(snippetID: snippet?.id ?? mixedSnippet?.id, fields: fields, elements: elements)
  
 }
 
}



