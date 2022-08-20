
import CoreData

@available(iOS 13.0, *)
public extension NMBaseSnippet {
@objc enum SnippetType: Int16, CaseIterable, Hashable, Codable {
  init(snippet: NMBaseSnippet) {
   switch snippet {
    case is NMPhotoSnippet: self = .photo
    case is NMAudioSnippet: self = .audio
    case is NMVideoSnippet: self = .video
    case is NMTextSnippet:  self = .text
    case is NMMixedSnippet: self = .mixed
    default: self = .base
   }
  }
  
 public var entity: NSEntityDescription { Self.entityDescriptionsMap[self]! }
 
 private static let entityDescriptionsMap : [Self : NSEntityDescription ] = [
  .base          :   NMBaseSnippet.entity(),
  .photo         :   NMPhotoSnippet.entity(),
  .audio         :   NMAudioSnippet.entity(),
  .video         :   NMVideoSnippet.entity(),
  .text          :   NMTextSnippet.entity(),
  .mixed         :   NMMixedSnippet.entity()
 ]
 

  case base  = 0 // the case for abstract entity NMBaseSnippet type
  case photo = 1 // the case for derived entity  NMPhotoSnippet type
  case video = 2 // the case for derived entity  NMVideoSnippet type
  case audio = 3 // the case for derived entity  NMAudioSnippet type
  case text  = 4 // the case for derived entity  NMTextSnippet type
  case mixed = 5 // the case for derived entity  NMMixedSnippet type
 }
 
 
}


