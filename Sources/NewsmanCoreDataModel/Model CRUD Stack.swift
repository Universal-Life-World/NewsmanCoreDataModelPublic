
import Foundation
import CoreData


public extension NMCoreDataModel
{
 // MARK: CREATE MO operations with model context
 
 func new<T: NMFileStorageManageable>(handler: @escaping (T) throws -> ())
 {
  context.perform { [unowned self] in
    let new = T(context: self.context)
    new.initFileStorage {
     switch $0
     {
      case .success(): break
      case .failure(let error as ContextError): error.log()
      case .failure(let error as NSError): print(error.localizedDescription)
      default: break
     }
     try? handler(new)
    }
    
  }
 }
 
 func new<T: NMFileStorageManageable>(object: T.Type, handler: @escaping (T) throws -> ())
 {
  new(handler: handler)
 }
 
 
 
 // MARK: READ (FETCH) MO operations from model context
 
 
 // MARK: UPDATE MO operations in the model context
 
 
 // MARK: DELETE MO operations
 
}
