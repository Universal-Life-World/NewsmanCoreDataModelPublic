
import Foundation


//MARK: CREATE USING STATIC ASYNC FACTORY HELPER FUNCTIONS.
@available(iOS 15.0, macOS 12.0, *)
public extension NMContentElement where Self.Snippet.Folder == Self.Folder,
                                        Self.Folder.Element == Self,
                                        Self.Snippet.Element == Self,
                                        Self.Snippet == Self.Folder.Snippet {
 
 @discardableResult
 static func create(snippet: Snippet, folder: Folder?, persist: Bool = true,
                    with updates: ((Self) throws -> ())? = nil) async throws -> Self {
  
  try await snippet.createSingle(persist: persist, with: updates)
 }
 
 @discardableResult
 static func create(_ N: Int, snippet: Snippet, folder: Folder?, persist: Bool = true,
                    with updates: (([Self]) throws -> ())? = nil) async throws -> [Self] {
  
  try await snippet.createSingles(persist: persist, with: updates)
 }
 
}


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
                           with updates: ((Element) throws -> ())? = nil) async throws -> Element {
  
  guard let parentContext = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> Element in
   try Task.checkCancellation()
  
   let newSingle = Element.init(context: parentContext)
   newSingle.locationsProvider = locationsProvider
   
   insert(newElements: [newSingle])
   
   return newSingle
   
  }.updated(updates)
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
 
}


