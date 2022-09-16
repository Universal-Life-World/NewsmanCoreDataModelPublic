
import CoreData

extension NMContentFolder {
 
 func encodeElementsAndSnippet(into container: inout KeyedEncodingContainer<CodingKeys>) throws {
   //print (#function, folderedElements.count, folderedElements.compactMap {$0.id})
  try container.encode(folderedElements, forKey: .folderedElements)
  try container.encode(snippet?.id,      forKey: .snippet)
  try container.encode(mixedSnippet?.id, forKey: .mixedSnippet)
 }
 
 
 func decodeIntoExisitingSnippet(from container: KeyedDecodingContainer<CodingKeys>,
                                 into context: NSManagedObjectContext) throws
 where Snippet.Element == Element, Snippet.Folder == Self {
  
   //print (#function, "DECODING ELEMENTS...")
  _ = try container.decode([Snippet.Element].self, forKey: .folderedElements)
  
  
  if let snippetID = try container.decode(UUID?.self, forKey: .snippet),
     let snippet = Snippet.existingSnippet(with: snippetID, in: context){
   
   snippet.addToContainer(folder: self)       { !snippet.contains(folder:  $0) }
    //snippet.addToContainer(elements: elements) { !snippet.contains(element: $0) }
   
  } else if let snippetID = try container.decode(UUID?.self, forKey: .mixedSnippet),
            let snippet = NMMixedSnippet.existingSnippet(with: snippetID, in: context){
   
   snippet.addToContainer(folder: self)       { !snippet.contains(folder:  $0) }
    //snippet.addToContainer(elements: elements) { !snippet.contains(element: $0) }
   
   
  } else {
   throw ContextError.noSnippet(object: self, entity: .contentFolder, operation: .JSONDecodingObject)
  }
  
   //addToContainer(elements: elements) { !self.contains(element: $0) }
 }
}
