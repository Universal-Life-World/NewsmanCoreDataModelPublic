
import Foundation

@available(iOS 15.0, macOS 12.0, *)
extension NMContentElementsContainer where Self.Element: NMContentElement,
                                           Self.Element == Folder.Element,
                                           Self.Folder == Element.Folder,
                                           Self.Element.Snippet == Self,
                                           Self.Folder.Snippet == Self {
 
 
 
 
 fileprivate func insert(newFolders: [Folder]) {
  let new = newFolders.filter { $0.isValid }
  if new.isEmpty { return }
  addToContainer(folders: new)
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
 
 @discardableResult
 public func createFolder( with ID: UUID, persist: Bool = false,
                           with updates: ((Folder) throws -> ())? = nil) async throws -> Folder
  where Self.Folder: NMUndoManageable  {
  
  guard let parentContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
 return try await parentContext.perform { [ unowned self, unowned parentContext ] () -> Folder in
   try Task.checkCancellation()
   
   let newFolder = Folder.init(context: parentContext)
   newFolder.id = ID
   newFolder.locationsProvider = locationsProvider
   insert(newFolders: [newFolder])
   return newFolder
   
  }.withRegisteredUndoManager(targetID: ID)
   .updated(updates)
   .persisted(persist)
   .withFileStorage()
 
 }
 
 @discardableResult
 public func createFolder( with ID: UUID,
                           from IDs: [UUID],
                           persist: Bool = false,
                           folderUpdates: ((Folder) throws -> ())? = nil,
                           singlesUpdates: (([Element]) throws ->())? = nil) async throws -> Folder
 where Folder: NMUndoManageable, Element: NMUndoManageable {
  
  let folder = try await createFolder(with: ID, persist: persist, with: folderUpdates)
  try await folder.createSingles(from: IDs, persist: persist, with: singlesUpdates)
  return folder
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
 
 @discardableResult
 public func createFolders(from IDs: [UUID], persist: Bool = false,
                           with updates: (([Folder]) throws -> ())? = nil) async throws -> [Folder] {
  
  guard let parentContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [  unowned self, unowned parentContext ] () -> [Folder] in
   try Task.checkCancellation()
   var newFolders = [Folder]()
   for id in IDs {
    let newFolder = Folder.init(context: parentContext)
    newFolder.id = id
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
