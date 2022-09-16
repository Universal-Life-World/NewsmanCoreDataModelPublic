
import Foundation

public struct SnippetDTO: DTORepresentable, Equatable, Hashable {
 public let fields: NSDictionary
 public let elements: Set<ContentElementDTO>
 public let folders: Set<FolderDTO>
 
}

extension NMContentElementsContainer
 where Element: NMContentElement,
       Folder.Element == Element,
       Element.Snippet == Folder.Snippet,
       Self == Element.Snippet,
       Folder == Element.Folder {
        
 @available(iOS 15.0, macOS 12.0, *)
 public var asyncDTO: SnippetDTO {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentElementContainer, operation: .gettingObjectDTO)
   }
   
   return await context.perform { self.dto }
  } //get async throws...
 }
 
 public var dto: SnippetDTO {
  let fields = NSDictionary(dictionary: dictionaryWithValues(forKeys: IdentityKeys.allCases.map{$0.rawValue}))
  let folders = Set(folders.map(\.dto))
  let elements = Set(unfolderedContentElements.map(\.dto))
  return .init(fields: fields, elements: elements, folders: folders)
  
 }
 
}
