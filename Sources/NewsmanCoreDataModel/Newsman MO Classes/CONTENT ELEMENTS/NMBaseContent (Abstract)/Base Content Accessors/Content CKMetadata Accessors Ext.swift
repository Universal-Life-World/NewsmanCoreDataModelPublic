import Foundation

extension NMBaseContent {
 
 @NSManaged fileprivate var primitiveCk_metadata: Data?
 
 public var silentCKMetadata: Data? {
  get { primitiveCk_metadata }
  set { primitiveCk_metadata = newValue }
  }
}
