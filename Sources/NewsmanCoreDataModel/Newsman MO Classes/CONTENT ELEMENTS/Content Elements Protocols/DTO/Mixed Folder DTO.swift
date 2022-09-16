

import Foundation

extension NMContentFolder where Self: NMMixedFolder {
 
 @available(iOS 15.0, macOS 12.0, *)
 public var asyncDTO: FolderDTO {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .mixedContentFolder, operation: .gettingObjectDTO)
   }
   
   return await context.perform { self.dto }
  } //get async throws...
 }
 
 public var dto: FolderDTO {
  let fields = NSDictionary(dictionary: dictionaryWithValues(forKeys: IdentityKeys.allCases.map{$0.rawValue}))
  let mixedElements = Set(audios.map(\.dto) + videos.map(\.dto) + texts.map(\.dto) + photos.map(\.dto))
  return .init(snippetID: mixedSnippet?.id, fields: fields, elements: mixedElements)
  
 }
}
