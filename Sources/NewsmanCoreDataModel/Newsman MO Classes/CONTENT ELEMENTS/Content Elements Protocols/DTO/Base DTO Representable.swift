import Foundation

public protocol DTORepresentable where Self: Hashable {
 var fields: NSDictionary { get }
}

public extension DTORepresentable {
 subscript<Keys: RawRepresentable> (key: Keys) -> Any? { fields[key.rawValue] }
}
