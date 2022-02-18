
import Foundation

@available(iOS 13.0, *)
public extension NMBaseSnippet {
 enum SnippetType: Int16, CaseIterable, Hashable {
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
  case base  = 0 // the case for abstract entity NMBaseSnippet type
  case photo = 1 // the case for derived entity  NMPhotoSnippet type
  case video = 2 // the case for derived entity  NMVideoSnippet type
  case audio = 3 // the case for derived entity  NMAudioSnippet type
  case text  = 4 // the case for derived entity  NMTextSnippet type
  case mixed = 5 // the case for derived entity  NMMixedSnippet type
 }
 
 
}
