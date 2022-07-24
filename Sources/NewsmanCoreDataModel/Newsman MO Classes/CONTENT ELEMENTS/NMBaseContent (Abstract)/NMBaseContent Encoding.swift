
import CoreData

extension CodingUserInfoKey {
 public static let managedObjectContext = Self.init(rawValue: "managedObjectContext")!
 public static let modelBackgroundContextKey = Self.init(rawValue: "modelBackgroundContext")!
}

extension NMBaseContent {
 
 enum CodingKeys: String, CodingKey {
  case  id, nameTag, date, latitude, location, longitude, positions, priority, type,
        folderedPhotos, folderedAudios, folderedVideos, folderedTexts,
        archivedTimeStamp, arrowMenuPosition, arrowMenuScaleFactor,
        arrowMenuTouchPoint, ck_metadata, colorFlag,  hiddenSectionsBitset,
        isArrowMenuShowing, isCopyable, isDeletable,
        isDragAnimating, isDraggable, isFolderable, isHiddenFromSection,
        isRateable, isSelectable, isSelected, isTrashable,
        lastAccessedTimeStamp, lastModifiedTimeStamp, lastRatedTimeStamp,
        publishedTimeStamp,ratedCount, rating, trashedTimeStamp,
        attachedToChatItems, connectedWithTopNews
 }
 
 public func encode(to encoder: Encoder) throws {
  var container = encoder.container(keyedBy: CodingKeys.self)
  try container.encode(id, forKey: .id)
  try container.encode(tag, forKey: .nameTag)
  try container.encode(type, forKey: .type)
  try container.encode(date, forKey: .date)
  try container.encode(latitude?.doubleValue, forKey: .latitude)
  try container.encode(longitude?.doubleValue, forKey: .longitude)
  try container.encode(location, forKey: .location)
  try container.encode(positions, forKey: .positions)
  try container.encode(priority, forKey: .priority)
  
  
  switch self  {
   case let folder as NMPhotoFolder: try container.encode(folder.folderedElements, forKey: .folderedPhotos)
   case let folder as NMTextFolder:  try container.encode(folder.folderedElements, forKey: .folderedTexts )
   case let folder as NMVideoFolder: try container.encode(folder.folderedElements, forKey: .folderedVideos)
   case let folder as NMAudioFolder: try container.encode(folder.folderedElements, forKey: .folderedAudios)
   case let folder as NMMixedFolder:
    try container.encode(folder.audios, forKey: .folderedAudios)
    try container.encode(folder.videos, forKey: .folderedVideos)
    try container.encode(folder.photos, forKey: .folderedPhotos)
    try container.encode(folder.texts,  forKey: .folderedTexts )
    
   default: break
  }
  
 }
 
 internal func decode(using decoder: Decoder) throws {
  let container = try decoder.container(keyedBy: CodingKeys.self)
  self.primitiveId = try container.decode(UUID.self, forKey: .id)
  self.tag = try container.decode(String.self, forKey: .nameTag)
  
 }
}



