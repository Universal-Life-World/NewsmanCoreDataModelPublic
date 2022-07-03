
import Foundation

public extension NSPredicate {
 static let always = NSPredicate(value: true)
 static let never = NSPredicate(value: false)
 
}

@available(iOS 15.0, macOS 12.0, *)
public extension AsyncSequence {
 var first: Self.Element?  {
  get async throws { try await first{_ in true } }
 }
}


public extension NSCompoundPredicate{
 convenience init(xorPredicateWithSubpredicates subpredicates: [NSPredicate]){
  if subpredicates.count == 1 {
   self.init(andPredicateWithSubpredicates: subpredicates)
   return
  }
  
  let p1 = subpredicates.first!
  let p2 = NSCompoundPredicate(xorPredicateWithSubpredicates: Array(subpredicates.dropFirst()))
  
  self.init(orPredicateWithSubpredicates: [
   Self(andPredicateWithSubpredicates: [ Self(notPredicateWithSubpredicate: p1), p2 ]),
   Self(andPredicateWithSubpredicates: [ Self(notPredicateWithSubpredicate: p2), p1 ]) ])
 }
}


public extension NSPredicate {
 static func + (p1: NSPredicate, p2: NSPredicate) -> NSPredicate {
  NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2])
 }
 
 static func - (p1: NSPredicate, p2: NSPredicate) -> NSPredicate {
  NSCompoundPredicate(xorPredicateWithSubpredicates: [p1, p2])
 }
 
 static func * (p1: NSPredicate, p2: NSPredicate) -> NSPredicate {
  NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
 }
 
 static prefix func !(p: NSPredicate) -> NSPredicate {
  NSCompoundPredicate(notPredicateWithSubpredicate: p)
 }
}
