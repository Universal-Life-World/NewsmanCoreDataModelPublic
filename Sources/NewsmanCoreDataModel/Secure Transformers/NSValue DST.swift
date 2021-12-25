
import Foundation

public final class NSValueDataSecureTransformer: NSSecureUnarchiveFromDataTransformer
{
  
  public static let name = NSValueTransformerName(rawValue: String(describing: NSValueDataSecureTransformer.self))
 
  public static func register()
  {
   let transformer = NSValueDataSecureTransformer()
   ValueTransformer.setValueTransformer(transformer, forName: name)
  }
  
  public override class func allowsReverseTransformation() -> Bool { true }
    
  public override class func transformedValueClass() -> AnyClass { NSValue.self }
    
  public override class var allowedTopLevelClasses: [AnyClass] { [NSValue.self] }

  public override func transformedValue(_ value: Any?) -> Any?
  {
   guard let data = value as? Data else {
      fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
    }
    return super.transformedValue(data)
  }
    
  public override func reverseTransformedValue(_ value: Any?) -> Any?
  {
    guard let value = value as? NSValue else {
     fatalError("Wrong data type: value must be a NSValue object; received \(type(of: value))")
    }
    return super.reverseTransformedValue(value)
  }
}

