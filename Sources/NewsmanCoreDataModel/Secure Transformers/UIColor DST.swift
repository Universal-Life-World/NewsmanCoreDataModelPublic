#if !os(macOS)
import UIKit

@available(iOS 12.0, *)
public final class UIColorDataSecureTransformer: NSSecureUnarchiveFromDataTransformer {
  
  public static let name = NSValueTransformerName(rawValue: String(describing: UIColorDataSecureTransformer.self))
 
  public static func register()
  {
   let transformer = UIColorDataSecureTransformer()
   ValueTransformer.setValueTransformer(transformer, forName: name)
  }
  
  public override class func allowsReverseTransformation() -> Bool { true }
    
  public override class func transformedValueClass() -> AnyClass { UIColor.self }
    
  public override class var allowedTopLevelClasses: [AnyClass] { [UIColor.self] }

  public override func transformedValue(_ value: Any?) -> Any?
  {
   guard let data = value as? Data else {
      fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
    }
    return super.transformedValue(data)
  }
    
  public override func reverseTransformedValue(_ value: Any?) -> Any?
  {
    guard let value = value as? UIColor else {
     fatalError("Wrong data type: value must be a UIColor object; received \(type(of: value))")
    }
    return super.reverseTransformedValue(value)
  }
}
#endif
