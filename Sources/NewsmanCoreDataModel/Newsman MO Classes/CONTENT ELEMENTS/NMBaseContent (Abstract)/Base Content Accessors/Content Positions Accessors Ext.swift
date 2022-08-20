
import Foundation

extension NMBaseContent {
 
 //MARK: Accessors for Content Element Positions field.
 @NSManaged fileprivate var primitivePositions: NSMutableDictionary?
 public static let positionsKey = "positions"
 
 public typealias TContentPositions = [ TPositionKey : Int ]
 
 public var positions: TContentPositions? {
  
  get {
   willAccessValue(forKey: Self.positionsKey)
   guard let rawPos = primitivePositions as? [String: Int] else { return nil }
   let positions = rawPos.map{ (TPositionKey(raw: $0.key), $0.value) }
   didAccessValue(forKey: Self.positionsKey)
   return Dictionary(uniqueKeysWithValues: positions)
  }
  
  set {
   willChangeValue(forKey: Self.positionsKey)
   guard let positions = newValue else { primitivePositions = nil; return }
   let rawPos = positions.map { (key: $0.key.rawString, value: $0.value) }
   primitivePositions = NSMutableDictionary(dictionary: Dictionary(uniqueKeysWithValues: rawPos))
   didChangeValue(forKey: Self.positionsKey)
   
  }
 }
 
 
 //MARK: Silent Accessors for Content Element Positions field.
 public var silentPositions: TContentPositions? {
  
  get {
   guard let rawPos = primitivePositions as? [String: Int] else { return nil }
   let positions = rawPos.map{ (TPositionKey(raw: $0.key), $0.value) }
   return Dictionary(uniqueKeysWithValues: positions)
  }
  
  set {
   guard let positions = newValue else { primitivePositions = nil; return }
   let rawPos = positions.map { (key: $0.key.rawString, value: $0.value) }
   primitivePositions = NSMutableDictionary(dictionary: Dictionary(uniqueKeysWithValues: rawPos))
  }
 }
 
}
