
import Foundation
import CoreData
import UIKit


public protocol NMContentElementsContainer where Self: NMBaseSnippet {

 associatedtype Element: NMBaseContent
 associatedtype Folder:  NMBaseContent
 
 var folders: [Folder]                   { get }
 var singleContentElements: [Element]    { get }
 
 func addToContainer(singleElements: [Element])
 func removeFromContainer(singleElements: [Element])
 
 func addToContainer(folders: [Folder])
 func removeFromContainer(folders: [Folder])
 
}

extension NMContentElementsContainer {
 public var isValid: Bool { managedObjectContext != nil && isDeleted == false }
 public var isEmpty: Bool { folders.isEmpty && singleContentElements.isEmpty }
 
 public func contains(element: Element) -> Bool { singleContentElements.contains{ element.id == $0.id } }
 public func contains(element: Element, where predicate: (Element) -> Bool ) -> Bool {
  singleContentElements.contains(where: predicate)
 }

 public func contains(folder: Folder) -> Bool { folders.contains{ folder.id == $0.id } }
 public func contains(folder: Folder, where predicate:(Folder) -> Bool ) -> Bool {
  folders.contains(where: predicate)
 }
 
 public func addToContainer(element: Element){ addToContainer(singleElements: [element]) }
 public func addToContainer(element: Element, with predicate: (Element) -> Bool){
  if predicate(element) { addToContainer(singleElements: [element]) }
 }
 
 public func addToContainer(elements: [Element], with predicate: (Element) -> Bool){
  addToContainer(singleElements: elements.filter(predicate))
 }
 
 public func addToContainer(folder: Folder)  { addToContainer(folders: [folder]) }
 public func addToContainer(folder: Folder, with predicate: (Folder) -> Bool){
  if predicate(folder) { addToContainer(folders: [folder]) }
 }
 
 public func addToContainer(folders: [Folder], with predicate: (Folder) -> Bool){
  addToContainer(folders: folders.filter(predicate))
 }
 public func removeFromContainer(element: Element) { removeFromContainer(singleElements: [element])}
 public func removeFromContainer(folder: Folder) { removeFromContainer(folders: [folder])}
 
 
 public static func registeredSnippet(with id: UUID, with context: NSManagedObjectContext) -> Self? {
  context.registeredObjects
   .compactMap{ $0 as? Self }
   .first{ $0.id == id && $0.isValid && $0.status != .trashed  }
 }
 
 public static func existingSnippet(with id: UUID, in context: NSManagedObjectContext) -> Self? {
  if let object = registeredSnippet(with: id, with: context) { return object }
  
  let pred = NSPredicate(format: "SELF.id == %@", id as CVarArg )
  let fr = Self.fetchRequest()
  fr.predicate = pred
  return try? context.fetch(fr).first{ $0.status != .trashed } as? Self
 }
 
 @available(iOS 15.0, macOS 12.0, *)
 public static func existingSnippet(with id: UUID, in context: NSManagedObjectContext) async throws -> Self? {
  
  try await context.perform {
   if let object = registeredSnippet(with: id, with: context) { return object }
   let pred = NSPredicate(format: "SELF.id == %@", id as CVarArg )
   let fr = Self.fetchRequest()
   fr.predicate = pred
   return try context.fetch(fr).first{ $0.status != .trashed } as? Self
  
  }
 }
 
 @available(iOS 15.0, macOS 12.0, *)
 public var snippetID: UUID {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentElementContainer, operation: .gettingObjectID)
   }
   
   return try await context.perform {
    guard let ID = self.id else {
     throw ContextError.noID(object: self, entity: .contentElementContainer, operation: .gettingObjectID)
    }
    return ID
   } //try await context.perform...
  } //get async throws...
 } //snippetID...
} //ext

@available(iOS 15.0, macOS 12.0, *)
extension NMContentElementsContainer where Element: NMContentElement {

 
 public var singleContentElementsAsync: [Element]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentElementContainer, operation: .gettingSnippetElements)
   }
   
   return await context.perform { self.singleContentElements }
  } //get async throws...
 } //snippet...
 
 public var foldersAsync: [Folder]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .contentElementContainer,
                                 operation: .gettingSnippetElements)
   }
   
   return await context.perform { self.folders }
  } //get async throws...
 } //snippet...
 
 public var foldersIDsAsync: [UUID]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .contentElementContainer,
                                 operation: .gettingSnippetElementsIDs)
   }
   
   return await context.perform { self.folders.compactMap(\.id) }
  } //get async throws...
 } //snippet...
 
 public var folderedContentElementsAsync: [Element]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentElementContainer, operation: .gettingSnippetElements)
   }
   
   return await context.perform { self.singleContentElements.filter { $0.isFoldered } }
  } //get async throws...
 } //snippet...
 

 
 public var unfolderedContentElementsAsync: [Element]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentElementContainer, operation: .gettingSnippetElements)
   }
   
   return await context.perform { self.singleContentElements.filter { !$0.isFoldered } }
  } //get async throws...
 } //snippet...
 

 public var folderedContentElementsIDsAsync: [UUID]  {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentFolder, operation: .gettingSnippetElementsIDs)
   }
   
   return await context.perform { self.singleContentElements.filter { $0.isFoldered }.compactMap(\.id) }
  } //get async throws...
 } //snippet..
 
 
 public var unfolderedContentElementsIDsAsync: [UUID]  {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentFolder, operation: .gettingSnippetElementsIDs)
   }
   
   return await context.perform { self.singleContentElements.filter { !$0.isFoldered }.compactMap(\.id) }
  } //get async throws...
 } //snippet..
 
}//extension scope...



extension NMContentElementsContainer where Self.Element: NMContentElement,
                                           Self.Element == Folder.Element,
                                           Self.Folder == Element.Folder,
                                           Self.Element.Snippet == Self,
                                           Self.Folder.Snippet == Self {
 
 public var folderedContentElements: [Element] { singleContentElements.filter{$0.isFoldered } }
 public var unfolderedContentElements: [Element] { singleContentElements.filter{!$0.isFoldered } }
}


@available(iOS 15.0, macOS 12.0, *)
extension NMContentElementsContainer where Self.Element: NMContentElement,
                                           Self.Element == Folder.Element,
                                           Self.Folder == Element.Folder,
                                           Self.Element.Snippet == Self,
                                           Self.Folder.Snippet == Self {
 
 
 

 
 fileprivate func unfolder(moved: [Element]){
  moved.forEach{ element in
   element.folder?.removeFromContainer(singleElements: [element])
  }
 }
 
 fileprivate func move(elements: [Element], to destination: Self) {
   
  guard destination.isValid else { return }
 
  let moved = elements.filter { $0.canBeMoved(to: destination) }
  if moved.isEmpty { return }
 
  removeFromContainer(singleElements: moved)
  destination.addToContainer(singleElements: moved)
  unfolder(moved: moved)
  
 }
 
 
 
 fileprivate func move(folderedIn moved: [Folder], to destination: Self){
  
  let foldered = moved.flatMap{ $0.folderedElements }
  removeFromContainer(singleElements: foldered)
  destination.addToContainer(singleElements: foldered)
 }
 
 fileprivate func move(folders: [Folder], to destination: Self) {
   
  guard destination.isValid else { return }

  let moved = folders.filter { $0.canBeMoved(to: destination)}

  removeFromContainer(folders: moved)
  destination.addToContainer(folders: moved)
  move(folderedIn: folders, to: destination)
 
   
 }
 
 
 
}



