
import Foundation
import CoreData


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
 
 public func addToContainer(element: Element){ addToContainer(singleElements: [element]) }
 public func addToContainer(folder: Folder)  { addToContainer(folders: [folder]) }
 public func removeFromContainer(element: Element) { removeFromContainer(singleElements: [element])}
 public func removeFromContainer(folder: Folder) { removeFromContainer(folders: [folder])}
 
 
 public static func registeredSnippet(with id: UUID, with context: NSManagedObjectContext) -> Self? {
  context.registeredObjects
   .compactMap{ $0 as? Self }
   .first{ $0.id == id && $0.isValid && $0.status != .trashed  }
 }
 
 public static func existingSnippet(with id: UUID, in context: NSManagedObjectContext) -> Self? {
  if let object = registeredSnippet(with: id, with: context) {
   return object
  }
  
  let pred = NSPredicate(format: "SELF.id == %@", id as CVarArg )
  let fr = Self.fetchRequest()
  fr.predicate = pred
  return try? context.fetch(fr).first{ $0.status != .trashed } as? Self
 }
 
}

@available(iOS 15.0, macOS 12.0, *)
extension NMContentElementsContainer
 where Self: NMFileStorageManageable, Self.Element: NMContentElement  {
 
 public var unfolderedAsync: [Element]? {
  get async {
   await managedObjectContext?.perform { self.singleContentElements.filter{ !$0.isFoldered } }
  }
 }
 
 
 public var foldersAsync: [Folder]? {
  get async {
   await managedObjectContext?.perform { self.folders }
  }
 }
 
 public func fileManagerFoldersTaskGroup() async throws {
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   await foldersAsync?.forEach{ folder in
    group.addTask { try await folder.fileManagerTask?.value }
   }
   
   try await group.waitForAll()
  }
 }
 
 public func fileManagerUnfolderedTaskGroup() async throws {
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
  
   await unfolderedAsync?.forEach{ element in
    group.addTask { try await element.fileManagerTask?.value }
   }
   
   try await group.waitForAll()
  }
 }
 
 public func fileManagerChildrenTaskGroup() async throws {
  try await fileManagerFoldersTaskGroup()
  try await fileManagerUnfolderedTaskGroup()
 }
 
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerChildrenTaskGroup()
 }
 
 
}

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
 
 
 fileprivate func insert(newElements: [Element], into folder: Folder? = nil ) {
  
  let new = newElements.filter { $0.isValid }
  
  if new.isEmpty { return }
  
  addToContainer(singleElements: new)
  
  if let folder = folder, folder.snippet == self { folder.insert(newElements: new) }
 }
 
 fileprivate func insert(newFolders: [Folder]) {
  let new = newFolders.filter { $0.isValid }
  if new.isEmpty { return }
  addToContainer(folders: new)
 }
 
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
 
 //MARK: METHOD FOR CREATING & INSERTING SINGLE CONTENT ELEMENT INTO CONTENT CONTAINER.
 
 @discardableResult
 public func createSingle( persist: Bool = false,
                           in snippetFolder: Folder? = nil,
                           with updates: ((Element) throws -> ())? = nil) async throws -> Element {
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> Element in
   try Task.checkCancellation()
  
   let newSingle = Element.init(context: parentContext)
   newSingle.locationsProvider = locationsProvider
    
   insert(newElements: [newSingle], into: snippetFolder)
   
   return newSingle
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
 }
 
 
 //MARK: METHOD FOR CREATING & INSERTING COLLECTION OF CONTENT ELEMENTS INTO CONTENT CONTAINER.
 
 @discardableResult
 public func createSingles(_ N: Int = 1,
                           persist: Bool = false,
                           in snippetFolder: Folder? = nil,
                           with updates: (([Element]) throws -> ())? = nil) async throws -> [Element] {
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> [Element] in
   try Task.checkCancellation()
   var newSingles = [Element]()
   for _ in 1...N {
    let newSingle = Element.init(context: parentContext)
    newSingle.locationsProvider = locationsProvider
    newSingles.append(newSingle)
    
   }
   
   insert(newElements: newSingles, into: snippetFolder)
   
   return newSingles
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
 //MARK: METHOD FOR CREATING & INSERTING SINGLE FOLDER INTO CONTENT CONTAINER.
 
 @discardableResult
 public func createFolder( persist: Bool = false,
                           with updates: ((Folder) throws -> ())? = nil) async throws -> Folder {
  
  guard let parentContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext ] () -> Folder in
   try Task.checkCancellation()
   
   let newFolder = Folder.init(context: parentContext)
   newFolder.locationsProvider = locationsProvider
  
   insert(newFolders: [newFolder])
   return newFolder
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
  
 }


 //MARK: METHOD FOR CREATING & INSERTING COLLECTION OF FOLDERS INTO CONTENT CONTAINER.
 
 @discardableResult
 public func createFolders(_ N: Int = 1,
                           persist: Bool = false,
                           with updates: (([Folder]) throws -> ())? = nil) async throws -> [Folder] {
  
  guard let parentContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [  unowned self, unowned parentContext ] () -> [Folder] in
   try Task.checkCancellation()
   var newFolders = [Folder]()
   for _ in 1...N {
    let newFolder = Folder.init(context: parentContext)
    newFolder.locationsProvider = locationsProvider
    newFolders.append(newFolder)
   }
   insert(newFolders: newFolders)
   return newFolders
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
  
 }
 
 
 
}


@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable where Self: NMContentElementsContainer {
 var resourceSnippetURL: URL {
  get async throws {
   
   try Task.checkCancellation()
   
   guard let context = managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .object, operation: .resourceFileAccess)
   }
   
   try await fileManagerTask?.value
   
   guard let snippetURL = (await context.perform { self.url }) else {
    throw ContextError.noURL(object: self, entity: .singleContentElement, operation: .resourceFileAccess)
   }
   
   return snippetURL
  }
 }
}
