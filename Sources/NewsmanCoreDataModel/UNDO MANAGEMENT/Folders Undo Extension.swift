import CoreData

@available(iOS 15.0, macOS 12.0, *)
extension NMUndoManageable where Self: NMContentFolder {
 
 
 fileprivate func registerUndoRedo(elements: [Element],
                                   undo: @escaping @Sendable ([Element]) -> (),
                                   redo: @escaping @Sendable ([Element]) -> ()) {
  
  let weakElements = WeakContainer(sequence: elements)
  
  NMUndoSession.register { [ weak managedObjectContext ] in
   await managedObjectContext?.perform {
    let elements = weakElements.elements.filter{ !$0.isDeleted && $0.managedObjectContext != nil }
    undo(elements)
   }
   
  } with: { [ weak managedObjectContext ] in
   await managedObjectContext?.perform {
    let elements = weakElements.elements.filter{ !$0.isDeleted && $0.managedObjectContext != nil }
    redo(elements)
   }
  }
 }
 
 fileprivate func registerUndoRedo (element: Element,
                                    undo: @escaping @Sendable (Element) -> (),
                                    redo: @escaping @Sendable (Element) -> ()) {
  
  NMUndoSession.register { [ weak managedObjectContext, weak element ] in
   await managedObjectContext?.perform {
    if let element = element, !element.isDeleted, let _ = element.managedObjectContext  {
     undo(element)
    }
   }
   
  } with: { [ weak managedObjectContext, weak element  ] in
   await managedObjectContext?.perform {
    if let element = element, !element.isDeleted, let _ = element.managedObjectContext {
     redo(element)
    }
   }
  }
  
 }
 
 
 func addToContainer(singleElements: [Element],
                     with undo: @escaping @Sendable ([Element]) -> (),
                     with redo: @escaping @Sendable ([Element]) -> ()) {
  
 }
 
 func addToContainer(elements: Element,
                     with undo: @escaping @Sendable (Element) -> (),
                     with redo: @escaping @Sendable (Element) -> ()) {
  
 }
 
 
 func removeFromContainer(singleElements: [Element],
                          with undo: @escaping @Sendable ([Element]) -> (),
                          with redo: @escaping @Sendable ([Element]) -> ()){
  
 }
 
 
 func removeFromContainer(element: Element,
                          with undo: @escaping @Sendable (Element) -> (),
                          with redo: @escaping @Sendable (Element) -> ()){
  
 }
 
}
