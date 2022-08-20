
import CoreData

extension NMContentElement {
 func encodeContentContainers(into container: inout KeyedEncodingContainer<CodingKeys>) throws {
  try container.encode(folder?.id,       forKey: .folder)
  try container.encode(snippet?.id,      forKey: .snippet)
  try container.encode(mixedFolder?.id,  forKey: .mixedFolder)
  try container.encode(mixedSnippet?.id, forKey: .mixedSnippet)
 }
 
 func decodeIntoExistingFolder(from container: KeyedDecodingContainer<CodingKeys>,
                               into context: NSManagedObjectContext) throws
 where Snippet.Folder == Folder, Folder.Element == Self, Snippet.Element == Self {
  
 // print (#function, "DECODING FOLDER...")
  if let folderID = try container.decode(UUID?.self, forKey: .folder),
     let folder = Folder.existingFolder(with: folderID, in: context) {
   
   folder.addToContainer(element: self) { !folder.contains(element: $0) }
   
   return
  }
  
   //If folder does not exist try to insert into exisiting snippet directly!
  if let snippetID = try container.decode(UUID?.self, forKey: .snippet),
     let snippet = Snippet.existingSnippet(with: snippetID, in: context) {
   snippet.addToContainer(element: self)
  } else if let snippetID = try container.decode(UUID?.self, forKey: .mixedSnippet),
            let snippet = NMMixedSnippet.existingSnippet(with: snippetID, in: context){
   
   snippet.addToContainer(element: self) { !snippet.contains(element: $0) }
   
  } else {
   throw ContextError.noSnippet(object: self, entity: .contentFolder, operation: .JSONDecodingObject)
  }
  
 }
 
}
