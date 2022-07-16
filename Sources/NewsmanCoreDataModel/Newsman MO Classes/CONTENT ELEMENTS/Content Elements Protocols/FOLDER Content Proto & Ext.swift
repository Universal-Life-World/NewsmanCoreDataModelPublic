
import Foundation
import CoreData

public protocol NMContentFolder where Self: NMBaseContent {
 
 associatedtype Element: NMBaseContent
 associatedtype Snippet: NMContentElementsContainer
 
 var snippet: Snippet?               { get }
 var mixedSnippet: NMMixedSnippet?   { get }
 var folderedElements: [Element]     { get }
 
 func addToContainer(singleElements: [Element])
 func removeFromContainer(singleElements: [Element])
 
}

extension NMContentFolder {
 public var container: NMBaseSnippet? { snippet ?? mixedSnippet }
 public var hasSnippet: Bool { container != nil }
 public var isValid: Bool { managedObjectContext != nil && isDeleted == false }
 public var isNew: Bool { isValid && hasSnippet == false  }
 public var isEmpty: Bool { folderedElements.isEmpty }
 public var elementsCount: Int { folderedElements.count }
 public var isSingleElement: Bool { elementsCount == 1 }

 public func canBeMoved(to destination: Snippet) -> Bool { isValid && hasSnippet && destination != self }
 
 public func addToContainer(element: Element){ addToContainer(singleElements: [element]) }
 public func removeFromContainer(element: Element) { removeFromContainer(singleElements: [element])}
 
 public static func registeredFolder(with id: UUID, with context: NSManagedObjectContext) -> Self? {
  context.registeredObjects.compactMap{ $0 as? Self }.first{ $0.id == id && $0.isValid }
 }
 
 public static func existingFolder(with id: UUID, in context: NSManagedObjectContext) -> Self? {
  
  if let object = registeredFolder(with: id, with: context) { return object }
  
  let pred = NSPredicate(format: "SELF.id == %@", id as CVarArg )
  let fr = Self.fetchRequest()
  fr.predicate = pred
  return try? context.fetch(fr).first as? Self
 }
 
 
 
}




@available(iOS 15.0, macOS 12.0, *)
extension NMContentFolder where Self: NMUndoManageable & NMFileStorageManageable,
                                Element: NMContentElement & NMUndoManageable & NMFileStorageManageable,
                                Snippet: NMUndoManageable & NMFileStorageManageable,
                                Snippet == Element.Snippet,
                                Snippet.Folder == Self,
                                Snippet.Element == Element,
                                Element.Folder == Self {
 
 func autoremoveIfNeeded() async throws {
  
  print(#function, objectID)
   
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .folderContentElement, operation: .autoremoveFolder )
  }
  
  if await context.perform({ self.isDeleted }) { return }
 
  if await context.perform({ self.isEmpty }) {
   try await self.deleteFromContext() // delete object with undo/redo...
   return
  }
         
  guard await context.perform({ self.isSingleElement }) else { return }
  
  let single = await context.perform{ self.folderedElements.first! }
   
  try await single.unfolder()
  
 }
}



