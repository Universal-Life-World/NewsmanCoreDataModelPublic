
import Foundation


 //MARK: CREATE INSIDE SNIPPET FOLDER.
@available(iOS 15.0, macOS 12.0, *)
extension NMContentFolder where Self.Element: NMContentElement,
                                Self.Element == Snippet.Element,
                                Self.Element.Folder == Self,
                                Self.Snippet.Folder == Self {
 
 
 public func insert(newElements: [Element]) {
  
  if newElements.isEmpty { return }
  let new = newElements.filter { $0.isValid }
  
  if new.isEmpty { return }
  addToContainer(singleElements: new) // INSERTS INTO CONTAINING SNIPPET/MIXED ONE AS WELL!!!
  
 }
 
 
 //MARK: CREATES SINGLE CONTENT ELEMENT INSIDE SNIPPET FOLDER AND PUT IT INTO CONTAINING SNIPPET AS WELL.
 
 @discardableResult
 public func createSingle( persist: Bool = false,
                           with updates: ((Element) throws -> ())? = nil) async throws -> Element
  {
  
  guard let parentContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> Element in
   try Task.checkCancellation()
  
   let newSingle = Element.init(context: parentContext)
   newSingle.locationsProvider = locationsProvider
   
   insert(newElements: [newSingle])
   
   return newSingle
   
  }
   .updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
  // Helper method for recovery with existing UUID.
 @discardableResult
 public func createSingle( with ID: UUID, persist: Bool = false,
                           with updates: ((Element) throws -> ())? = nil) async throws -> Element
 
 where Element: NMUndoManageable {
  
  guard let parentContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> Element in
   try Task.checkCancellation()
   
   let newSingle = Element.init(context: parentContext)
   newSingle.id = ID
   newSingle.locationsProvider = locationsProvider
   
   insert(newElements: [newSingle])
   
   return newSingle
   
  }.withRegisteredUndoManager(targetID: ID)
   .updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
 //MARK: CREATES COLLECTION OF SINGLE CONTETNT ELEMENTS INSIDE SNIPPET FOLDER AND PUT THEM ALL INTO CONTAINING SNIPPET AS WELL.
 
 @discardableResult
 public func createSingles(_ N: Int = 1, persist: Bool = false,
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
   
   insert(newElements: newSingles)
   
   return newSingles
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
 // Helper method for recovery with existing UUIDs.
 @discardableResult
 public func createSingles(from IDs: [UUID], persist: Bool = false,
                           with updates: (([Element]) throws -> ())? = nil) async throws -> [Element]
  where Element: NMUndoManageable {
  
  if IDs.isEmpty { return [] }
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> [Element] in
   try Task.checkCancellation()
   var newSingles = [Element]()
   for id in IDs {
    let newSingle = Element.init(context: parentContext)
    newSingle.id = id
    newSingle.locationsProvider = locationsProvider
    newSingles.append(newSingle)
    
   }
   
   insert(newElements: newSingles)
   
   return newSingles
   
  }.withRegisteredUndoManager(targetIDs: IDs)
   .updated(updates)
   .persisted(persist)
   .withFileStorage()
 }
 
}


