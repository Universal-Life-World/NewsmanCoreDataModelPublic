
import CoreData

// MARK: CREATE MO operations with model context with async API
@available(iOS 15.0, macOS 12.0, *)
public extension NMCoreDataModel {
 
 // MARK: CREATE in main context.
 @discardableResult
 func create<T: NSManagedObject>(persist: Bool = false,
                                 objectType: T.Type,
                                 with updates: ((T) throws -> ())? = nil) async throws -> T {
  
  let modelMainContext = await mainContext
  return try await mainContext.perform { [ unowned self ] () -> T in
   try Task.checkCancellation()
   let newObject = T(context: modelMainContext)
   (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
   //(newObject as? NMDateGroupStateObservable)?.dateGroupStateUpdater = dateGroupStateUpdater
   return newObject
  }.updated(updates)     //1
   .persisted(persist)   //2
   .withFileStorage()    //3
 }
 
 
 //Helper variant for snippet recovery with existing UUID.
 @discardableResult
 func create<T: NMBaseSnippet>(with ID: UUID,
                               persist: Bool = false,
                               objectType: T.Type,
                               with updates: ((T) throws -> ())? = nil) async throws -> T {
  
  let modelMainContext = await mainContext
  return try await mainContext.perform { [ unowned self ] () -> T in
   try Task.checkCancellation()
   let newObject = T(context: modelMainContext)
   newObject.id = ID
   newObject.locationsProvider = locationsProvider
   return newObject
  }.updated(updates)     //1
   .persisted(persist)   //2
   .withFileStorage()    //3
 }
  
 // MARK: CREATE in main context using entity description.
 @discardableResult
 func create(persist: Bool = false,
             entityType: NSManagedObject.Type,
             with updates: ((NSManagedObject) throws -> ())? = nil) async throws -> NSManagedObject {
  
  
  
  let modelMainContext = await mainContext
  return try await modelMainContext.perform { [unowned self] () -> NSManagedObject in
   try Task.checkCancellation()
   let newObject = NSManagedObject(entity: entityType.entity(), insertInto: modelMainContext)
   (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
//   try updates?(newObject)
   return newObject
  }.updated(updates)   //1
   .persisted(persist) //2
   .withFileStorage()  //3
 }
 
  // MARK: CREATE in background context and fetch in main one for usage.

 func backgroundCreate<T: NSManagedObject>(persist: Bool = false,
                                           objectType: T.Type,
                                           with updates: ((T) throws -> ())? = nil) async throws -> T {
  let bgContext = await newBackgroundContext
  let bgObject = try await bgContext.perform { [unowned self] () -> T in
   try Task.checkCancellation()
   let newObject = T(context: bgContext)
   (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
   return newObject
  }.updated(updates)   //1
   .persisted(persist) //2
   .withFileStorage()  //3
  
  let modelMainContext = await mainContext
  return try await modelMainContext.perform { () -> T in
   try Task.checkCancellation()
   return modelMainContext.object(with: bgObject.objectID) as! T
   
  }
 }

 // MARK: CREATE a batch of homogeneous MOs in MAIN context.
 func create<T: NSManagedObject>(persist: Bool,
                                 objectType: T.Type,
                                 objectCount: Int,
                                 with updates: (([T]) throws -> ())? = nil) async throws -> [T] {
  
  let modelMainContext = await mainContext
  return try await modelMainContext.perform { [unowned self] () -> [T] in
   try Task.checkCancellation()
   var newObjects = [T]()
   for _ in 1...objectCount {
    let newObject = T(context: modelMainContext)
    (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
    newObjects.append(newObject)
   }
   return newObjects
  }.updated(updates)   //1
   .persisted(persist) //2
   .withFileStorage()  //3
  
 }
 
 // MARK: CREATE a batch of homogeneous MOs in background context and fetch in main one for usage.
 func backgroundCreate<T: NSManagedObject>(persist: Bool,
                                           objectType: T.Type,
                                           objectCount: Int,
                                           with updates: (([T]) throws -> ())? = nil) async throws -> [T] {
  
  let bgContext = await newBackgroundContext
  let bgObjects = try await bgContext.perform { [unowned self] () -> [T] in
   try Task.checkCancellation()
   var newObjects = [T]()
   for _ in 1...objectCount {
    let newObject = T(context: bgContext)
    (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
    newObjects.append(newObject)
   }
   return newObjects
  }.updated(updates)   //1
   .persisted(persist) //2
   .withFileStorage()  //3
  
  let modelMainContext = await mainContext
  return try await modelMainContext.perform { [unowned self] () -> [T] in
   try Task.checkCancellation()
   return bgObjects.map{ context.object(with: $0.objectID) } as! [T]
   
  }
 }
 
  // MARK: CREATE a batch of heterogeous MOs in MAIN context!!!
 func create(persist: Bool = false,
             entityTypes: [ NSManagedObject.Type ],
             with updates: (([NSManagedObject]) throws -> ())? = nil) async throws -> [NSManagedObject] {
  
  let modelMainContext = await mainContext
  return try await modelMainContext.perform { [ unowned self] () -> [NSManagedObject] in
   try Task.checkCancellation()
   var newObjects = [NSManagedObject]()
   let entityDescriptions = entityTypes.map{ $0.entity() }
   for entityDescription in entityDescriptions {
    let newObject = NSManagedObject(entity: entityDescription, insertInto: modelMainContext)
    (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
    newObjects.append(newObject)
   }
   return newObjects
  }.updated(updates)   //1
   .persisted(persist) //2
   .withFileStorage()  //3
  
 }
 
 // MARK: CREATE a batch of heterogeous MOs in background context using MO type info and fetch in main one for usage.
 func backgroundCreate(persist: Bool = false,
                       entityTypes: [ NSManagedObject.Type ],
                       with updates: (([NSManagedObject]) throws -> ())? = nil) async throws -> [NSManagedObject] {

  let bgContext = await newBackgroundContext //MOM is loaded here when context is queried!!
  let bgObjects = try await bgContext.perform { [unowned self] () -> [NSManagedObject] in
   try Task.checkCancellation()
   var newObjects = [NSManagedObject]()
   let entityDescriptions = entityTypes.map{ $0.entity() }
    //make sure entity descriptions are initialised after MOM is loaded above!!
   for entityDescription in entityDescriptions {
    let newObject = NSManagedObject(entity: entityDescription, insertInto: bgContext)
    (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
    newObjects.append(newObject)
   }
   return newObjects
  }.updated(updates)   //1
   .persisted(persist) //2
   .withFileStorage()  //3

  let modelMainContext = await mainContext
  return try await modelMainContext.perform { [unowned self] () -> [NSManagedObject] in
   try Task.checkCancellation()
   return bgObjects.map{context.object(with: $0.objectID)} 

  }
 }
 
 // MARK: CREATE in main context with GL info if such services are available.
 func create<T, G, N>(persisted: Bool = true,
                      of objectType: T.Type,
                      with: G.Type,
                      using: N.Type,
                      updated byBlock: ((T) throws -> ())? = nil) async throws -> T
                      where T: NSManagedObject,
                            G: NMGeocoderProtocol,
                            N: NMNetworkMonitorProtocol {
                             
   try await create(persist: persisted,
                    objectType: T.self,
                    with: byBlock).withGeoLocations(with: G.self, using: N.self) as! T
 }
 
 
 // MARK: CREATE with GL info if such services are available in background context and fetch in main one for usage.
 func backgroundCreate<T, G, N>(persisted: Bool = true,
                                of objectType: T.Type,
                                with: G.Type,
                                using: N.Type,
                                updated byBlock: ((T) throws -> ())? = nil) async throws -> T
 where T: NSManagedObject,
       G: NMGeocoderProtocol,
       N: NMNetworkMonitorProtocol {
        
        try await backgroundCreate(persist: persisted,
                                   objectType: T.self,
                                    with: byBlock).withGeoLocations(with: G.self, using: N.self) as! T
       }
 
 
 
 
 
 
}
