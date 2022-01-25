import Foundation

public protocol NMEnumCasesStringLocalizable where Self: RawRepresentable
{
 var localizedString: String { get }
}

public extension NMEnumCasesStringLocalizable where  Self.RawValue == String
{
 var localizedString: String { NSLocalizedString(rawValue, comment: rawValue) }
}
