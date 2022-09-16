
import Foundation
import UIKit


extension NMContentElementsContainer where Self: NMMixedSnippet {
 
 @available(iOS 15.0, macOS 12.0, *)
 public var asyncDTO: SnippetDTO {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .mixedElementsContainer, operation: .gettingObjectDTO)
   }
   
   return await context.perform { self.dto }
  } //get async throws...
 }
 
 public var dto: SnippetDTO {
  let fields = NSDictionary(dictionary: dictionaryWithValues(forKeys: IdentityKeys.allCases.map{$0.rawValue}))
  
  let elements = Set(audioElements.filter{!$0.isFoldered}.map(\.dto) +
                     videoElements.filter{!$0.isFoldered}.map(\.dto) +
                     textsElements.filter{!$0.isFoldered}.map(\.dto) +
                     photoElements.filter{!$0.isFoldered}.map(\.dto))
                     
  
  let folders = Set(audioElementsFolders.map(\.dto)  +
                    videoElementsFolders.map(\.dto) +
                    textElementsFolders.map(\.dto)  +
                    photoElementsFolders.map(\.dto) +
                    mixedElementsFolders.map(\.dto))
  
  return .init(fields: fields, elements: elements, folders: folders)
  
 }
}
