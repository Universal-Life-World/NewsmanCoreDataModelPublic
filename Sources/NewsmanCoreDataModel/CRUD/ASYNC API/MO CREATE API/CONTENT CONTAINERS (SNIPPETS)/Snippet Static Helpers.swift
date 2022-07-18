
import CoreData

@available(iOS 15.0, macOS 12.0, *)
extension NMContentElementsContainer {
 
 @discardableResult
 public static func create(in context: NSManagedObjectContext,
                           persist: Bool = false,
                           with updates: ((Self) throws -> ())? = nil) async throws -> Self {
  
  try await context.perform { () -> Self in
   try Task.checkCancellation()
   let newObject = Self(context: context)
   newObject.locationsProvider = context.locationsProvider
   return newObject
  }.updated(updates)     //1
   .persisted(persist)   //2
   .withFileStorage()    //3
 }
 
 @discardableResult
 public static func create(in model: NMCoreDataModel,
                           persist: Bool = false,
                           with updates: ((Self) throws -> ())? = nil) async throws -> Self {
  
  try await model.create(persist: persist, objectType: Self.self, with: updates)
 }
 
 @discardableResult
 public static func backgroundCreate(in model: NMCoreDataModel,
                                     persist: Bool = false,
                                     with updates: ((Self) throws -> ())? = nil) async throws -> Self {
  
  try await model.backgroundCreate(persist: persist, objectType: Self.self, with: updates)
 }
 
}
