extension NMBaseSnippet {
 
 enum CodingKeys: String, CodingKey {
  case  id, status, type, nameTag, date, geoLocation2D, location, /* longitude, latitude,*/
        about, priority, archivedTimeStamp, ck_metadata, hiddenSectionsBitset,
        folders,//, photoFolders, textFolders, audioFolders, videoFolders, mixedFolders,
        singleElements,//, photos, texts, audios, videos,
        contentElementsGroupingType, contentElementsSortingType, contentElementsSortOrder,
        isDeletable, isDragAnimating, isDraggable, isHiddenFromSection, isHideableFromSection,
        isSelected, contentElementsInRow, dateSearchFormatIndex, isTrashable,
        lastAccessedTimeStamp, lastModifiedTimeStamp, trashedTimeStamp, publishedTimeStamp,
        isContentCopyable, isContentEditable, isContentPublishable, isContentSharable, isMergeable,
        isShowingSnippetDetailedCell, sectionAlphaIndex, sectionPriorityIndex, sectionTypeIndex,
        showsContentElementsPositions, showsHiddenContentElements
  // connectedWithTopNews
 }
 
 public func encode(to encoder: Encoder) throws {
  
  var container = encoder.container(keyedBy: CodingKeys.self)
  
  //(1) main group ******************************************************************************
  try container.encode(id,                                 forKey: .id)                   //E11
  try container.encode(date,                               forKey: .date)                 //E12
  try container.encode(status,                             forKey: .status)               //E13
  try container.encode(nameTag,                            forKey: .nameTag)              //E14
  try container.encode(type,                               forKey: .type)                 //E15
  try container.encode(geoLocation2D,                      forKey: .geoLocation2D)        //E16
  try container.encode(location,                           forKey: .location)             //E17
  try container.encode(priority,                           forKey: .priority)             //E18
  try container.encode(about,                              forKey: .about)                //E19
  try container.encode(ck_metadata,                        forKey: .ck_metadata)          //E110
  try container.encode(hiddenSectionsBitset,               forKey: .hiddenSectionsBitset) //E111
  //*********************************************************************************************
  
  //(2) time stamps group ***********************************************************************
  try container.encode(lastAccessedTimeStamp,              forKey: .lastAccessedTimeStamp) //E21
  try container.encode(lastModifiedTimeStamp,              forKey: .lastModifiedTimeStamp) //E22
  try container.encode(publishedTimeStamp,                 forKey: .publishedTimeStamp)    //E23
  try container.encode(trashedTimeStamp,                   forKey: .trashedTimeStamp)      //E24
  try container.encode(archivedTimeStamp,                  forKey: .archivedTimeStamp)     //E25
  //*********************************************************************************************
  
  //(3) is...able to do group *******************************************************************
  try container.encode(isDeletable,                        forKey: .isDeletable)           //E31
  try container.encode(isDragAnimating,                    forKey: .isDragAnimating)       //E32
  try container.encode(isDraggable,                        forKey: .isDraggable)           //E33
  try container.encode(isTrashable,                        forKey: .isTrashable)           //E34
  try container.encode(isHiddenFromSection,                forKey: .isHiddenFromSection)   //E35
  try container.encode(isHideableFromSection,              forKey: .isHideableFromSection) //E36
  try container.encode(isSelected,                         forKey: .isSelected)            //E37
  try container.encode(isContentCopyable,                  forKey: .isContentCopyable)     //E38
  try container.encode(isContentEditable,                  forKey: .isContentEditable)     //E39
  try container.encode(isContentPublishable,               forKey: .isContentPublishable)  //E310
  try container.encode(isContentSharable,                  forKey: .isContentSharable)     //E311
  try container.encode(isMergeable,                        forKey: .isMergeable)           //E312
  try container.encode(isShowingSnippetDetailedCell,       forKey: .isShowingSnippetDetailedCell) //E313
  //*********************************************************************************************
  
  //(4) Index fields group **********************************************************************
  //try container.encode(sectionAlphaIndex,                  forKey: .sectionAlphaIndex)      //E41
  //try container.encode(sectionPriorityIndex,               forKey: .sectionPriorityIndex)   //E42
  //try container.encode(sectionTypeIndex,                   forKey: .sectionTypeIndex)       //E43
  //try container.encode(dateSearchFormatIndex,              forKey: .dateSearchFormatIndex)  //E44
  //SectionDateIndex is not encoded!
  //*********************************************************************************************
  
  //(5) UI elements reflection group ************************************************************
  try container.encode(contentElementsGroupingType,        forKey: .contentElementsGroupingType) //E51
  try container.encode(contentElementsInRow,               forKey: .contentElementsInRow)        //E52
  //try container.encode(contentElementsSortingType,         forKey: .contentElementsSortingType)
  //try container.encode(contentElementsSortOrder,           forKey: .contentElementsSortOrder)
  try container.encode(showsContentElementsPositions,      forKey: .showsContentElementsPositions) //E53
  try container.encode(showsHiddenContentElements,         forKey: .showsHiddenContentElements)    //E54
 //**********************************************************************************************
  
  
   //  attachedToChatItems,
   //  connectedWithTopNews
  
  
  switch self {
  
   case let snippet as NMPhotoSnippet : try snippet.encodeContentElements(into: &container)
   case let snippet as NMTextSnippet  : try snippet.encodeContentElements(into: &container)
   case let snippet as NMVideoSnippet : try snippet.encodeContentElements(into: &container)
   case let snippet as NMAudioSnippet : try snippet.encodeContentElements(into: &container)
   case let snippet as NMMixedSnippet : try snippet.encodeContentElements(into: &container)

   default: break
  }
  
 }
 
}



