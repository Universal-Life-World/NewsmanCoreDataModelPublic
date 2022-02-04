
import CoreData

@available(iOS 15.0, *) @available(macOS 12.0.0, *)
public extension NSManagedObject
{
 
 func updated<T: NSManagedObject>(_ block: ( (T) throws -> () )? ) async throws -> T
 {
  guard let self  = self as? T else {
   fatalError("Wrong object type!!! <T> must be NSManagedObject!")
  }
 
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .updateObject)
  }
 
  guard self.isDeleted == false else {
   throw ContextError.isDeleted(object: self, entity: .object, operation: .updateObject)
  }
  
  guard let block = block else { return self }
 
  return try await context.perform { [ unowned self ] in
   do {
    try block(self)
    return self
   }
   catch {
    context.delete(self)
    throw error
   }
  }
 }
 
 
 func persisted<T: NSManagedObject>(_ persist: Bool = true ) async throws -> T
 {
  guard let self  = self as? T else {
   fatalError("Wrong object type!!! <T> must be NSManagedObject!")
  }
  guard persist else { return self }
 
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .persistObject )
  }
  
  return try await context.perform { [ unowned self ] in
   guard self.hasChanges else { return self }
   try context.save()
   return self
  }
 }
 
 func withFileStorage<T: NSManagedObject>() async throws -> T
 {
  guard let self  = self as? T else {
   fatalError("Wrong object type!!! <T> must be NSManagedObject!")
  }
  guard let manageStorage = self as? NMFileStorageManageable else { return self  }
  return try await manageStorage.withFileStorage() as! T
 }
 
 func withGeoLocations<G, N>(with geocoderType: G.Type,
                             using networkMonitorType: N.Type) async throws -> NSManagedObject
                             where G: NMGeocoderProtocol,
                                   N: NMNetworkMonitorProtocol
 {
  guard let context = managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .updateObject)
  }
  
  guard isDeleted == false else {
   throw ContextError.isDeleted(object: self, entity: .object, operation: .updateObject)
  }
  
  guard let withLocations = self as? NMGeoLocationProvidable else { return self }
  guard let locationsProvider = withLocations.locationsProvider else { return self }
  
  switch (await context.perform { (withLocations.geoLocation, withLocations.location) }) {
   case (let location?, nil ):
    let location = try await location.getPlacemark(with: G.self, using: N.self).addressString
    
    await context.perform {
     withLocations.location = location
    }
    
   case (nil , nil ):
    let location = try await locationsProvider.locationFix
    let address = try await location.getPlacemark(with: G.self, using: N.self).addressString
    
    await context.perform {
     withLocations.geoLocation = location
     withLocations.location = address
    }
    
   
   default: break
    
  }
 
  return self
 
 }//func withGeoLocations<G, N>(with geocoderType: G.Type,...
 
}//public extension NSManagedObject...



@available(iOS 15.0, *) @available(macOS 12.0.0, *)
public extension NMCoreDataModel
{
 // MARK: CREATE MO operations with model context with async API
 func create<T: NSManagedObject>(persist: Bool = false,
                                 objectType: T.Type,
                                 with updates: ((T) throws -> ())? = nil) async throws -> T
 {
  try await context.perform { [unowned self] () -> T in
   let newObject = T(context: self.context)
   (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
   return newObject
  }
  .updated(updates)
  .persisted(persist)
  .withFileStorage()
 }
  
 
 func create<T, G, N>(persisted: Bool = true,
                      of objectType: T.Type,
                      with: G.Type,
                      using: N.Type,
                      updated byBlock: ((T) throws -> ())? = nil) async throws -> T
                      where T: NSManagedObject,
                            G: NMGeocoderProtocol,
                            N: NMNetworkMonitorProtocol
 {
  try await create(persist: persisted, objectType: T.self, with: byBlock)
   .withGeoLocations(with: G.self, using: N.self) as! T
 }
 
 
 
  // MARK: READ (FETCH) MO operations from model context
  
  
  // MARK: UPDATE MO operations in the model context
  
  
  // MARK: DELETE MO operations
}
