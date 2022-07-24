import Foundation

@available(iOS 13.0, *)
public extension NMBaseContent {
 @objc enum ContentType: Int16, CaseIterable, Hashable, Codable {
  init(contentElement: NMBaseContent) {
   switch contentElement {
    case is NMPhoto:       self = .photo
    case is NMPhotoFolder: self = .photoFolder
     
    case is NMAudio:       self = .audio
    case is NMAudioFolder: self = .audioFolder
     
    case is NMVideo:       self = .video
    case is NMVideoFolder: self = .videoFolder
     
    case is NMText:        self = .text
    case is NMTextFolder:  self = .textFolder
     
    case is NMMixedFolder: self = .mixedFolder
     
    default: self = .baseContent
   }
  }
  
  
  case baseContent  = 0 // the case for abstract
  
  case photo = 1 // the case for derived
  case photoFolder = 2 // the case for derived
  
  case video = 3 // the case for derived
  case videoFolder = 4 // the case for derived
  
  case audio = 5 // the case for derived
  case audioFolder = 6 // the case for derived
  
  case text  = 7 // the case for derived
  case textFolder  = 8 // the case for derived
  
  case mixedFolder = 9 // the case for derived
 }
 
 
}
