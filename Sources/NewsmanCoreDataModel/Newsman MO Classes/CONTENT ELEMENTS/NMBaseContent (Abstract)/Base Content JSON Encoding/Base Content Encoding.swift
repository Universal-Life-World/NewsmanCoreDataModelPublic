
extension NMBaseContent {
 
 enum CodingKeys: String, CodingKey {
  case  id, tag, date, location, geoLocation2D, /*latitude,  longitude,*/
        positions, priority, type, status,
        folderedPhotos, folderedAudios, folderedVideos, folderedTexts,
        snippet, folder, folderedElements,
        photoSnippet, audioSnippet, videoSnippet, textSnippet, mixedSnippet,
        photoFolder, audioFolder, videoFolder, textFolder, mixedFolder,
        archivedTimeStamp, arrowMenuPosition, arrowMenuScaleFactor,
        arrowMenuTouchPoint, ck_metadata, colorFlag,  hiddenSectionsBitset,
        isArrowMenuShowing, isCopyable, isDeletable,
        isDragAnimating, isDraggable, isFolderable, isHiddenFromSection,
        isRateable, isSelectable, isSelected, isTrashable,
        lastAccessedTimeStamp, lastModifiedTimeStamp, lastRatedTimeStamp,
        publishedTimeStamp, ratedCount, rating, trashedTimeStamp
        //attachedToChatItems, connectedWithTopNews
 }
 
 public func encode(to encoder: Encoder) throws {
  
  var container = encoder.container(keyedBy: CodingKeys.self)
  
  try container.encode(id,                            forKey: .id)
  try container.encode(tag,                           forKey: .tag)
  try container.encode(type,                          forKey: .type)
  try container.encode(status,                        forKey: .status)
  try container.encode(date,                          forKey: .date)
  try container.encode(geoLocation2D,                 forKey: .geoLocation2D)
  try container.encode(location,                      forKey: .location)
  try container.encode(positions,                     forKey: .positions)
  try container.encode(priority,                      forKey: .priority)
  
  try container.encode(archivedTimeStamp,             forKey: .archivedTimeStamp)
  try container.encode(arrowMenuPosition,             forKey: .arrowMenuPosition)
  try container.encode(arrowMenuScaleFactor,          forKey: .arrowMenuScaleFactor)
  try container.encode(arrowMenuTouchPoint,           forKey: .arrowMenuTouchPoint)
  try container.encode(ck_metadata,                   forKey: .ck_metadata)
  try container.encode(colorFlag?.cgColor.components, forKey: .colorFlag)
  try container.encode(hiddenSectionsBitset,          forKey: .hiddenSectionsBitset)
  try container.encode(isArrowMenuShowing,            forKey: .isArrowMenuShowing)
  try container.encode(isCopyable,                    forKey: .isCopyable)
  try container.encode(isDeletable,                   forKey: .isDeletable)
  try container.encode(isDragAnimating,               forKey: .isDragAnimating)
  try container.encode(isDraggable,                   forKey: .isDraggable)
  try container.encode(isFolderable,                  forKey: .isFolderable)
  try container.encode(isHiddenFromSection,           forKey: .isHiddenFromSection)
  try container.encode(isRateable,                    forKey: .isRateable)
  try container.encode(isSelectable,                  forKey: .isSelectable)
  try container.encode(isSelected,                    forKey: .isSelected)
  try container.encode(isTrashable,                   forKey: .isTrashable)
  try container.encode(lastAccessedTimeStamp,         forKey: .lastAccessedTimeStamp)
  try container.encode(lastModifiedTimeStamp,         forKey: .lastModifiedTimeStamp)
  try container.encode(lastRatedTimeStamp,            forKey: .lastRatedTimeStamp)
  try container.encode(publishedTimeStamp,            forKey: .publishedTimeStamp)
  try container.encode(ratedCount,                    forKey: .ratedCount)
  try container.encode(rating,                        forKey: .rating)
  try container.encode(trashedTimeStamp,              forKey: .trashedTimeStamp)
              
//  attachedToChatItems,
//  connectedWithTopNews
  
  
  switch self {
   case let photo as NMPhoto : try photo.encodeContentContainers(into: &container)
   case let video as NMVideo : try video.encodeContentContainers(into: &container)
   case let audio as NMAudio : try audio.encodeContentContainers(into: &container)
   case let text  as NMText  : try  text.encodeContentContainers(into: &container)
    
   case let folder as NMPhotoFolder : try folder.encodeElementsAndSnippet(into: &container)
   case let folder as NMTextFolder  : try folder.encodeElementsAndSnippet(into: &container)
   case let folder as NMVideoFolder : try folder.encodeElementsAndSnippet(into: &container)
   case let folder as NMAudioFolder : try folder.encodeElementsAndSnippet(into: &container)
   case let folder as NMMixedFolder : try folder.encodeElementsAndSnippet(into: &container)
    
   default: break
  }
  
 }
 
}



