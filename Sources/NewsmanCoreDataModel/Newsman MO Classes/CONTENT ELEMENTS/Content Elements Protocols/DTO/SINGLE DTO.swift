
import Foundation

public struct ContentElementDTO: DTORepresentable, Equatable, Hashable {
 
 public let fields: NSDictionary
 
 public let snippetID: UUID?
 public let folderID: UUID?
 
}


extension NMContentElement {
 @available(iOS 15.0, macOS 12.0, *)
 public var asyncDTO: ContentElementDTO {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .singleContentElement, operation: .gettingObjectDTO)
   }
   
   return await context.perform { self.dto }
  } //get async throws...
 }
 
 public var dto: ContentElementDTO {
  let fields = NSDictionary(dictionary: dictionaryWithValues(forKeys: IdentityKeys.allCases.map{$0.rawValue}))
  return  .init(fields: fields,
                snippetID: snippet?.id ?? mixedSnippet?.id,
                folderID:  folder?.id ?? mixedFolder?.id )
     
 }
 
}
