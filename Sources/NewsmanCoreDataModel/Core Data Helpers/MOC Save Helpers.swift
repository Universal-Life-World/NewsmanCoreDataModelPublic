import CoreData
import Combine
import RxSwift


public extension NSManagedObjectContext
{
 
 final var backgroundContext: NSManagedObjectContext
 {
  let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
  context.persistentStoreCoordinator = self.persistentStoreCoordinator
  return context
 }
 
 final func saveIfNeeded() throws // save all main queue context changes as needed.
 {
  guard hasChanges else { return } // if it really needs saving proceed...
  try save()
 }
 
 
 private final func executeBlockAndSaveContext<T> (block: () throws -> T, handler: ((Result<T, Error>) -> Void)?)
 {
  let result = Result <T, Error> { () -> T in
   let blockResult = try block()
   try saveIfNeeded()
   return blockResult
  }
  handler?(result)
 }
 
 final func persist<T> ( _ block: @escaping () throws -> T, handler: ((Result<T, Error>) -> Void)?) -> Void
 {
  perform { [unowned self] in self.executeBlockAndSaveContext(block: block, handler: handler) }
 }
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 final func persist<T>( _ block: @escaping () throws -> T) async rethrows -> T
 {
  try await perform { [unowned self] in
   let result = try block()
   try self.saveIfNeeded()
   return result
  }
 }
 
 @available(iOS 13.0, *)
 final func persist<T>( _ block: @escaping () throws -> T) -> Future<T, Error>
 {
  Future<T,Error>{ [unowned self] promise in
   self.persist(block, handler: promise)
  }
 }
 
 @available(iOS 13.0, *)
 final func persist<T>( block: @escaping () throws -> T) -> AnyPublisher<T, Error>
 {
  persist(block).eraseToAnyPublisher()
 }
 
 final func persist<T>( _ block: @escaping () throws -> T) -> Single<T>
 {
  Single<T>.create { [unowned self] promise in
   self.persist(block, handler: promise)
   return Disposables.create()
  }
 }
 

 final func persistAndWait( _ block: @escaping () -> Void, handler: ((Result<Void, Error>) -> Void)?) -> Void
 {
  performAndWait { executeBlockAndSaveContext(block: block, handler: handler) }
 }
 
 
 
}

