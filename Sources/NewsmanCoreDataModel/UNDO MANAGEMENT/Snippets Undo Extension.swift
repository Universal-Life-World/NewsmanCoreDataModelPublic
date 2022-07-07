import CoreData




@available(iOS 15.0, macOS 12.0, *)
extension NMUndoManageable
where Self: NMContentElementsContainer,
      Self.Element: NMContentElement,
      Self.Folder: NMContentFolder {
 
 
 //MARK: Register undo & redo tasks helper generic method for Collection of container elements (Targets). Registers undo & redo tasks with the currect open undo/redo Session.
 
 public typealias TUndoRedoTask<T> =  @Sendable (_ targets: T) throws -> ()
 
 fileprivate func registerUndoRedo<E: NMBaseContent> (elements: [E],
                                                      undo: @escaping TUndoRedoTask<[E]>,
                                                      redo: @escaping TUndoRedoTask<[E]>) {

  let weakElements = WeakContainer(sequence: elements)
  
  NMUndoSession.register { /* UNDO TASK */ [ weak managedObjectContext ] in
   try await managedObjectContext?.perform {
    let elements = weakElements.elements.filter{!$0.isDeleted && $0.managedObjectContext != nil }
    try undo(elements)
   }

  } with: { /* REDO TASK */ [ weak managedObjectContext ] in
   try await managedObjectContext?.perform {
    let elements = weakElements.elements.filter{!$0.isDeleted && $0.managedObjectContext != nil }
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
    if let element = element, !element.isDeleted, let _ = element.managedObjectContext {
     try undo(element)
    }
   }

  } with: { /* UREDO TASK */ [ weak managedObjectContext, weak element  ] in
   try await managedObjectContext?.perform {
    if let element = element, !element.isDeleted, let _ = element.managedObjectContext {
     try redo(element)
    }
   }
  }

 }
 
 
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
 
 public typealias TFolderUndoTask = TUndoTask<Folder>
 public typealias TFolderRedoTask = TRedoTask<Folder>
 
 // This is a default closure expression static getter used as a default Undo/Redo task for adding single element.
 // $0 - parameter is a source container for Undo Task and destination for Redo Task.
 // $1 - parameter is a target for undo & redo tasks.

 public static var addToContainerUndo: TElementUndoTask {{ $0.addToContainer(element: $1) }}
 public static var addToContainerRedo: TElementRedoTask {{ $0.addToContainer(element: $1) }}
 
 
 public func addToContainer(undoTarget element: Element,
                            undo: @escaping TElementUndoTask = Self.addToContainerUndo ,
                            redo: @escaping TElementRedoTask = Self.addToContainerRedo) throws {
  
  guard let sourceSnippet = element.snippet else {
   throw ContextError.noSnippet(object: element, entity: .singleContentElement, operation: .undoMove)
  }
  
  guard let sourceID = sourceSnippet.id else {
   throw ContextError.noID(object: sourceSnippet, entity: .object, operation: .undoMove)
  }
  
  guard let destinationID = self.id else {
   throw ContextError.noID(object: self, entity: .object, operation: .undoMove)
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
 
 public typealias TUndoFoldersCollectionTask = TUndoCollectionTask<Folder>
 public typealias TRedoFoldersCollectionTask = TRedoCollectionTask<Folder>
 
 // This is a default Undo Task closure expression static getter used as a default Undo task for collection.
 // $0 - parameter is a collection of tuples (source container, target) for Undo Task.
 public static var addToContainerUndoMany: TUndoElementsCollectionTask {
  { $0.forEach{ $0.source.addToContainer(element: $0.target) } }
 }
 
 public static var addToContainerFoldersUndoMany: TUndoFoldersCollectionTask {
  { $0.forEach{ $0.source.addToContainer(folder: $0.target) } }
 }
 
 public static var addToContainerRedoMany: TRedoElementsCollectionTask {{ $0.addToContainer(singleElements: $1) }}
  // This is a default Redo Task closure expression static getter used as a default Redo task for collection.
  // $0 - parameter is a destination container for Redo Task.
  // $1 - parameter is a collection of targets for Redo task.
 
 public static var addToContainerFoldersRedoMany: TRedoFoldersCollectionTask {{ $0.addToContainer(folders: $1) }}
 
 public func addToContainer(undoTargets singleElements: [Element],
                            with undo: @escaping TUndoElementsCollectionTask = Self.addToContainerUndoMany,
                            with redo: @escaping TRedoElementsCollectionTask = Self.addToContainerRedoMany) throws {
  
  if singleElements.isEmpty { return }
  
  //Create mapping between elemets ids & corresponding containers ids.
  let sourceSnippetsMap = singleElements.reduce(into: [UUID : UUID]()){
   if let ID = $1.id, let SID = $1.snippet?.id { $0[ID] = SID }
  }
  
  if sourceSnippetsMap.isEmpty { return }
  

  guard let destinationID = self.id else {
   throw ContextError.noID(object: self, entity: .object, operation: .move)
  }
  
  addToContainer(singleElements: singleElements)
  
  registerUndoRedo(elements: singleElements){ elements in
   var sourceTargetTuples = [(Self, Element)]()
   //Obtaining or fetching existing source content containers at the moment of UNDO task execution!
   for element in elements {
    guard let context = element.managedObjectContext else { break }
    guard let ID = element.id else { break }
    guard let sourceID = sourceSnippetsMap[ID] else { break }
    guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { break }
    sourceTargetTuples.append((source: sourceSnippet, target: element))
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
 
 public static var removeFromContainerUndo: TElementUndoTask {{ $0.addToContainer     (element: $1) }}
 public static var removeFromContainerRedo: TElementRedoTask {{ $0.removeFromContainer(element: $1) }}
 
 public func removeFromContainer(undoTarget element: Element,
                                 undo: @escaping TElementUndoTask = Self.removeFromContainerUndo,
                                 redo: @escaping TElementRedoTask = Self.removeFromContainerRedo) throws {
  
  guard let sourceSnippet = element.snippet else {
   throw ContextError.noSnippet(object: element, entity: .singleContentElement, operation: .undoMove)
  }
  
  guard let sourceID = sourceSnippet.id else {
   throw ContextError.noID(object: sourceSnippet, entity: .object, operation: .undoMove)
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
 
 
 
 
 public func removeFromContainer(undoTargets singleElements: [Element],
                                 with undo: @escaping TElementsCollectionTask = Self.removeUndoMany,
                                 with redo: @escaping TElementsCollectionTask = Self.removeRedoMany) throws {
  
  if singleElements.isEmpty { return }
  
   //Create mapping between elemets ids & corresponding containers ids.
  let sourceSnippetsMap = singleElements.reduce(into: [UUID : UUID]()){
   if let ID = $1.id, let SID = $1.snippet?.id { $0[ID] = SID }
  }
  
  if sourceSnippetsMap.isEmpty { return }
  
  removeFromContainer(singleElements: singleElements)
  
  
  let stt = { (_ elements: [Element]) -> [(Self, Element)] in
   var sourceTargetTuples = [(Self, Element)]()
    //Obtaining or fetching existing source content containers at the moment of UNDO task execution!
   for element in elements {
    guard let context = element.managedObjectContext else { break }
    guard let ID = element.id else { break }
    guard let sourceID = sourceSnippetsMap[ID] else { break }
    guard let sourceSnippet = Self.existingSnippet(with: sourceID, in: context) else { break }
    sourceTargetTuples.append((source: sourceSnippet, target: element))
   }
   return sourceTargetTuples
   
  }
  
  registerUndoRedo(elements: singleElements){ try undo(stt($0)) } redo: { try redo(stt($0)) }
  
 }
 
 
 

 
 public func addToContainer(undoTarget folder: Folder,
                            with undo: @escaping TUndoRedoTask<Folder>,
                            with redo: @escaping TUndoRedoTask<Folder>)  {
  
  addToContainer(folder: folder)
  registerUndoRedo(element: folder, undo: undo, redo: redo)
  
 }
 
 
 public func addToContainer(undoTargets folders: [Folder],
                            with undo: @escaping TUndoRedoTask<[Folder]>,
                            with redo: @escaping TUndoRedoTask<[Folder]>) {
  
  addToContainer(folders: folders)
  registerUndoRedo(elements: folders, undo: undo, redo: redo)
 }
 
 
 
 
 public func removeFromContainer(undoTarget folder: Folder,
                                 with undo: @escaping TUndoRedoTask<Folder>,
                                 with redo: @escaping TUndoRedoTask<Folder>)  {
  
  
  removeFromContainer(folder: folder)
  registerUndoRedo(element: folder, undo: undo, redo: redo)
  
 }
 
 public func removeFromContainer(undoTargets folders: [Folder],
                                 with undo: @escaping TUndoRedoTask<[Folder]>,
                                 with redo: @escaping TUndoRedoTask<[Folder]>) {
  
  removeFromContainer(folders: folders)
  registerUndoRedo(elements: folders, undo: undo, redo: redo)
 
  
 }
 
 
 
 
}
