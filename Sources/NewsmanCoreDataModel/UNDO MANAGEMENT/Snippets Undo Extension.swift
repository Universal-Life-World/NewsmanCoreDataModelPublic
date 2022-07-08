import CoreData




@available(iOS 15.0, macOS 12.0, *)
extension NMUndoManageable
where Self: NMContentElementsContainer,
      Self.Element: NMContentElement,
      Self.Folder: NMContentFolder,
      Self.Folder.Element == Self.Element{
 
 
 //MARK: Register undo & redo tasks helper generic method for Collection of container elements (Targets). Registers undo & redo tasks with the currect open undo/redo Session.
 
 public typealias TUndoRedoTask<T> =  @Sendable (_ targets: T) throws -> ()
 
 fileprivate func registerUndoRedo<E: NMBaseContent> (elements: [E],
                                                      undo: @escaping TUndoRedoTask<[E]>,
                                                      redo: @escaping TUndoRedoTask<[E]>) {

  let weakElements = WeakContainer(sequence: elements)
  
  NMUndoSession.register { /* UNDO TASK */ [ weak managedObjectContext ] in
   try await managedObjectContext?.perform {
    let elements = weakElements.elements.filter{
     $0.isDeleted == false && $0.managedObjectContext != nil && $0.status != .trashed
    }
    try undo(elements)
   }

  } with: { /* REDO TASK */ [ weak managedObjectContext ] in
   try await managedObjectContext?.perform {
    let elements = weakElements.elements.filter{
     $0.isDeleted == false && $0.managedObjectContext != nil && $0.status != .trashed
    }
    try redo(elements)
   }
  }
 }

 //MARK: Register undo & redo tasks helper generic method for single container element (Target). Registers undo & redo tasks with the currect open undo/redo Session.
 
 fileprivate func registerUndoRedo<E: NMBaseContent> (element: E,
                                                      undo: @escaping TUndoRedoTask<E> ,
                                                      redo: @escaping TUndoRedoTask<E> )  {

  NMUndoSession.register { /* UNDO TASK */ [ weak managedObjectContext, weak element ] in
   try await managedObjectContext?.perform {
    if let e = element, e.isDeleted == false, let _ = e.managedObjectContext, e.status != .trashed {
     try undo(e)
    }
   }

  } with: { /* UREDO TASK */ [ weak managedObjectContext, weak element  ] in
   try await managedObjectContext?.perform {
    if let e = element, e.isDeleted == false, let _ = e.managedObjectContext, e.status != .trashed {
     try redo(e)
    }
   }
  }

 }
 
 
 
 //***********************************************************************
  //MARK: GROUP OF METHODS FOR SNIPPET SINGLE CONTENT ELEMENTS...
 //***********************************************************************
 
 //MARK: Register undo & redo tasks after adding single content element (target) into its content container. Default general purpose method without source & destination containers.
 
 public func addToContainer(undoTarget element: Element,
                            with undo: @escaping TUndoRedoTask<Element>,
                            with redo: @escaping TUndoRedoTask<Element>) {
  
  
  addToContainer(element: element)
  registerUndoRedo(element: element, undo: undo, redo: redo)
  
  
 }
 
 
 
//MARK: Register undo & redo tasks after adding single content element (target) into its content container returning existing valid source container & destination container at the time of undo & redo action. The Destination & Source container might be different from those at the moment of undo & redo pair of tasks registration!
 
 
 public typealias TUndoTask<E> = @Sendable (_ source: Self, _ target: E) throws -> ()
 public typealias TRedoTask<E> = @Sendable (_ destin: Self, _ target: E) throws -> ()
 
 public typealias TElementUndoTask = TUndoTask<Element>
 public typealias TElementRedoTask = TRedoTask<Element>
 
 // This is a default closure expression static getter used as a default Undo/Redo task for adding single element.
 // $0 - parameter is a source container for Undo Task and destination for Redo Task.
 // $1 - parameter is a target for undo & redo tasks.

 public static var addUndo: TElementUndoTask {{ $0.addToContainer(element: $1) }}
 public static var addRedo: TElementRedoTask {{ $0.addToContainer(element: $1) }}
 
 //MARK: SINGLE ELEMENT TARGET: UNDO(SOURCE, TARGET), REDO(DESTIN, TARGET).
 
 public func addToContainer(undoTarget element: Element,
                            undo: @escaping TElementUndoTask = Self.addUndo ,
                            redo: @escaping TElementRedoTask = Self.addRedo) throws {
  
  guard let sourceSnippet = element.snippet else {
   throw ContextError.noSnippet(object: element,
                                entity: .singleContentElement, operation: .addToContainerUndoably)
  }
  
  guard let sourceID = sourceSnippet.id else {
   throw ContextError.noID(object: sourceSnippet,
                           entity: .contentElementContainer, operation: .addToContainerUndoably)
  }
  
  guard let destinationID = self.id else {
   throw ContextError.noID(object: self,
                           entity: .contentElementContainer, operation: .addToContainerUndoably)
  }
  
  guard sourceSnippet != self else { return } // No op if source === destination container!
  
  addToContainer(element: element)
  
  registerUndoRedo(element: element){
   guard let context = $0.managedObjectContext else { return }
    //Obtaining or fetching existing source content container at the moment of UNDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try undo(sourceSnippet, $0)
   
  } redo: {
   guard let context = $0.managedObjectContext else { return }
    //Obtaining or fetching existing destination content container at the moment of REDO task execution!
   guard let destinationSnippet = Self.existingSnippet(with: destinationID, in: context) else { return }
   try redo(destinationSnippet, $0)
  }
  
  
  
  
 }
 
 
 //MARK: Register undo & redo tasks after adding multiple single content element (targets) into its content container. Default general purpose method without sources & destination containers.
 
 public func addToContainer(undoTargets singleElements: [Element],
                            with undo: @escaping TUndoRedoTask<[Element]>,
                            with redo: @escaping TUndoRedoTask<[Element]>) {
  
  
  addToContainer(singleElements: singleElements)
  registerUndoRedo(elements: singleElements, undo: undo, redo: redo)
 }
 
 
 //MARK: Register undo & redo tasks after adding multiple content elements (Targets Collection) into its Destination content container (SELF) returning corresponding existing valid Source containers & Destination container at the time of undo & redo action. The Destination & Source containers might be different from those at the moment of undo & redo pair of tasks registration!!!
 
 public typealias TUndoCollectionTask<E> = @Sendable ([( source: Self,   target:  E)]) throws -> ()
 public typealias TRedoCollectionTask<E> = @Sendable ( _ destin: Self, _ targets: [E]) throws -> ()
 
 public typealias TUndoElementsCollectionTask = TUndoCollectionTask<Element>
 public typealias TRedoElementsCollectionTask = TRedoCollectionTask<Element>
 

 
 // This is a default Undo Task closure expression static getter used as a default Undo task for collection.
 // $0 - parameter is a collection of tuples (source container, target) for Undo Task.
 public static var addUndoMany: TUndoElementsCollectionTask {
  { $0.forEach{ $0.source.addToContainer(element: $0.target) } }
 }
 
 
 
 public static var addRedoMany: TRedoElementsCollectionTask {{ $0.addToContainer(singleElements: $1) }}
  // This is a default Redo Task closure expression static getter used as a default Redo task for collection.
  // $0 - parameter is a destination container for Redo Task.
  // $1 - parameter is a collection of targets for Redo task.
 

 
 //MARK: COLLECTION OF SINGLE ELEMENTS: UNDO((SOURCE, TARGET)), REDO(DESTIN, [TARGET]).
 public func addToContainer(undoTargets singleElements: [Element],
                            with undo: @escaping TUndoElementsCollectionTask = Self.addUndoMany,
                            with redo: @escaping TRedoElementsCollectionTask = Self.addRedoMany) throws {
  
  if singleElements.isEmpty { return } // NO OP!!
  
  //Create mapping between elemets ids & corresponding containers ids.
  let sourceSnippetsMap = try singleElements.reduce(into: [UUID : UUID]()){ map, element in
   
   guard let elementID = element.id else {
    throw ContextError.noID(object: element,
                            entity: .singleContentElement, operation: .addToContainerUndoably)
   }
   guard let snippet = element.snippet else{
    throw ContextError.noSnippet(object: element,
                                 entity: .singleContentElement, operation: .addToContainerUndoably)
   }
   guard let snippetID = snippet.id else{
    throw ContextError.noID(object: snippet,
                            entity: .contentElementContainer, operation: .addToContainerUndoably)
   }
   
   map[elementID] = snippetID
   
  }
  
  guard let destinationID = self.id else {
   throw ContextError.noID(object: self, entity: .contentElementContainer, operation: .addToContainerUndoably)
  }
  
  addToContainer(singleElements: singleElements)
  
  registerUndoRedo(elements: singleElements){ elements in
   var sourceTargetTuples = [(Self, Element)]()
   //Obtaining or fetching existing source content containers at the moment of UNDO task execution!
   for element in elements {
    guard let context = element.managedObjectContext else { break }
    guard let elementID = element.id else { break }
    guard let sourceID = sourceSnippetsMap[elementID] else { break }
    guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { break }
    let sourceTargetTuple = (source: sourceSnippet, target: element) // source - target when undoing...
    sourceTargetTuples.append(sourceTargetTuple)
   }
   
   try undo(sourceTargetTuples)
   
  } redo: { [ weak self ] elements in
   guard let context = self?.managedObjectContext else { return }
   //Obtaining or fetching existing destination content container at the moment of REDO task execution!
   guard let destinationSnippet = Self.existingSnippet(with: destinationID, in: context) else { return }
   try redo(destinationSnippet, elements)
  }
  
 }
 
 
 //MARK: Register undo & redo tasks after removing one single content element (target) from its correspondong content container. Default general purpose method without source & destination containers.
 
 public func removeFromContainer(undoTarget element: Element,
                                 with undo: @escaping TUndoRedoTask<Element>,
                                 with redo: @escaping TUndoRedoTask<Element>) {
  
  removeFromContainer(element: element)
  registerUndoRedo(element: element, undo: undo, redo: redo)
 }
 
 
//MARK: Register undo & redo tasks after removing single content element (target) from its content container returning existing valid source container & destination container at the time of undo & redo action. The Destination & Source container might be different from those at the moment of undo & redo pair of tasks registration!
 
 
 // This is a closure expression static getters used as Undo/Redo remove from container tasks for single element.
 // $0 - parameter is a source container for Undo & Redo tasks.
 // $1 - parameter is a target for undo & redo tasks.
 // For remove from container operation there is no destination container!!!!
 
 public static var removeUndo: TElementUndoTask {{ $0.addToContainer     (element: $1) }}
 public static var removeRedo: TElementRedoTask {{ $0.removeFromContainer(element: $1) }}
 
 //MARK: REMOVE SINGLE ELEMENT TARGET: UNDO(SOURCE, TARGET) == REDO(SOURCE, TARGET).

 public func removeFromContainer(undoTarget element: Element,
                                 undo: @escaping TElementUndoTask = Self.removeUndo,
                                 redo: @escaping TElementRedoTask = Self.removeRedo) throws {
  
  guard let sourceSnippet = element.snippet else {
   throw ContextError.noSnippet(object: element,
                                entity: .singleContentElement,
                                operation: .removeFromContainerUndoably)
  }
  
  guard let sourceID = sourceSnippet.id else {
   throw ContextError.noID(object: sourceSnippet,
                           entity: .contentElementContainer,
                           operation: .removeFromContainerUndoably)
  }
  
  guard sourceSnippet == self else { return } //The element can be removed from the container it belongs to!
  
  removeFromContainer(element: element)
  
  registerUndoRedo(element: element){
   guard let context = $0.managedObjectContext else { return }
    //Obtaining or fetching existing source content container at the moment of UNDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try undo(sourceSnippet, $0)
   
  } redo: {
   guard let context = $0.managedObjectContext else { return }
    //Obtaining or fetching existing source content container at the moment of REDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try redo(sourceSnippet, $0)
  }
  
  
 }
 
 
 //MARK: Register undo & redo tasks after removing multiple single content element (targets) from its correspondong content containers. Default general purpose method without sources & destination containers.
 
 public func removeFromContainer(undoTargets singleElements: [Element],
                                 with undo: @escaping TUndoRedoTask<[Element]>,
                                 with redo: @escaping TUndoRedoTask<[Element]>) {
  
  removeFromContainer(singleElements: singleElements)
  registerUndoRedo(elements: singleElements, undo: undo, redo: redo)
 }
 
 public typealias TElementsCollectionTask = TUndoElementsCollectionTask
 public typealias TFoldersCollectionTask  = TUndoFoldersCollectionTask
 
  
 public static var removeUndoMany: TElementsCollectionTask {
  { $0.forEach{ $0.source.addToContainer(element: $0.target) } }
 }
 
 public static var removeFoldersUndoMany: TFoldersCollectionTask {
  { $0.forEach{ $0.source.addToContainer(folder: $0.target) } }
 }
 
 public static var removeRedoMany: TElementsCollectionTask {
  { $0.forEach{ $0.source.removeFromContainer(element: $0.target) } }
 }
  
 public static var removeFoldersRedoMany: TFoldersCollectionTask {
  { $0.forEach{ $0.source.removeFromContainer(folder: $0.target) } }
 }
 
 
 //MARK: REMOVE COLLECTION OF SINGLE ELEMENTS (TARGETS): UNDO([(SOURCE, TARGET)]) == REDO([(SOURCE, TARGET)]).
 
 public func removeFromContainer(undoTargets singleElements: [Element],
                                 with undo: @escaping TElementsCollectionTask = Self.removeUndoMany,
                                 with redo: @escaping TElementsCollectionTask = Self.removeRedoMany) throws {
  
  if singleElements.isEmpty { return }
  
   //Create mapping between elemets ids & corresponding containers ids.
  let sourceSnippetsMap = try singleElements.reduce(into: [UUID : UUID]()){ map, element in
   guard let elementID = element.id else {
    throw ContextError.noID(object: element,
                            entity: .singleContentElement, operation: .removeFromContainerUndoably)
   }
   guard let snippet = element.snippet else {
    throw ContextError.noSnippet(object: element,
                                 entity: .singleContentElement, operation: .removeFromContainerUndoably)
   }
   guard let snippetID = snippet.id else{
    throw ContextError.noID(object: snippet,
                            entity: .contentElementContainer, operation: .removeFromContainerUndoably)
   }
   
   map[elementID] = snippetID
  }
  
  removeFromContainer(singleElements: singleElements)
  
  let stt = { (_ elements: [Element]) -> [(Self, Element)] in
   var sourceTargetTuples = [(Self, Element)]()
    //Obtaining or fetching existing source content containers at the moment of UNDO task execution!
   for element in elements {
    guard let context = element.managedObjectContext else { break }
    guard let ID = element.id else { break }
    guard let sourceID = sourceSnippetsMap[ID] else { break }
    guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { break }
    let sourceTargetTuple = (source: sourceSnippet, target: element)
    sourceTargetTuples.append(sourceTargetTuple)
   }
   
   return sourceTargetTuples
  }

  registerUndoRedo(elements: singleElements) { try undo(stt($0)) } redo: { try redo(stt($0)) }
  
 }
 
 
 
 //**********************************************
 // MARK: GROUP OF METHODS FOR SNIPPET FOLDERS...
 //**********************************************
 
 
 public func addToContainer(undoTarget folder: Folder,
                            with undo: @escaping TUndoRedoTask<Folder>,
                            with redo: @escaping TUndoRedoTask<Folder>)  {
  
  addToContainer(folder: folder)
  addToContainer(singleElements: folder.folderedElements)
  registerUndoRedo(element: folder, undo: undo, redo: redo)
  
 }
 
 
//MARK: Register undo & redo tasks after adding single FOLDER (Target) into its content container returning existing valid source container & destination container at the time of undo & redo action. The Destination & Source container might be different from those at the moment of undo & redo pair of tasks registration!


 public typealias TFolderUndoTask = TUndoTask<Folder>
 public typealias TFolderRedoTask = TRedoTask<Folder>
 
  // This is a default closure expression static getter used as a default Undo/Redo task for adding single element.
  // $0 - parameter is a source container for Undo Task and destination for Redo Task.
  // $1 - parameter is a target for undo & redo tasks.
 
 public static var addFolderUndo: TFolderUndoTask {
  {
   $0.addToContainer(folder: $1)
   $0.addToContainer(singleElements: $1.folderedElements)
  }
 }
 public static var addFolderRedo: TFolderRedoTask {
  {
   $0.addToContainer(folder: $1)
   $0.addToContainer(singleElements: $1.folderedElements)
  }
 }
 
 //MARK: SINGLE ELEMENT TARGET: UNDO(SOURCE, TARGET), REDO(DESTIN, TARGET).
 
 public func addToContainer(undoTarget folder: Folder,
                            undo: @escaping TFolderUndoTask = Self.addFolderUndo ,
                            redo: @escaping TFolderRedoTask = Self.addFolderRedo) throws {
  
  guard let sourceSnippet = folder.snippet else {
   throw ContextError.noSnippet(object: folder,
                                entity: .folderContentElement, operation: .addToContainerUndoably)
  }
  
  guard let sourceID = sourceSnippet.id else {
   throw ContextError.noID(object: sourceSnippet,
                           entity: .contentElementContainer, operation: .addToContainerUndoably)
  }
  
  guard let destinationID = self.id else {
   throw ContextError.noID(object: self,
                           entity: .contentElementContainer, operation: .addToContainerUndoably)
  }
  
  guard sourceSnippet != self else { return } // No op if source === destination container!
  
  addToContainer(folder: folder)
  addToContainer(singleElements: folder.folderedElements)
  
  registerUndoRedo(element: folder){ folder in
   guard let context = folder.managedObjectContext else { return }
    //Obtaining or fetching existing source content container at the moment of UNDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try undo(sourceSnippet, folder)
   
  } redo: {
   guard let context = $0.managedObjectContext else { return }
    //Obtaining or fetching existing destination content container at the moment of REDO task execution!
   guard let destinationSnippet = Self.existingSnippet(with: destinationID, in: context) else { return }
   try redo(destinationSnippet, folder)
  }

 }
 
 public func addToContainer(undoTargets folders: [Folder],
                            with undo: @escaping TUndoRedoTask<[Folder]>,
                            with redo: @escaping TUndoRedoTask<[Folder]>) {
  
  addToContainer(folders: folders)
  let allFoldered = folders.flatMap{ $0.folderedElements }
  addToContainer(singleElements: allFoldered)
  registerUndoRedo(elements: folders, undo: undo, redo: redo)
 }
 
 public typealias TUndoFoldersCollectionTask = TUndoCollectionTask<Folder>
 public typealias TRedoFoldersCollectionTask = TRedoCollectionTask<Folder>
 

 public static var addFoldersUndoMany: TUndoFoldersCollectionTask {
  {
   $0.forEach{
    $0.source.addToContainer(folder: $0.target)
    $0.source.addToContainer(singleElements: $0.target.folderedElements)
   }
  }
 }
 
 public static var addFoldersRedoMany: TRedoFoldersCollectionTask {
  {
   $0.addToContainer(folders: $1)
   $0.addToContainer(singleElements: $1.flatMap{$0.folderedElements})
  }
 }
 
 
  //MARK: COLLECTION OF FOLDERS : UNDO((SOURCE, TARGET)), REDO(DESTIN, [TARGET]).
 public func addToContainer(undoTargets folders: [Folder],
                            with undo: @escaping TUndoFoldersCollectionTask = Self.addFoldersUndoMany,
                            with redo: @escaping TRedoFoldersCollectionTask = Self.addFoldersRedoMany) throws {
  
  if folders.isEmpty { return } // NO OP!!
  
   //Create mapping between elemets ids & corresponding containers ids.
  let sourceSnippetsMap = try folders.reduce(into: [UUID : UUID]()){ map, folder in
   
   guard let folderID = folder.id else {
    throw ContextError.noID(object: folder,
                            entity: .folderContentElement, operation: .addToContainerUndoably)
   }
   guard let snippet = folder.snippet else{
    throw ContextError.noSnippet(object: folder,
                                 entity: .folderContentElement, operation: .addToContainerUndoably)
   }
   guard let snippetID = snippet.id else{
    throw ContextError.noID(object: snippet,
                            entity: .contentElementContainer, operation: .addToContainerUndoably)
   }
   
   map[folderID] = snippetID
   
  }
  
  guard let destinationID = self.id else {
   throw ContextError.noID(object: self, entity: .contentElementContainer, operation: .addToContainerUndoably)
  }
  
  addToContainer(folders: folders)
  let allFoldered = folders.flatMap{ $0.folderedElements }
  addToContainer(singleElements: allFoldered)
  
  registerUndoRedo(elements: folders){ folders in
   var sourceTargetTuples = [(Self, Folder)]()
    //Obtaining or fetching existing source content containers at the moment of UNDO task execution!
   for folder in folders {
    guard let context = folder.managedObjectContext else { break }
    guard let folderID = folder.id else { break }
    guard let sourceID = sourceSnippetsMap[folderID] else { break }
    guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { break }
    let sourceTargetTuple = (source: sourceSnippet, target: folder) // source - target when undoing...
    sourceTargetTuples.append(sourceTargetTuple)
   }
   
   try undo(sourceTargetTuples)
   
  } redo: { [ weak self ] folders in
   guard let context = self?.managedObjectContext else { return }
    //Obtaining or fetching existing destination content container at the moment of REDO task execution!
   guard let destinationSnippet = Self.existingSnippet(with: destinationID, in: context) else { return }
   try redo(destinationSnippet, folders)
  }
  
 }
 
 
 
 public func removeFromContainer(undoTarget folder: Folder,
                                 with undo: @escaping TUndoRedoTask<Folder>,
                                 with redo: @escaping TUndoRedoTask<Folder>)  {
  
  
  removeFromContainer(folder: folder)
  removeFromContainer(singleElements: folder.folderedElements)
  registerUndoRedo(element: folder, undo: undo, redo: redo)
  
 }
 
 
 public func removeFromContainer(undoTargets folders: [Folder],
                                 with undo: @escaping TUndoRedoTask<[Folder]>,
                                 with redo: @escaping TUndoRedoTask<[Folder]>) {
  
  removeFromContainer(folders: folders)
  let allFoldered = folders.flatMap{ $0.folderedElements }
  removeFromContainer(singleElements: allFoldered)
  registerUndoRedo(elements: folders, undo: undo, redo: redo)
 
  
 }
 
 
 
 
}
