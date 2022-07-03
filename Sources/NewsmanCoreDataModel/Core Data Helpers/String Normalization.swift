import Foundation

extension String {
 
 public var normalizedForSearch: String? {
  applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower"), reverse: false)
 }
 
 
}

extension String {
 
 public static let normalizedFieldNamePrefix = "normalizedSearch"
 
 public func capitalizingFirstLetter() -> String {
  return prefix(1).capitalized + dropFirst()
 }
 
 
 
 mutating func capitalizeFirstLetter() {
  self = self.capitalizingFirstLetter()
 }
}

extension String {
 public var normalizedSearchKeyPath: String { Self.normalizedFieldNamePrefix + capitalizingFirstLetter() }
}
