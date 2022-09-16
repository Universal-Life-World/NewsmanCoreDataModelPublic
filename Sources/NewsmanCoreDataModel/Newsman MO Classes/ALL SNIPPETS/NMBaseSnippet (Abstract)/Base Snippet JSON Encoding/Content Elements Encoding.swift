
import CoreData

extension NMContentElementsContainer {
 func encodeContentElements(into container: inout KeyedEncodingContainer<CodingKeys>) throws {
  try container.encode(folders, forKey: .folders)
  try container.encode(singleContentElements, forKey: .singleElements)
 }
 
 func decodeContentElements(from container: KeyedDecodingContainer<CodingKeys>,
                            into context: NSManagedObjectContext) throws {
  
  _ = try container.decode([Folder].self,  forKey: .folders)
  _ = try container.decode([Element].self, forKey: .singleElements)
  
 }
 
}




