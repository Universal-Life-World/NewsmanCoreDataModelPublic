
import Foundation
public protocol NMEnumOptionalCasesManageable where Self: Hashable
{
 static var isolationQueue: DispatchQueue { get }
 static var enabled: [ Self : Bool ] { get set }
 var isCaseEnabled: Bool { get set }
}

public extension NMEnumOptionalCasesManageable where Self: CaseIterable
{
 var isCaseEnabled: Bool
 {
  get { Self.isolationQueue.sync{ Self.enabled[self]! } }
  set { Self.isolationQueue.sync{ Self.enabled[self] = newValue } }
 }
}
