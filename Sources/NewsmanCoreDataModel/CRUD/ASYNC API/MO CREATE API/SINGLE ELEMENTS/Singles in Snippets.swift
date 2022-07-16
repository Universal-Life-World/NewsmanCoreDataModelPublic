

import Foundation

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
 
 
 //MARK: METHOD FOR CREATING & INSERTING SINGLE CONTENT ELEMENT INTO SNIPPET CONTENT CONTAINER.
 
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
 
 
 @discardableResult
 public func createSingle( with ID: UUID, persist: Bool = false,
                           in snippetFolder: Folder? = nil,
                           with updates: ((Element) throws -> ())? = nil) async throws -> Element {
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> Element in
   try Task.checkCancellation()
   
   let newSingle = Element.init(context: parentContext)
   newSingle.locationsProvider = locationsProvider
   newSingle.id = ID
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
 
 
 @discardableResult
 public func createSingles(from IDs: [UUID], persist: Bool = false,
                           in snippetFolder: Folder? = nil,
                           with updates: (([Element]) throws -> ())? = nil) async throws -> [Element] {
  
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
   
   insert(newElements: newSingles, into: snippetFolder)
   
   return newSingles
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
}
