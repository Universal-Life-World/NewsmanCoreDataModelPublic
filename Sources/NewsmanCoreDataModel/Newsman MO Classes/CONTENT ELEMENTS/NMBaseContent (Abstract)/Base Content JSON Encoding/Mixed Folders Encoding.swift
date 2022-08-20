
import CoreData

extension NMContentFolder where Self: NMMixedFolder {
 
 func encodeElementsAndSnippet(into container: inout KeyedEncodingContainer<CodingKeys>) throws {
  try container.encode(audios, forKey: .folderedAudios)
  try container.encode(videos, forKey: .folderedVideos)
  try container.encode(photos, forKey: .folderedPhotos)
  try container.encode(texts,  forKey: .folderedTexts )
  try container.encode(mixedSnippet?.id, forKey: .mixedSnippet)
 }
 
 func decodeIntoExisitingSnippet(from container: KeyedDecodingContainer<CodingKeys>,
                                 into context: NSManagedObjectContext) throws {
  
  let photos = try container.decode([NMPhoto].self, forKey: .folderedPhotos)
  let audios = try container.decode([NMAudio].self, forKey: .folderedAudios)
  let texts =  try container.decode([NMText ].self, forKey: .folderedTexts)
  let videos = try container.decode([NMVideo].self, forKey: .folderedVideos)
  
  guard let snippetID = try container.decode(UUID?.self, forKey: .mixedSnippet),
        let snippet = NMMixedSnippet.existingSnippet(with: snippetID, in: context) else {
   throw ContextError.noSnippet(object: self, entity: .contentFolder, operation: .JSONDecodingObject)
  }
  
  snippet.addToContainer(folder: self)
  addToContainer(singleElements: photos + audios + texts + videos)
 }
}
