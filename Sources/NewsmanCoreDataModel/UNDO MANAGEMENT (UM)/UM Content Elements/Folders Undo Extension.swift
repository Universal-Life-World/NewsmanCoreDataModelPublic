import CoreData

@available(iOS 15.0, macOS 12.0, *)
extension NMUndoManageable where Self: NMContentFolder & NMFileStorageManageable,
                                 Self.Element: NMContentElement & NMUndoManageable,
                                 Self.Snippet.Element == Self.Element,
                                 Self.Snippet.Folder == Self,
                                 Self.Element.Snippet == Self.Snippet,
                                 Self.Element.Folder == Self {
 
 
  //MARK: Register undo & redo tasks helper method for single content element (Target). Registers undo & redo tasks with the currect open undo/redo Session.
 
 fileprivate func registerUndoRedo(element: Element,
                                   undo: @escaping TUndoRedoTask<Element> ,
                                   redo: @escaping TUndoRedoTask<Element> )  {
  
  NMUndoSession.register { /* UNDO TASK */ [ weak managedObjectContext, weak element ] in
   try await managedObjectContext?.perform {
    if let e = element, e.isValid { try undo(e) }
   }
   
  } with: { /* UREDO TASK */ [ weak managedObjectContext, weak element  ] in
   try await managedObjectContext?.perform {
    if let e = element, e.isValid { try redo(e) }
   }
  }
  
 }
 
  //MARK: Register undo & redo tasks helper method for a Collection of Single Container Elements (Targets). Registers undo & redo tasks with the currect open undo/redo Session.
 
 fileprivate func registerUndoRedo (elements: [Element],
                                    undo: @escaping TUndoRedoTask<[Element]>,
                                    redo: @escaping TUndoRedoTask<[Element]>) {
  
  let weakElements = WeakContainer(sequence: elements)
  
  NMUndoSession.register { /* UNDO TASK */ [ weak managedObjectContext ] in
   try await managedObjectContext?.perform {
    let elements = weakElements.elements.filter{ $0.isValid }
    if elements.isEmpty { return }
    try undo(elements)
   }
   
  } with: { /* REDO TASK */ [ weak managedObjectContext ] in
   try await managedObjectContext?.perform {
    let elements = weakElements.elements.filter{ !$0.isValid }
    if elements.isEmpty { return }
    try redo(elements)
   }
  }
 }
 
 
  //***********************************************************************
  //MARK: GROUP OF METHODS FOR FOLDER SINGLE CONTENT ELEMENTS...
  //***********************************************************************
 
  //MARK: Register undo & redo tasks after adding single content element (target) into its content container. Default general purpose method without source & destination containers.
 
 public func addToContainer(undoTarget element: Element,
                            with undo: @escaping TUndoRedoTask<Element>,
                            with redo: @escaping TUndoRedoTask<Element>) {
  
  addToContainer(element: element)
  registerUndoRedo(element: element, undo: undo, redo: redo)
  
 }
 
 
//MARK: Register undo & redo tasks after adding single content element (target) into its folder container returning existing valid source & destination folder at the time of undo & redo action. The Destination & Source folder might be different from those at the moment of undo & redo pair of tasks registration!
 
 
 public typealias TRefolderUndoTask = TUndoTask<(source: Self?, destin: Self), Element>
 public typealias TRefolderRedoTask = TRedoTask<Self, Element>
 

 public static var folderUndo: TRefolderUndoTask {
  {
   $0.source?.addToContainer(element: $1)
   $0.destin.removeFromContainer(element: $1)
  }
 }
 
 public static var folderRedo: TRefolderRedoTask {{ $0.addToContainer(element: $1) }}
 
  //MARK: SINGLE ELEMENT TARGET: UNDO(SOURCE, TARGET), REDO(DESTIN, TARGET).
 
 public func addToContainer(undoTarget element: Element,
                            undo: @escaping TRefolderUndoTask = Self.folderUndo ,
                            redo: @escaping TRefolderRedoTask = Self.folderRedo) throws {

  
  guard let _ = element.snippet else {
   throw ContextError.noSnippet(object: element,
                                entity: .singleContentElement, operation: .addToContainerUndoably)
  }

  guard let _ = self.snippet else {
   throw ContextError.noSnippet(object: self,
                                entity: .folderContentElement, operation: .addToContainerUndoably)
  }

  guard let destinID = self.id else {
   throw ContextError.noID(object: self,
                           entity: .folderContentElement, operation: .addToContainerUndoably)
  }
  
  let sourceFolder = element.folder
 
  guard sourceFolder != self else { return } // No op if source folder if any === destination folder!

  addToContainer(element: element)

  registerUndoRedo(element: element){ [ weak sourceFolder, weak self, sourceID = sourceFolder?.id ] element in
   
   guard let context = element.managedObjectContext else { return }
   
   let destinFolder = { () -> Self? in
    if let destinFolder = self, destinFolder.isValid { return destinFolder }
    return Self.existingFolder(with: destinID, in: context)
   }()
   
   guard let destinFolder = destinFolder else { return }
   
   let sourceFolder = { () -> Self? in
    guard let sourceID = sourceID else { return nil }
    if let sourceFolder = sourceFolder, sourceFolder.isValid { return sourceFolder }
    return Self.existingFolder(with: sourceID, in: context)
   }()
   
   try undo((source: sourceFolder, destin: destinFolder), element)

  } redo: { [ weak self ] element in
   
   guard let context = element.managedObjectContext else { return }
   
   let destinFolder = { () -> Self? in
    if let destinFolder = self, destinFolder.isValid { return destinFolder }
    return Self.existingFolder(with: destinID, in: context)
   }()
   
   guard let destinFolder = destinFolder else { return }
   
   try redo(destinFolder, element)
  }

 }//public func addToContainer(undoTarget element: Element...
                                  
                                  

 public typealias TUnfolderUndoTask = TUndoTask<Self, Element>
 public typealias TUnfolderRedoTask = TRedoTask<Self, Element>
 
 public static var unfolderUndo: TUnfolderUndoTask {{ $0.addToContainer(element: $1) }}
 public static var unfolderRedo: TUnfolderRedoTask {{ $0.removeFromContainer(element: $1) }}
 
 
 public func removeFromContainer(undoTarget element: Element,
                                 undo: @escaping TUnfolderUndoTask = Self.unfolderUndo ,
                                 redo: @escaping TUnfolderRedoTask = Self.unfolderRedo) throws {
  
 
  guard element.folder == self else { return }
         
  guard let _ = element.snippet else {
   throw ContextError.noSnippet(object: element,
                                entity: .singleContentElement, operation: .addToContainerUndoably)
  }
  
  guard let _ = self.snippet else {
   throw ContextError.noSnippet(object: self,
                                entity: .folderContentElement, operation: .addToContainerUndoably)
  }
  
  guard let sourceID = self.id else {
   throw ContextError.noID(object: self,
                           entity: .folderContentElement, operation: .addToContainerUndoably)
  }
  
 
  removeFromContainer(element: element)
  
  registerUndoRedo(element: element){ [ weak self ] element in
  
   guard let context = element.managedObjectContext else { return }
   
   if let sourceFolder = self, sourceFolder.isValid {
    try undo(sourceFolder, element)
    return
   }
   
   guard let sourceFolder = Self.existingFolder(with: sourceID, in: context) else { return }
   
   try undo(sourceFolder, element)
   
  } redo: { [ weak self ] element in
   guard let context = element.managedObjectContext else { return }
   
   if let sourceFolder = self, sourceFolder.isValid {
    try undo(sourceFolder, element)
    return
   }
   
   guard let sourceFolder = Self.existingFolder(with: sourceID, in: context) else { return }
   
   try redo(sourceFolder, element)
  }
  
 } // public func removeFromContainer(undoTarget element: Element...

 
//MARK: UNDO/REDO AFTER DELETING FOLDERS FROM CONTEXT.

 public typealias TDeleteFolderUndoTask = TDeleteUndoTask<Self.Snippet>
 public typealias TDeleteFolderRedoTask = TDeleteRedoTask<Self>
 
 
 public static var deleteFolderUndo: TDeleteFolderUndoTask {
  { try await $0.createFolder(with: $1, from: $2, persist: true) }
 }
 
 public static var deleteFolderRedo: TDeleteFolderRedoTask {{ try await $0.delete() }}
 
 
//MARK: Deletes folder MO from context & removes its underlying file storage directory from disk recoverably by moving it into temporary recovery directory& This method also registers child MOs (Content elements) for recovery as well.
 
 public func deleteFromContext(undo: @escaping TDeleteFolderUndoTask = Self.deleteFolderUndo ,
                               redo: @escaping TDeleteFolderRedoTask = Self.deleteFolderRedo) async throws {
   
  
  
  guard let deletedFolderID = (await managedObjectContext?.perform { self.id }) else {
   throw ContextError.noID(object: self,
                           entity: .folderContentElement,
                           operation: .deleteFromContextUndoably)
  }
  
  
  guard let sourceSnippet = (await managedObjectContext?.perform { self.snippet }) else {
   throw ContextError.noSnippet(object: self,
                                entity: .folderContentElement,
                                operation: .deleteFromContextUndoably)
  }

  guard let sourceSnippetID = (await managedObjectContext?.perform { sourceSnippet.id }) else {
   throw ContextError.noID(object: sourceSnippet,
                           entity: .contentElementContainer,
                           operation: .deleteFromContextUndoably)
  }
  
  let childElementsIDs = await managedObjectContext?.perform{ self.folderedElements.compactMap(\.id)} ?? []
  
  try await self.delete(withFileStorageRecovery: true) //deletes from context with recovery!
  
  await NMUndoSession.register { [ weak sourceSnippet, weak managedObjectContext ] in
   
   let sourceSnippet = await managedObjectContext?.perform { () -> Self.Snippet? in
    if let sourceSnippet = sourceSnippet, sourceSnippet.isValid { return sourceSnippet }
    guard let context = managedObjectContext else { return nil }
    return Self.Snippet.existingSnippet(with: sourceSnippetID, in: context)
   }
   
   guard let sourceSnippet = sourceSnippet else { return }
   
   try await undo(sourceSnippet, deletedFolderID, childElementsIDs)
   
  } with: { [ weak sourceSnippet, weak managedObjectContext ] in
   
   let undeletedFolder = await managedObjectContext?.perform { () -> Self? in
    if let sourceSnippet = sourceSnippet, sourceSnippet.isValid {
     return sourceSnippet.folders.first{ $0.id == deletedFolderID }
    }
    guard let context = managedObjectContext else { return nil }
    return Self.Snippet.existingSnippet(with: sourceSnippetID, in: context)?
                       .folders.first{ $0.id == deletedFolderID }
   }
   
   guard let undeletedFolder = undeletedFolder else { return }
   
   try await redo(undeletedFolder)
  }
  
  
 
  

  
  
 }
 
}
