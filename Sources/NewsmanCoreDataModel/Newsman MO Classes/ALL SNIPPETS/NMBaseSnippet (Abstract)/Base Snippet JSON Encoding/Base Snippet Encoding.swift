extension NMBaseSnippet {
 
 enum CodingKeys: String, CodingKey {
  case  id, status, type, nameTag, date, location, longitude, latitude, about, priority,
        archivedTimeStamp, ck_metadata, hiddenSectionsBitset, geoLocation2D,
        contentElementsGroupingType, contentElementsSortingType, contentElementsSortOrder,
        isDeletable, isDragAnimating, isDraggable, isHiddenFromSection, isHideableFromSection,
        isSelected, contentElementsInRow, dateSearchFormatIndex, isTrashable,
        lastAccessedTimeStamp, lastModifiedTimeStamp,trashedTimeStamp, publishedTimeStamp,
        isContentCopyable, isContentEditable, isContentPublishable, isContentSharable, isMergeable,
        isShowingSnippetDetailedCell, sectionAlphaIndex, sectionPriorityIndex, sectionTypeIndex,
        showsContentElementsPositions, showsHiddenContentElements
  // connectedWithTopNews
 }
 
 public func encode(to encoder: Encoder) throws {
  
  var container = encoder.container(keyedBy: CodingKeys.self)
  
  //main group ******************************************************************************
  try container.encode(id,                                 forKey: .id)
  try container.encode(status,                             forKey: .status)
  try container.encode(nameTag,                            forKey: .nameTag)
  try container.encode(type,                               forKey: .type)
  try container.encode(date,                               forKey: .date)
  try container.encode(geoLocation2D,                      forKey: .geoLocation2D)
  try container.encode(location,                           forKey: .location)
  try container.encode(priority,                           forKey: .priority)
  try container.encode(about,                              forKey: .about)
  try container.encode(ck_metadata,                        forKey: .ck_metadata)
  try container.encode(hiddenSectionsBitset,               forKey: .hiddenSectionsBitset)
  //*****************************************************************************************
  
  //time stamps group ***********************************************************************
  try container.encode(lastAccessedTimeStamp,              forKey: .lastAccessedTimeStamp)
  try container.encode(lastModifiedTimeStamp,              forKey: .lastModifiedTimeStamp)
  try container.encode(publishedTimeStamp,                 forKey: .publishedTimeStamp)
  try container.encode(trashedTimeStamp,                   forKey: .trashedTimeStamp)
  //*****************************************************************************************
  
  //is...able to do group *******************************************************************
  try container.encode(isDeletable,                        forKey: .isDeletable)
  try container.encode(isDragAnimating,                    forKey: .isDragAnimating)
  try container.encode(isDraggable,                        forKey: .isDraggable)
  try container.encode(isTrashable,                        forKey: .isTrashable)
  try container.encode(isHiddenFromSection,                forKey: .isHiddenFromSection)
  try container.encode(isHideableFromSection,              forKey: .isHideableFromSection)
  try container.encode(isSelected,                         forKey: .isSelected)
  try container.encode(isContentCopyable,                  forKey: .isContentCopyable)
  try container.encode(isContentEditable,                  forKey: .isContentEditable)
  try container.encode(isContentPublishable,               forKey: .isContentPublishable)
  try container.encode(isContentSharable,                  forKey: .isContentSharable)
  try container.encode(isMergeable,                        forKey: .isMergeable)
  try container.encode(isShowingSnippetDetailedCell,       forKey: .isShowingSnippetDetailedCell)
  //*********************************************************************************************
  
  //Index fields group **************************************************************************
  try container.encode(sectionAlphaIndex,                  forKey: .sectionAlphaIndex)
  try container.encode(sectionPriorityIndex,               forKey: .sectionPriorityIndex)
  try container.encode(sectionTypeIndex,                   forKey: .sectionTypeIndex)
  //*********************************************************************************************
  
  //UI elements reflection group ****************************************************************
  try container.encode(contentElementsSortingType,         forKey: .contentElementsGroupingType)
  try container.encode(contentElementsInRow,               forKey: .contentElementsInRow)
  try container.encode(dateSearchFormatIndex,              forKey: .dateSearchFormatIndex)
  try container.encode(contentElementsSortingType,         forKey: .contentElementsSortingType)
  try container.encode(contentElementsSortOrder,           forKey: .contentElementsSortOrder)
  try container.encode(archivedTimeStamp,                  forKey: .archivedTimeStamp)
  try container.encode(showsContentElementsPositions,      forKey: .showsContentElementsPositions)
  try container.encode(showsHiddenContentElements,         forKey: .showsHiddenContentElements)
 //*********************************************************************************************
  
  
   //  attachedToChatItems,
   //  connectedWithTopNews
  
  
//  switch self {
//   case let photo as NMPhoto : try photo.encodeContentContainers(into: &container)
//   case let video as NMVideo : try video.encodeContentContainers(into: &container)
//   case let audio as NMAudio : try audio.encodeContentContainers(into: &container)
//   case let text  as NMText  : try  text.encodeContentContainers(into: &container)
//
//   case let folder as NMPhotoFolder : try folder.encodeElementsAndSnippet(into: &container)
//   case let folder as NMTextFolder  : try folder.encodeElementsAndSnippet(into: &container)
//   case let folder as NMVideoFolder : try folder.encodeElementsAndSnippet(into: &container)
//   case let folder as NMAudioFolder : try folder.encodeElementsAndSnippet(into: &container)
//   case let folder as NMMixedFolder : try folder.encodeElementsAndSnippet(into: &container)
//
//   default: break
//  }
  
 }
 
}



