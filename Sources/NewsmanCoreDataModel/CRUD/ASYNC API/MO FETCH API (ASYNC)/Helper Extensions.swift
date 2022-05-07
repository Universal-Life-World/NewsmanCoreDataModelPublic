
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
