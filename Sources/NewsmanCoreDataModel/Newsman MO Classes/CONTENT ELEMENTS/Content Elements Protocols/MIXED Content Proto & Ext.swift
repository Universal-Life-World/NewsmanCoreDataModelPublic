
@available(iOS 15.0, macOS 12.0, *)
extension NMContentElementsContainer where Self: NMMixedSnippet {

 fileprivate func insert(mixedElements: [NMBaseContent], into folder: NMBaseContent? )  {
  
  if mixedElements.isEmpty { return }
  
  let newPhotos = mixedElements.compactMap{ $0 as? NMPhoto }.filter { $0.isValid }
  let newAudios = mixedElements.compactMap{ $0 as? NMAudio }.filter { $0.isValid }
  let newTexts =  mixedElements.compactMap{ $0 as? NMText  }.filter { $0.isValid }
  let newVideos = mixedElements.compactMap{ $0 as? NMVideo }.filter { $0.isValid }
  
  let newMixed = newPhotos as [_ ] + newAudios as [_ ] + newTexts  as [_ ] + newVideos as [_ ]
  
  if newMixed.isEmpty { return }
  
  addToContainer(singleElements: newMixed)
  
  guard let folder = folder else { return }
  
  switch folder {
   case let photoFolder as NMPhotoFolder
    where photoFolder.mixedSnippet == self && photoFolder.isValid  :
     photoFolder.insert(newElements: newPhotos)
   
   case let audioFolder as NMAudioFolder
    where audioFolder.mixedSnippet == self && audioFolder.isValid :
     audioFolder.insert(newElements: newAudios)
    
   case let textFolder as NMTextFolder
    where textFolder.mixedSnippet == self && textFolder.isValid :
     textFolder.insert(newElements: newTexts)
    
   case let videoFolder as NMVideoFolder
    where videoFolder.mixedSnippet == self && videoFolder.isValid :
     videoFolder.insert(newElements: newVideos)
   
   case let mixedFolder as NMMixedFolder
    where mixedFolder.mixedSnippet == self && mixedFolder.isValid :
     mixedFolder.insert(mixedElements: newMixed)
    
   default: return
  }
 }
 
 
 
 
 fileprivate func insert(newFolders: [NMBaseContent]) {
  
  if newFolders.isEmpty { return }
  
  let newMixed  = newFolders.compactMap{ $0 as? NMMixedFolder }.filter { $0.isValid }
  let newPhotos = newFolders.compactMap{ $0 as? NMPhotoFolder }.filter { $0.isValid }
  let newAudios = newFolders.compactMap{ $0 as? NMAudioFolder }.filter { $0.isValid }
  let newTexts  = newFolders.compactMap{ $0 as? NMTextFolder  }.filter { $0.isValid }
  let newVideos = newFolders.compactMap{ $0 as? NMVideoFolder }.filter { $0.isValid }
  
  let new: [NMBaseContent] = newMixed as [_ ] + newPhotos as [_ ] + newAudios as [_ ]
                                              + newTexts  as [_ ] + newVideos as [_ ]
  
  if new.isEmpty { return }
  
  addToContainer(folders: new)
 }

 
 @discardableResult
 public func createSingles<E: NMContentElement, F> (_ N: Int = 1, of contentType: E.Type,
                           in snippetFolder: F? = nil,
                           persist: Bool = false,
                           with updates: (([E]) throws -> ())? = nil) async throws -> [E] where E.Folder == F {
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> [E] in
   try Task.checkCancellation()
   var newSingles = [E]()
   for _ in 1...N {
    let newSingle = contentType.init(context: parentContext)
    newSingle.locationsProvider = locationsProvider
    newSingles.append(newSingle)
    
   }
   
   insert(mixedElements: newSingles, into: snippetFolder)
   
   
   return newSingles
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
 @discardableResult
 public func createSingle<E: NMContentElement, F> (of contentType: E.Type,
                                                   in snippetFolder: F? = nil,
                                                   persist: Bool = false,
                                                   with updates: ((E) throws -> ())? = nil) async throws -> E
 where E.Folder == F {
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> E in
   try Task.checkCancellation()

   let newSingle = contentType.init(context: parentContext)
   newSingle.locationsProvider = locationsProvider

   
 
   insert(mixedElements: [newSingle], into: snippetFolder)
   
   
   return newSingle
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
 @discardableResult
 public func createSingles (_ N: Int = 1, of contentType: Element.Type,
                                  into mixedFolder: NMMixedFolder?,
                                  persist: Bool = false,
                                  with updates: (([Element]) throws -> ())? = nil) async throws -> [Element] {
  
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> [Element] in
   try Task.checkCancellation()
   var newSingles = [Element]()
   for _ in 1...N {
    let newSingle = contentType.init(context: parentContext)
    newSingle.locationsProvider = locationsProvider
    newSingles.append(newSingle)
    
   }
   
   insert(mixedElements: newSingles, into: mixedFolder)
   
   
   return newSingles
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
 @discardableResult
 public func createSingle <E: NMContentElement> (of contentType: E.Type,
                            into mixedFolder: NMMixedFolder? = nil ,
                            persist: Bool = false,
                            with updates: ((E) throws -> ())? = nil) async throws -> E {
  
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> E in
   try Task.checkCancellation()
   let newSingle = E.init(context: parentContext)
   newSingle.locationsProvider = locationsProvider
  
   insert(mixedElements: [newSingle], into: mixedFolder)
   
   
   return newSingle
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
 
 @discardableResult
 public func createFolder<F: NMContentFolder>(of folderType: F.Type,
                          persist: Bool = false,
                          with updates: ((F) throws -> ())? = nil) async throws -> F {
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [  unowned self, unowned parentContext ] () -> F in
   try Task.checkCancellation()
   
   let newFolder = F.init(context: parentContext)
   newFolder.locationsProvider = locationsProvider
   
   insert(newFolders: [newFolder])
   return newFolder
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
  
 }
 
 @discardableResult
 public func createFolders(_ N: Int = 1, of folderType: Folder.Type,
                           persist: Bool = false,
                           with updates: (([Folder]) throws -> ())? = nil) async throws -> [Folder] {
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [  unowned self, unowned parentContext ] () -> [Folder] in
   try Task.checkCancellation()
   var newFolders = [Folder]()
   for _ in 1...N {
    let newFolder = folderType.init(context: parentContext)
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
extension NMContentFolder where Self: NMMixedFolder {
 
 
 fileprivate func insert(mixedElements: [NMBaseContent])  {
  
  if mixedElements.isEmpty { return }
  
  let newPhotos = mixedElements.compactMap{ $0 as? NMPhoto }.filter { $0.isValid }
  let newAudios = mixedElements.compactMap{ $0 as? NMAudio }.filter { $0.isValid }
  let newTexts =  mixedElements.compactMap{ $0 as? NMText  }.filter { $0.isValid }
  let newVideos = mixedElements.compactMap{ $0 as? NMVideo }.filter { $0.isValid }
  
  let newMixed = newPhotos as [_ ] + newAudios as [_ ] + newTexts  as [_ ] + newVideos as [_ ]
  
  if newMixed.isEmpty { return }
  
  addToContainer(singleElements: newMixed)
 }
 
 
 
 @discardableResult
 public func createSingles(_ N: Int = 1, of contentType: Element.Type,
                           persist: Bool = false,
                           with updates: (([Element]) throws -> ())? = nil) async throws -> [Element]
 {
  
  
  guard let parentContext = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .createChildren)
  }
  
  return try await parentContext.perform { [ unowned self, unowned parentContext] () -> [Element] in
   try Task.checkCancellation()
   var newSingles = [Element]()
   for _ in 1...N {
    let newSingle = contentType.init(context: parentContext)
    newSingle.locationsProvider = locationsProvider
    newSingles.append(newSingle)
    
    
   }
   
   insert(mixedElements: newSingles)
   
   
   return newSingles
   
  }.updated(updates)
   .persisted(persist)
   .withFileStorage()
  
 }
 
 
 
 
}
