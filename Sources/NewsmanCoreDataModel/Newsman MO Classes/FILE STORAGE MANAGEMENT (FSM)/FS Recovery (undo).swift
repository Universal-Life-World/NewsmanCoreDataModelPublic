

import Foundation

public extension NMFileStorageManageable  {
 var recoveryURL: URL? {
  guard let url = url else { return nil }
  
  return NMCoreDataModel.recoveryFolderURL?.appendingPathComponent(url.lastPathComponent)
  
 }
 
}
