import Foundation

@available(iOS 12.0, *)
public final class GenericDataSecureTransformer<T: NSSecureCoding>: NSSecureUnarchiveFromDataTransformer
{
  public static var name: NSValueTransformerName
  {
   NSValueTransformerName(rawValue: String(describing: T.self) + "DataSecureTransformer")
  }
 
  public static func register()
  {
   let transformer = GenericDataSecureTransformer<T>()
   ValueTransformer.setValueTransformer(transformer, forName: name)
  }
  
  public override class func allowsReverseTransformation() -> Bool { true }
    
  public override class func transformedValueClass() -> AnyClass { T.self }
    
  public override class var allowedTopLevelClasses: [AnyClass] { [T.self] }

  public override func transformedValue(_ value: Any?) -> Any?
  {
   guard let data = value as? Data else {
      fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
    }
    return super.transformedValue(data)
  }
    
  public override func reverseTransformedValue(_ value: Any?) -> Any?
  {
    guard let value = value as? T else {
     fatalError("Wrong data type: value must be a \(String(describing: T.self)) object; received \(type(of: value))")
    }
    return super.reverseTransformedValue(value)
  }
}
