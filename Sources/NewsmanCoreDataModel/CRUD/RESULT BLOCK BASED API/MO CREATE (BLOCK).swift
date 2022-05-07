
import Foundation
import CoreData
import RxSwift



@available(iOS 14.0, *)
public extension NMCoreDataModel
{
 // MARK: CREATE MO operations with model context
 
 func create<T: NSManagedObject>(persist: Bool = false,
                                 objectType: T.Type,
                                 with updateBlock: ( (T) throws -> () )? = nil,
                                 handler: @escaping (Result<T, Error>)  -> ())
 {
  context.perform { [unowned self] in
   let newObject = T(context: self.context)
   (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
   
   switch Result(catching: { try updateBlock?(newObject) }) {
    case .success(_ ): break
    case .failure(let updateBlockError): context.delete(newObject)
     handler(.failure(updateBlockError))
     return 
   }
   
   guard let objectWithStorage = newObject as? NMFileStorageManageable else {
    guard persist else { handler(.success(newObject)); return }
    let persistResult = Result { try context.saveIfNeeded() }.map{_ in newObject }
    handler (persistResult)
    return
   }
   
   guard persist else {
    objectWithStorage.initFileStorage { initResult in
     handler(initResult.map{_ in newObject })
    }
    return
   }
   
   switch Result(catching: { try context.saveIfNeeded() }) {
    case .success():
     objectWithStorage.initFileStorage { [unowned self] initResult in
      switch initResult {
        case .success() : handler(.success(newObject))
        case .failure(let error): context.delete(newObject)
         handler(.failure(error))
      }
     }
    case .failure(let error): handler(.failure(error))
   }
  
 }
}
 




 
 
 // MARK: READ (FETCH) MO operations from model context
 
 
 // MARK: UPDATE MO operations in the model context
 
 
 // MARK: DELETE MO operations
 
}
