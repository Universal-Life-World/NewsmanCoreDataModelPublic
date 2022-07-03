
import Foundation


public final class WeakContainer<E: AnyObject>: @unchecked Sendable {
 
 private let pointerArray = NSPointerArray(options: .weakMemory)
 
 private let isolationQueue = DispatchQueue(label: "isolationQueue.WeakContainer")
 
 public final var elements: [E] { pointerArray.allObjects as? [E] ?? [] }
 
 public final var isEmpty: Bool { elements.isEmpty }
 
 public func removeAll() { pointerArray.count = 0 }
 
 public init () {}
 
 public init <S: Sequence>(sequence: S) where S.Element == E { append(sequence) }
 
 
 public final func append(_ element: E) {
  
  isolationQueue.sync {
    pointerArray.addPointer( Unmanaged.passUnretained(element).toOpaque() )
  }
 }
 
 public final func append <S: Sequence>(_ sequence: S) where S.Element == E {
  
  isolationQueue.sync {
   sequence
    .compactMap{$0}
    .map{ Unmanaged.passUnretained($0).toOpaque() }
    .forEach{ pointerArray.addPointer($0)}
  }
 }
 
 public final subscript(index: Int) -> E?{
  
  get {
   isolationQueue.sync {
    guard let pointer = pointerArray.pointer(at: index) else { return nil }
    return Unmanaged<E>.fromOpaque(pointer).takeUnretainedValue()
   }
  }
  
  set (newElement){
   isolationQueue.sync {
    guard let newElement = newElement else { return }
   
    let pointer = Unmanaged.passUnretained(newElement).toOpaque()
    pointerArray.insertPointer(pointer , at: index)
   }
  }
  
 }


}

 extension Sequence where Self.Element: AnyObject {
  var weakArray: WeakContainer<Self.Element> { .init(sequence: self) }
 }



