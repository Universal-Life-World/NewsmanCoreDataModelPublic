import CoreData


extension NMUndoManageable{
 public typealias TUndoRedoTask<Targets> = @Sendable (_ targets: Targets) throws -> ()
 
 public typealias TUndoTask<S, Target> = @Sendable (_ source: S, _ target: Target) throws -> ()
 public typealias TRedoTask<D, Target> = @Sendable (_ destin: D, _ target: Target) throws -> ()
 
 public typealias TDeleteUndoTask<S> = @Sendable (_ srs: S, _ targetID: UUID, _ childIDs: [UUID]) async throws -> ()
 public typealias TDeleteRedoTask<Target> = @Sendable ( _ target: Target) async throws -> ()
 
}


@available(iOS 15.0, macOS 12.0, *)
extension NMUndoManageable where Self: NMContentElementsContainer,
                                 Self.Element: NMContentElement,
                                 Self.Folder: NMContentFolder,
                                 Self.Folder.Element == Self.Element,
                                 Self.Element.Snippet == Self,
                                 Self.Folder.Snippet == Self {
 
 

 
 
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

 
 //MARK: Register undo & redo tasks helper method for single folder content element (Target). Registers undo & redo tasks with the currect open undo/redo Session.
 
 fileprivate func registerUndoRedo (folder: Folder,
                                    undo: @escaping TUndoRedoTask<Folder> ,
                                    redo: @escaping TUndoRedoTask<Folder> )  {
  
  /* UNDO TASK */
  NMUndoSession.register { [ weak managedObjectContext, weak folder, folderID = folder.id ] in
   try await managedObjectContext?.perform {
    if let f = folder, f.isValid { try undo(f) }
    else if let moc = managedObjectContext, let folderID = folderID,
            let exf = Folder.existingFolder(with: folderID, in: moc){ try undo(exf) }
   }
   /* UREDO TASK */
  } with: {  [ weak managedObjectContext, weak folder, folderID = folder.id ] in
   try await managedObjectContext?.perform {
    if let f = folder, f.isValid { try redo(f) }
    else if let moc = managedObjectContext, let folderID = folderID,
            let exf = Folder.existingFolder(with: folderID, in: moc){ try undo(exf) }
   }
  }
  
 }
 
 
 //MARK: Register undo & redo tasks helper method for a Collection of Folder Content Elements (Targets). Registers undo & redo tasks with the currect open undo/redo Session.
 

 fileprivate func registerUndoRedo (folders: [Folder],
                                    undo: @escaping TUndoRedoTask<[Folder]>,
                                    redo: @escaping TUndoRedoTask<[Folder]>) {
  
  let weakFolders = WeakContainer(sequence: folders)
  let beforeFoldersIDs = folders.compactMap(\.id)
  
 
  NMUndoSession.register {  /* UNDO TASK */  [ weak managedObjectContext ] in
   try await managedObjectContext?.perform {
    guard let moc = managedObjectContext else { return }
    let afterFolders = weakFolders.elements.filter{ $0.isValid }
    let afterFolderIDs = Set(afterFolders.compactMap(\.id))
    let existingFolders = Set(beforeFoldersIDs).symmetricDifference(afterFolderIDs).compactMap{
     Folder.existingFolder(with: $0, in: moc)
    }
    let folders = afterFolders + existingFolders
    if folders.isEmpty { return }
    try undo(folders)
   }
   
  } with: { /* REDO TASK */ [ weak managedObjectContext ] in
   try await managedObjectContext?.perform {
    guard let moc = managedObjectContext else { return }
    let afterFolders = weakFolders.elements.filter{ $0.isValid }
    let afterFolderIDs = Set(afterFolders.compactMap(\.id))
    let existingFolders = Set(beforeFoldersIDs).symmetricDifference(afterFolderIDs).compactMap{
     Folder.existingFolder(with: $0, in: moc)
    }
    
    let folders = afterFolders + existingFolders
    if folders.isEmpty { return }
    try redo(folders)
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
 
 
 public typealias TElementUndoTask = TUndoTask<Self, Element>
 public typealias TElementRedoTask = TRedoTask<Self, Element>
 
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
 
 public typealias TUndoCollectionTask<Target> = @Sendable ([( source: Self,   target:   Target)]) throws -> ()
 public typealias TRedoCollectionTask<Target> = @Sendable ( _ destin: Self, _ targets: [Target] ) throws -> ()
 
 public typealias TUndoElementsCollectionTask = TUndoCollectionTask<Element>
 public typealias TRedoElementsCollectionTask = TRedoCollectionTask<Element>
 

 
 // This is a default Undo Task closure expression static getter used as a default Undo task for collection.
 // $0 - parameter is a collection of tuples (source container, target) for Undo Task.
 public static var addUndoMany: TUndoElementsCollectionTask {
  {
   $0.forEach{ $0.source.addToContainer(element: $0.target) }
  }
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
  
  
  guard element.snippet == self else { return } //The element can be removed from the container it belongs to!
  

  guard let sourceID = self.id else {
   throw ContextError.noID(object: self,
                           entity: .contentElementContainer,
                           operation: .removeFromContainerUndoably)
   
  }
  
  
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
 
 public typealias TElementsCollectionTask = @Sendable ( _ source: Self, _ targets: [Element]) throws -> ()
 
  
 public static var removeUndoMany: TElementsCollectionTask {
  { (src, ts) in src.addToContainer(singleElements: ts.filter{ $0.snippet == src }) }
 }
 
 
 public static var removeRedoMany: TElementsCollectionTask {
  { (src, ts) in src.removeFromContainer(singleElements: ts.filter{ $0.snippet == src }) }
 }
  
 
 
 //MARK: REMOVE COLLECTION OF SINGLE ELEMENTS (TARGETS): UNDO([(SOURCE, TARGET)]) == REDO([(SOURCE, TARGET)]).
 
 public func removeFromContainer(undoTargets singleElements: [Element],
                                 with undo: @escaping TElementsCollectionTask = Self.removeUndoMany,
                                 with redo: @escaping TElementsCollectionTask = Self.removeRedoMany) throws {
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self,
                                entity: .contentElementContainer,
                                operation: .removeFromContainerUndoably)
  }
  
  guard let sourceID = self.id else {
   throw ContextError.noID(object: self,
                           entity: .contentElementContainer,
                           operation: .removeFromContainerUndoably)
   
  }
  
  let elements = singleElements.filter{ $0.snippet == self }
   //The element can be removed from the container it belongs to!
  
  if elements.isEmpty { return } // all alients then no op!
 
  removeFromContainer(singleElements: elements)
  
  registerUndoRedo(elements: elements) { [ weak context ] elements in
   guard let context = context else { return }
    //Obtaining or fetching existing source content container at the moment of UNDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try undo(sourceSnippet, elements)
   
  } redo: { [ weak context ] elements in
   guard let context = context else { return }
    //Obtaining or fetching existing source content container at the moment of UNDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try undo(sourceSnippet, elements)
  }
  
 }
 
 
 //**********************************************
 // MARK: GROUP OF METHODS FOR SNIPPET FOLDERS...
 //**********************************************
 
 
 public func addToContainer(undoTarget folder: Folder,
                            with undo: @escaping TUndoRedoTask<Folder>,
                            with redo: @escaping TUndoRedoTask<Folder>)  {
  
  addToContainer(folder: folder)
  addToContainer(singleElements: folder.folderedElements)
  registerUndoRedo(folder: folder, undo: undo, redo: redo)
  
 }
 

 
//MARK: Register undo & redo tasks after adding single FOLDER (Target) into its content container returning existing valid source container & destination container at the time of undo & redo action. The Destination & Source container might be different from those at the moment of undo & redo pair of tasks registration!

//MARK: SINGLE FOLDER TARGET: UNDO(SOURCE, TARGET) <-> REDO(DESTIN, TARGET).
 
 public typealias TFolderUndoTask = TUndoTask<Self, Folder>
 public typealias TFolderRedoTask = TRedoTask<Self, Folder>
 
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
  
  registerUndoRedo(folder: folder){ folder in
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
  registerUndoRedo(folders: folders, undo: undo, redo: redo)
 }
 
 
 
//MARK: ADD COLLECTION OF FOLDERS : UNDO((SOURCE, TARGET)) <-> REDO(DESTIN, [TARGET]).
 
 
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
  
  registerUndoRedo(folders: folders){ folders in
   var sourceTargetTuples = [(source: Self, target: Folder)]()
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
  registerUndoRedo(folder: folder, undo: undo, redo: redo)
  
 }
 
 
 public static var removeFolderUndo: TFolderUndoTask {
  {
   $0.addToContainer(folder: $1)
   $0.addToContainer(singleElements: $1.folderedElements)
  }
 }
 
 public static var removeFolderRedo: TFolderRedoTask {
  {
   $0.removeFromContainer (folder: $1)
   $0.removeFromContainer(singleElements: $1.folderedElements)
  }
 }
 
 //MARK: REMOVE FOLDER TARGET: UNDO(SOURCE, TARGET) == REDO(SOURCE, TARGET).
 
 public func removeFromContainer(undoTarget folder: Folder,
                                 undo: @escaping TFolderUndoTask = Self.removeFolderUndo,
                                 redo: @escaping TFolderRedoTask = Self.removeFolderRedo) throws {
  
  guard let sourceSnippet = folder.snippet else {
   throw ContextError.noSnippet(object: folder,
                                entity: .folderContentElement,
                                operation: .removeFromContainerUndoably)
  }
  
  guard let sourceID = sourceSnippet.id else {
   throw ContextError.noID(object: sourceSnippet,
                           entity: .contentElementContainer,
                           operation: .removeFromContainerUndoably)
  }
  
  guard sourceSnippet == self else { return } //The folder can be removed from the container it belongs to!
  
  removeFromContainer(folder: folder)
  removeFromContainer(singleElements: folder.folderedElements)
  
  registerUndoRedo(folder: folder){ folder in
   guard let context = folder.managedObjectContext else { return }
    //Obtaining or fetching existing source content container at the moment of UNDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try undo(sourceSnippet, folder)
   
  } redo: { folder in
   guard let context = folder.managedObjectContext else { return }
    //Obtaining or fetching existing source content container at the moment of REDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try redo(sourceSnippet, folder)
  }
  
  
 }
 
 
 
 public func removeFromContainer(undoTargets folders: [Folder],
                                 with undo: @escaping TUndoRedoTask<[Folder]>,
                                 with redo: @escaping TUndoRedoTask<[Folder]>) {
  
  removeFromContainer(folders: folders)
  let allFoldered = folders.flatMap{ $0.folderedElements }
  removeFromContainer(singleElements: allFoldered)
  registerUndoRedo(folders: folders, undo: undo, redo: redo)
 
  
 }
 
 
 
//MARK: REMOVE COLLECTION OF FOLDERS (TARGETS): UNDO(SOURCE, [TARGET]) == REDO(SOURCE, [TARGET]).
 
 public typealias TFoldersCollectionTask  = @Sendable ( _ source: Self, _ targets: [Folder]) throws -> ()
 
 public static var removeFoldersUndoMany: TFoldersCollectionTask {
  { src, folders in
   let folders = folders.filter{ $0.snippet == src }
   src.addToContainer(folders: folders)
   let allFoldered = folders.flatMap{ $0.folderedElements }
   src.addToContainer(singleElements: allFoldered)
  }
 }
 
 public static var removeFoldersRedoMany: TFoldersCollectionTask {
  { src, folders in
   let folders = folders.filter{ $0.snippet == src }
   src.removeFromContainer(folders: folders)
   let allFoldered = folders.flatMap{ $0.folderedElements }
   src.removeFromContainer(singleElements: allFoldered)
  }
 }
 
 
 public func removeFromContainer(undoTargets folders: [Folder],
                                 with undo: @escaping TFoldersCollectionTask = Self.removeFoldersUndoMany,
                                 with redo: @escaping TFoldersCollectionTask = Self.removeFoldersRedoMany) throws {
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self,
                                entity: .contentElementContainer,
                                operation: .removeFromContainerUndoably)
  }
  
  guard let sourceID = self.id else {
   throw ContextError.noID(object: self,
                           entity: .contentElementContainer,
                           operation: .removeFromContainerUndoably)
   
  }
  
  let folders = folders.filter{ $0.snippet == self }
   //The folder can be removed from the container it belongs to!
  
  if folders.isEmpty { return } // all alients then no op!
  
  removeFromContainer(folders: folders)
  let allFoldered = folders.flatMap{ $0.folderedElements }
  removeFromContainer(singleElements: allFoldered)
  
  registerUndoRedo(folders: folders) { [ weak context ] folders in
   guard let context = context else { return }
    //Obtaining or fetching existing source content container at the moment of UNDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try undo(sourceSnippet, folders)
   
  } redo: { [ weak context ] folders in
   guard let context = context else { return }
    //Obtaining or fetching existing source content container at the moment of UNDO task execution!
   guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { return }
   try undo(sourceSnippet, folders)
  }
  
 }
 
 
 
 
}
