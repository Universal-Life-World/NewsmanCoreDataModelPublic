
import Foundation
import CoreData


public extension NMCoreDataModel
{
 // MARK: CREATE MO operations with model context
 
 func create<T: NSManagedObject>(persist: Bool = false,
                                 objectType: T.Type,
                                 handler: @escaping (Result<T, Error>)  -> ())
 {
  context.perform { [unowned self] in
   let newObject = T(context: self.context)
   
   guard let objectWithStorage = newObject as? NMFileStorageManageable else
   {
    guard persist else { handler(.success(newObject)); return }
    let persistResult = Result { try context.saveIfNeeded() }.map{_ in newObject }
    handler (persistResult)
    return
   }
   
   objectWithStorage.initFileStorage {initResult in
    context.perform {[unowned self] in
      switch initResult {
       case .success() :
        let objectURL = objectWithStorage.url!
        guard persist else { handler(.success(newObject)); return }
    
         switch Result(catching: { try context.saveIfNeeded() }) {
          case .success(): handler(.success(newObject))
          case .failure(let persistError):
           handler(.failure(persistError))
           FileManager.removeItemFromDisk(at: objectURL) {
             switch $0 {
              case .success(): print ("FILE STORAGE IS DELETED SUCCESSFULLY AFTER CONTEXT ERROR!")
              case .failure(let error): print (error.localizedDescription)
             
             }
           }
        }
       
       case .failure(let error): context.delete(newObject)
        handler(.failure(error))
    
     }
    }
  }
 }
}

@available(iOS 15.0, *) @available(macOS 12.0.0, *)
func create<T: NSManagedObject>(persisted: Bool = false,
                                objectType: T.Type,
                                with setUp: ((T) throws -> ())? = nil) async throws -> T
{
 let newObject = try await context.perform { [ unowned self ] () throws -> T in
  let newObject = T(context: self.context)
  try setUp?(newObject)
  return newObject
 }

 guard let objectWithStorage = newObject as? NMFileStorageManageable else
 {
  if persisted { try context.saveIfNeeded() }
  return newObject
 }
 
 let objectURL = objectWithStorage.url!
 do {
  try await objectWithStorage.initFileStorage()
  if persisted { try context.saveIfNeeded() }
 }
 catch {
  await context.perform { [ unowned self ] in self.context.delete(newObject) }
  try await FileManager.removeItemFromDisk(at: objectURL)
  throw error
 }
 
 return newObject
 }
 

 
 
 // MARK: READ (FETCH) MO operations from model context
 
 
 // MARK: UPDATE MO operations in the model context
 
 
 // MARK: DELETE MO operations
 
}
