
import Foundation
import struct CoreGraphics.CGPoint



extension NMBaseContent {
 
 @NSManaged fileprivate var primitiveArrowMenuPosition: NSValue?
 @NSManaged fileprivate var primitiveArrowMenuTouchPoint: NSValue?
 
 public static let arrowMenuPositionKey   = "arrowMenuPosition"
 public static let arrowMenuTouchPointKey = "arrowMenuTouchPoint"
 
 
//MARK: Accessors for Content Element arrow menu position - CGPoint.
 public var arrowMenuPosition: CGPoint? {
  
  get {
   willAccessValue(forKey: Self.arrowMenuPositionKey)
   guard let position = primitiveArrowMenuPosition else { return nil }
   didAccessValue(forKey: Self.arrowMenuPositionKey)
   return position.cgPointValue
  }
  
  set {
   willChangeValue(forKey: Self.arrowMenuPositionKey)
   guard let position = newValue else { primitiveArrowMenuPosition = nil; return }
   primitiveArrowMenuPosition = NSValue(cgPoint: position)
   didChangeValue(forKey: Self.arrowMenuPositionKey)
  }
  
 }
 
 //MARK: Silent Accessors for Content Element arrow menu position - CGPoint.
 public var silentArrowMenuPosition: CGPoint? {
  get { primitiveArrowMenuPosition?.cgPointValue }
  set {
   guard let position = newValue else { return }
   primitiveArrowMenuPosition = NSValue(cgPoint: position)
  }
  
 }
 
 
 
 //MARK: Accessors for Content Element arrow menu touch point - CGPoint
 public var arrowMenuTouchPoint: CGPoint? {
  
  get {
   willAccessValue(forKey: Self.arrowMenuTouchPointKey)
   guard let position = primitiveArrowMenuTouchPoint else { return nil }
   didAccessValue(forKey: Self.arrowMenuTouchPointKey)
   return position.cgPointValue
  }
  
  set {
   willChangeValue(forKey: Self.arrowMenuTouchPointKey)
   guard let position = newValue else { primitiveArrowMenuTouchPoint = nil; return }
   primitiveArrowMenuTouchPoint = NSValue(cgPoint: position)
   didChangeValue(forKey: Self.arrowMenuTouchPointKey)
  }
  
 }
 
  //MARK: Silent Accessors for Content Element arrow menu touch point - CGPoint.
 public var silentArrowMenuTouchPoint: CGPoint? {
  get { primitiveArrowMenuTouchPoint?.cgPointValue }
  set {
   guard let position = newValue else {  return }
   primitiveArrowMenuTouchPoint = NSValue(cgPoint: position)
  }
 }
 
}
