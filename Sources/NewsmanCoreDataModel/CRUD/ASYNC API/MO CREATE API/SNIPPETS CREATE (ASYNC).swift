
import CoreData

@available(iOS 15.0, macOS 12.0, *)
public extension Collection where Element: NSManagedObject {
 func updated(_ block: ( ([Element]) throws -> () )? ) async throws -> [ Element ] {
  try Task.checkCancellation()
  
  guard let block = block else { return Array(self) }
  
  let contexts = Array(Set(compactMap(\.managedObjectContext)))
  
  if contexts.isEmpty { return [] }
  
  guard contexts.count == 1 else {
   throw ContextError.multipleContextsInCollection(collection: Array(self))
  }
  
  let context = contexts.first!
  
  return try await context.perform {
   try Task.checkCancellation()
   let validObjects = filter{ $0.managedObjectContext != nil && $0.isDeleted == false }
   do {
    try block(validObjects)
    return validObjects
   }
   catch {
    validObjects.forEach{ context.delete($0) }
    throw error
   }
  }
  
 }
 
 func persisted(_ persist: Bool = true ) async throws -> [ Element ] {
  try Task.checkCancellation()

  guard persist else { return Array(self) }
  
  let contexts = Array(Set(compactMap(\.managedObjectContext)))
  
  if contexts.isEmpty { return [] }
  
  guard contexts.count == 1 else {
   throw ContextError.multipleContextsInCollection(collection: Array(self))
  }
  
  let context = contexts.first!
  
  return try await context.perform {
   try Task.checkCancellation()
   let validObjects = filter{ $0.managedObjectContext != nil && $0.isDeleted == false }
   guard validObjects.contains(where: \.hasChanges) else { return validObjects }
   try context.save()
   return validObjects
  }
 }
 
 func withFileStorage() async throws -> [ Element ] {
  try Task.checkCancellation()
  
  return try await withThrowingTaskGroup(of: Element?.self, returning: [Element].self)
  { group in
   forEach { object in
    guard let context = object.managedObjectContext else { return }
    group.addTask {
     try Task.checkCancellation()
     if ( await context.perform { object.isDeleted }) { return nil }
     return try await object.withFileStorage()
     
    }
   }
   return try await group.compactMap{ $0 }.reduce(into: []) { $0.append($1) }
  }
 }
 
}

@available(iOS 15.0, macOS 12.0, *)
public extension NSManagedObject {
 
 func updated<T: NSManagedObject>(_ block: ( (T) throws -> () )? ) async throws -> T {
  try Task.checkCancellation()
 
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .updateObject)
  }
 
  guard let block = block else { return self as! T }
 
  return try await context.perform { [ unowned self ] in
   do {
    try Task.checkCancellation()
    
    guard self.isDeleted == false else {
     throw ContextError.isDeleted(object: self, entity: .object, operation: .updateObject)
    }
    
    try block(self as! T)
    return self as! T
   }
   catch {
    context.delete(self)
    throw error
   }
  }
 }
 
 
 
 
 func persisted<T: NSManagedObject>(_ persist: Bool = true ) async throws -> T {
  try Task.checkCancellation()
  
  guard persist else { return self as! T }
 
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .persistObject )
  }
  
  return try await context.perform { [ unowned self ] in
   try Task.checkCancellation()
   guard self.hasChanges else { return self as! T }
   try context.save()
   return self as! T
  }
 }
 
 func withFileStorage<T: NSManagedObject>() async throws -> T {
  try Task.checkCancellation()
  guard let manageStorage = self as? NMFileStorageManageable else { return self as! T  }
  return try await manageStorage.withFileStorage() as! T
 }
 
 
 //MARK: ASYNC METHOD TO UPDATE GPS COORDINATES OF CONFORMED OBJECT AND THEN GEOCODE THEM INTO STRING ADDRESS.
 func withGeoLocations<G, N>(with geocoderType: G.Type,
                             using networkMonitorType: N.Type) async throws -> NSManagedObject
                             where G: NMGeocoderProtocol,
                                   N: NMNetworkMonitorProtocol {
  
  try Task.checkCancellation()
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .updateObject)
  }
 
  try await context.perform {
   guard self.isDeleted == false else {
    throw ContextError.isDeleted(object: self, entity: .object, operation: .updateObject)
   }
  }
  
  guard let withLocations = self as? NMGeoLocationProvidable else { return self }
  
  guard let locationsProvider = withLocations.locationsProvider else { return self }
                                    
  print (#function, "START... \(locationsProvider)")
                                    
  switch (await context.perform { (withLocations.geoLocation, withLocations.location) }) {
   case (let location?, nil ):
    try Task.checkCancellation()
    let locationStr = try await location.getPlacemark(with: G.self, using: N.self).addressString
    
    try await context.perform {
     try Task.checkCancellation()
     guard withLocations.managedObjectContext != nil else { return }
     withLocations.location = locationStr
    }
    
   case ( nil , nil ):
    try Task.checkCancellation()
    print ("AWAIT FOR LOCATION FIX...")
    let location = try await locationsProvider.locationFix
    
    print ("AWAIT FOR PLACEMARK...")
    try await context.perform {
     try Task.checkCancellation()
     guard withLocations.managedObjectContext != nil else { return }
    
     withLocations.geoLocation = location
     
     print ("UPDATED GEO LOCATION FOR \(String(describing: Swift.type(of: self))) IN {\(String(describing: withLocations.managedObjectContext))} with VALUE: \(location)")
    }
    
    try Task.checkCancellation()
    let address = try await location.getPlacemark(with: G.self, using: N.self).addressString
    try await context.perform {
     try Task.checkCancellation()
     guard withLocations.managedObjectContext != nil else { return }
     withLocations.location = address
     

     print ("UPDATED GEOCODED ADDRESS \(String(describing: Swift.type(of: self))) IN {\(String(describing: withLocations.managedObjectContext))} with VALUE: \(address)")
    }
    
   
    // print ("PLACEMARK IS READY \(address)")
    
   
   default: break
    
  }
//  print (#function, "IS DONE!")
  return self
 
 }//func withGeoLocations<G, N>(with geocoderType: G.Type,...
 
}//public extension NSManagedObject...



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
  }.updated(updates)   //1
   .persisted(persist)   //2
   .withFileStorage()    //3
 }
 
 //MARK: CREATE single type child element with parent container in main context.
// func create<T, P> (in parent: P, persist: Bool = false,
//                    contained: T.Type,
//                    with updates: ((T) throws -> ())? = nil) async throws -> T
//
// where P: NMContentElementsContainer, P.SingleType == T {
//  try await create(persist: persist, objectType: T.self){
//   parent.insert(newElements: [$0])
//   try updates?($0)
//  }
// }
 
  //MARK: CREATE folder type child element with parent container in main context.
// func create<T, P> (in parent: P, persist: Bool = false,
//                    contained: T.Type,
//                    with updates: ((T) throws -> ())? = nil) async throws -> T
// 
// where P: NMContentElementsContainer, P.FolderType == T {
//  try await create(persist: persist, objectType: T.self){
//   parent.insert(newElements: [$0])
//   try updates?($0)
//  }
// }
  
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
