import CoreData
import CoreLocation

extension NMBaseSnippet {
 
 func decodeValueSilently<T: Decodable>(_ type: T.Type,
                                        from container: KeyedDecodingContainer<CodingKeys>,
                                        forKey codingKey: CodingKeys) throws {
  
  setPrimitiveValue(try container.decode(T.self, forKey: codingKey), forKey: codingKey.rawValue)
 }
 
 
 func decode(from container: KeyedDecodingContainer<CodingKeys>,
             into context: NSManagedObjectContext) throws {
  
  //(1) Main group **********************************************************************************
  try decodeValueSilently(UUID?.self,  from: container, forKey: .id                           )  //D11
  try decodeValueSilently(Date?.self,  from: container, forKey: .date                         )  //D12
  
  silentStatus           = try container.decode(SnippetStatus.self,       forKey:  .status)      //D13
  silentNameTag          = try container.decode(String?.self,             forKey:  .nameTag)     //D14
  
  //type decoded before in public required convenience init(from decoder: Decoder) throws        //D15
  
  silentGeoLocation2D    = try container.decode(CLLocationCoordinate2D?.self,
                                                forKey:  .geoLocation2D)                         //D16
  
  silentLocation         = try container.decode(String?.self,             forKey:  .location)    //D17
  silentPriority         = try container.decode(SnippetPriority.self,     forKey:  .priority)    //D18
  silentAbout            = try container.decode(String?.self,             forKey:  .about)       //D19
  silentCKMetadata       = try container.decode(Data?.self,               forKey:  .ck_metadata) //D110
  
  try decodeValueSilently(Int16.self,  from: container, forKey: .hiddenSectionsBitset )          //D111
  //*************************************************************************************************
  
  //(2) time stamps group **************************************************************************
  try decodeValueSilently(Date?.self, from: container, forKey: .lastAccessedTimeStamp       ) //D21
  try decodeValueSilently(Date?.self, from: container, forKey: .lastModifiedTimeStamp       ) //D22
  
  silentPublishedTimeStamp  = try container.decode(Date?.self,  forKey:  .publishedTimeStamp ) //D23
  silentTrashedTimeStamp    = try container.decode(Date?.self,  forKey:  .trashedTimeStamp   ) //D24
  silentArchivedTimeStamp   = try container.decode(Date?.self,  forKey:  .archivedTimeStamp  ) //D25
  //************************************************************************************************
  
  //(3) is...able to do group ***********************************************************************
  try decodeValueSilently(Bool.self, from: container, forKey: .isDeletable                  ) //D31
  try decodeValueSilently(Bool.self, from: container, forKey: .isDragAnimating              ) //D32
  try decodeValueSilently(Bool.self, from: container, forKey: .isDraggable                  ) //D33
  try decodeValueSilently(Bool.self, from: container, forKey: .isTrashable                  ) //D34
  try decodeValueSilently(Bool.self, from: container, forKey: .isHiddenFromSection          ) //D35
  try decodeValueSilently(Bool.self, from: container, forKey: .isHideableFromSection        ) //D36
  try decodeValueSilently(Bool.self, from: container, forKey: .isSelected                   ) //D37
  try decodeValueSilently(Bool.self, from: container, forKey: .isContentCopyable            ) //D38
  try decodeValueSilently(Bool.self, from: container, forKey: .isContentEditable            ) //D39
  try decodeValueSilently(Bool.self, from: container, forKey: .isContentPublishable         ) //D310
  try decodeValueSilently(Bool.self, from: container, forKey: .isContentSharable            ) //D311
  try decodeValueSilently(Bool.self, from: container, forKey: .isMergeable                  ) //D312
  try decodeValueSilently(Bool.self, from: container, forKey: .isShowingSnippetDetailedCell ) //D313
  //*************************************************************************************************
  
  //(4) Index fields group **************************************************************************
  silentSectionDateIndexGroup = DateGroup.current(of: date!, at: Date())    //D41
  //*************************************************************************************************
  
  //(5) UI elements reflection group ****************************************************************
  silentContentElementsGroupingType = try container.decode(ContentGroupType.self,
                                                           forKey: .contentElementsGroupingType) //D51
  
  
  try decodeValueSilently(Int16.self, from: container, forKey: .contentElementsInRow)            //D52
  try decodeValueSilently(Bool.self,  from: container, forKey: .showsContentElementsPositions)   //D53
  try decodeValueSilently(Bool.self,  from: container, forKey: .showsHiddenContentElements)      //D54
  
  //*************************************************************************************************
  
  switch self {

   case let snippet as NMPhotoSnippet: try  snippet.decodeContentElements(from: container, into: context)
   case let snippet as NMAudioSnippet: try  snippet.decodeContentElements(from: container, into: context)
   case let snippet as NMTextSnippet:  try  snippet.decodeContentElements(from: container, into: context)
   case let snippet as NMVideoSnippet: try  snippet.decodeContentElements(from: container, into: context)
   case let snippet as NMMixedSnippet: try  snippet.decodeContentElements(from: container, into: context)

   default: break

  }
 }
}



