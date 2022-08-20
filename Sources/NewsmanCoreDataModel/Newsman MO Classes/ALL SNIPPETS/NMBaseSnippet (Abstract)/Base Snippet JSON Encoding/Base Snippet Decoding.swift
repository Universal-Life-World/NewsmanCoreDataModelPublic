import CoreData
import CoreLocation

extension NMBaseSnippet {
 
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
  try decodeValueSilently(Int16.self,  from: container, forKey: .hiddenSectionsBitset     )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isDeletable              )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isDragAnimating          )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isDraggable              )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isHiddenFromSection      )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isSelected               )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isTrashable              )
  try decodeValueSilently(Int16.self,  from: container, forKey: .hiddenSectionsBitset     )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isHiddenFromSection      )
  try decodeValueSilently(Bool.self,   from: container, forKey: .isHideableFromSection    )
  
  
  silentStatus              = try container.decode(SnippetStatus.self,           forKey:  .status)
  silentNameTag             = try container.decode(String?.self,                 forKey:  .nameTag)
  silentGeoLocation2D       = try container.decode(CLLocationCoordinate2D?.self, forKey:  .geoLocation2D)
  silentLocation            = try container.decode(String?.self,                 forKey:  .location)
  silentPriority            = try container.decode(SnippetPriority.self,         forKey:  .priority)
  silentPublishedTimeStamp  = try container.decode(Date?.self,                   forKey:  .publishedTimeStamp )
  silentTrashedTimeStamp    = try container.decode(Date?.self,                   forKey:  .trashedTimeStamp   )
  silentArchivedTimeStamp   = try container.decode(Date?.self,                   forKey:  .archivedTimeStamp  )
  silentCKMetadata          = try container.decode(Data?.self,                   forKey:  .ck_metadata        )
  
  silentSectionDateIndexGroup = DateGroup.current(of: date!, at: Date())
  
  
  
  
  


//  switch self {
//
//   case let element as NMPhoto:  try element.decodeIntoExistingFolder(from: container, into: context)
//   case let element as NMVideo:  try element.decodeIntoExistingFolder(from: container, into: context)
//   case let element as NMAudio:  try element.decodeIntoExistingFolder(from: container, into: context)
//   case let element as NMText:   try element.decodeIntoExistingFolder(from: container, into: context)
//
//   case let folder as NMPhotoFolder: try folder.decodeIntoExisitingSnippet(from: container, into: context)
//   case let folder as NMAudioFolder: try folder.decodeIntoExisitingSnippet(from: container, into: context)
//   case let folder as NMTextFolder:  try folder.decodeIntoExisitingSnippet(from: container, into: context)
//   case let folder as NMVideoFolder: try folder.decodeIntoExisitingSnippet(from: container, into: context)
//   case let folder as NMMixedFolder: try folder.decodeIntoExisitingSnippet(from: container, into: context)
//
//   default: break
//
//  }
 }
}



