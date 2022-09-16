import CoreData
import CoreLocation
import CoreGraphics

extension NMBaseContent {
 
 func decodeValueSilently<T: Decodable>(_ type: T.Type,
                                        from container: KeyedDecodingContainer<CodingKeys>,
                                        forKey codingKey: CodingKeys) throws {
  
  setPrimitiveValue(try container.decode(T.self, forKey: codingKey), forKey: codingKey.rawValue)
 }
 
 
 func decode(from container: KeyedDecodingContainer<CodingKeys>, into context: NSManagedObjectContext) throws {
  
  try decodeValueSilently(UUID?.self,  from: container, forKey: .id                       )

  try decodeValueSilently(Date?.self,  from: container, forKey: .date                     )
  try decodeValueSilently(Date?.self,  from: container, forKey: .lastAccessedTimeStamp    )
  try decodeValueSilently(Date?.self,  from: container, forKey: .lastModifiedTimeStamp    )
  try decodeValueSilently(Double.self, from: container, forKey: .arrowMenuScaleFactor     )
  try decodeValueSilently(Int16.self,  from: container, forKey: .hiddenSectionsBitset     )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isArrowMenuShowing       )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isCopyable               )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isDeletable              )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isDragAnimating          )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isDraggable              )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isFolderable             )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isHiddenFromSection      )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isRateable               )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isSelectable             )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isSelected               )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isTrashable              )
  try decodeValueSilently(Double.self, from: container, forKey: .rating                   )
  try decodeValueSilently(Int64.self,  from: container, forKey: .ratedCount               )
                        
  silentStatus              = try container.decode(ContentStatus.self,           forKey:  .status)
  silentTag                 = try container.decode(String?.self,                 forKey:  .tag)
  silentGeoLocation2D       = try container.decode(CLLocationCoordinate2D?.self, forKey:  .geoLocation2D)
  silentLocation            = try container.decode(String?.self,                 forKey:  .location)
  silentPositions           = try container.decode(TContentPositions?.self,      forKey:  .positions)
  silentPriority            = try container.decode(ContentPriority.self,         forKey:  .priority)
  silentArrowMenuPosition   = try container.decode(CGPoint?.self,                forKey:  .arrowMenuPosition)
  silentArrowMenuTouchPoint = try container.decode(CGPoint?.self,                forKey:  .arrowMenuTouchPoint)
  
  silentPublishedTimeStamp  = try container.decode(Date?.self,                   forKey:  .publishedTimeStamp )
  silentTrashedTimeStamp    = try container.decode(Date?.self,                   forKey:  .trashedTimeStamp   )
  silentLastRatedTimeStamp  = try container.decode(Date?.self,                   forKey:  .lastRatedTimeStamp )
  silentArchivedTimeStamp   = try container.decode(Date?.self,                   forKey:  .archivedTimeStamp  )
  silentCKMetadata          = try container.decode(Data?.self,                   forKey:  .ck_metadata        )
  
  decodeColorFlagSilenty(from: container)

  switch self {
    
   case let element as NMPhoto:  try element.decodeIntoExistingFolder(from: container, into: context)
   case let element as NMVideo:  try element.decodeIntoExistingFolder(from: container, into: context)
   case let element as NMAudio:  try element.decodeIntoExistingFolder(from: container, into: context)
   case let element as NMText:   try element.decodeIntoExistingFolder(from: container, into: context)
    
   case let folder as NMPhotoFolder: try folder.decodeIntoExisitingSnippet(from: container, into: context)
   case let folder as NMAudioFolder: try folder.decodeIntoExisitingSnippet(from: container, into: context)
   case let folder as NMTextFolder:  try folder.decodeIntoExisitingSnippet(from: container, into: context)
   case let folder as NMVideoFolder: try folder.decodeIntoExisitingSnippet(from: container, into: context)
   case let folder as NMMixedFolder: try folder.decodeIntoExisitingSnippet(from: container, into: context)
    
   default: break
    
  }
 }
}



