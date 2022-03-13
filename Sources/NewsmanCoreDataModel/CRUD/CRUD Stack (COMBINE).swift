
import Foundation
import Combine
import CoreData


@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension NSManagedObject {
 
 func updated<T: NSManagedObject>(_ block: ( (T) throws -> () )? ) -> AnyPublisher<T, Error> {
  Future <T, Error> { [unowned self] promise in
  
   guard let context = self.managedObjectContext else {
    promise(.failure(ContextError.noContext(object: self, entity: .object, operation: .updateObject)))
    return
   }
   
   guard let block = block else {
    promise(.success(self as! T))
    return
   }
   
   context.perform {
    
    guard self.isDeleted == false else {
     promise(.failure(ContextError.isDeleted(object: self, entity: .object, operation: .updateObject)))
     return
    }
    
    do {
     try block(self as! T)
     promise(.success(self as! T))
    }
    catch {
     context.delete(self)
     promise(.failure(error))
    }
   }
  }.eraseToAnyPublisher()
  
 }//func updated<T: NSManagedObject>(_ block: ( (T) throws -> () )? ) -> AnyPublisher<T, Error>...
 
 func persisted<T: NSManagedObject>(_ persist: Bool = true ) -> AnyPublisher<T, Error> {
  Future <T, Error> { promise in
   
   
   guard persist else {
    promise(.success(self as! T))
    return
   }
   
   guard let context = self.managedObjectContext else {
    promise(.failure(ContextError.noContext(object: self, entity: .object, operation: .persistObject)))
    return
   }
   
   context.perform {
    guard self.hasChanges else {
     promise(.success(self as! T))
     return
    }
    
    do {
     try context.save()
     promise(.success(self as! T))
    } catch {
     promise(.failure(error))
    }
   
   }
  }.eraseToAnyPublisher()
  
 }//func persisted<T: NSManagedObject>(_ persist: Bool = true ) -> AnyPublisher<T, Error>...
 
 func withFileStorage<T: NSManagedObject>() -> AnyPublisher<T, Error> {
  Future <T, Error> { promise in
  
   guard let context = self.managedObjectContext else {
    promise(.failure(ContextError.noContext(object: self, entity: .object, operation: .storageCreate)))
    return
   }
   
   guard let manageStorage = self as? NMFileStorageManageable else {
    promise(.success(self as! T))
    return
   }
   
   context.perform {
    
    guard self.isDeleted == false else {
     promise(.failure(ContextError.isDeleted(object: self, entity: .object, operation: .updateObject)))
     return
    }
    
    guard let url = manageStorage.url else {
     promise(.failure(ContextError.noURL(object: self, entity: .object, operation: .storageCreate)))
     return
    }
    
    if FileManager.default.fileExists(atPath: url.path)  {
     promise(.success(self as! T))
     return
    }
    
    FileManager.createDirectoryOnDisk(at: url){ result in
     promise(result.map{_ in self as! T } )
    }
   }
   
   
  
  }.eraseToAnyPublisher()

 }//func withFileStorage<T: NSManagedObject>() -> AnyPublisher<T, Error>...
 
 func withGeoLocations<G, N>(with geocoderType: G.Type,
                             using networkMonitorType: N.Type) -> AnyPublisher<NSManagedObject, Error>
                             where G: NMGeocoderProtocol,
                                   N: NMNetworkMonitorProtocol
 {
  
  Future<NSManagedObject, Error>{ [ unowned self] promise in
   guard let context = managedObjectContext else {
    promise(.failure(ContextError.noContext(object: self, entity: .object, operation: .updateObject)))
    return
   }
   
   
   guard let withLocations = self as? NMGeoLocationProvidable else {
    promise (.success(self))
    return
   }
   
   guard let locationsProvider = withLocations.locationsProvider else {
    promise (.success(self))
    return

   }
   
   context.perform {
    defer { promise (.success(self)) }
    
    if withLocations.isDeleted  { return }
 
    switch (withLocations.geoLocation, withLocations.location) {
     case (nil, nil):
      withLocations.geoLocationSubscription = locationsProvider
       .locationFixPublisher
       .receive(on: DispatchQueue.global(qos: .utility))
       .handleEvents(receiveOutput: { location in
        context.perform { withLocations.geoLocation = location }
       })
       .flatMap { $0.getPlacemarkPublisher(geocoderType.self, networkMonitorType.self) }
       .replaceError(with: nil)
       .compactMap{ $0?.addressString }
       .sink { address in
         context.perform { withLocations.location = address }
       }
      
     case (let geoLocation?, nil):
      withLocations.geoLocationSubscription = geoLocation
       .getPlacemarkPublisher(geocoderType.self, networkMonitorType.self)
       .receive(on: DispatchQueue.global(qos: .utility))
       .replaceError(with: nil)
       .compactMap{ $0?.addressString }
       .sink { address in
        context.perform { withLocations.location = address }
       }
      
     default: break
      
       
    }
    
    
   }
   
  }.eraseToAnyPublisher()
                                    
 }
 
 
}
 
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension NMCoreDataModel {
 
 // MARK: CREATE in main context.
 func create<T: NSManagedObject>(persist: Bool = false,
                                 objectType: T.Type,
                                 with updates: ((T) throws -> ())? = nil)  -> AnyPublisher<T, Error> {
  
  Future<T, Error> { [unowned self] promise in
   context.perform {
    let newObject = T(context: context)
    (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
    promise(.success(newObject))
   }
  }
  .flatMap{ $0.updated(updates) }
  .flatMap{ $0.persisted(persist) }
  .flatMap{ $0.withFileStorage() }
  .eraseToAnyPublisher()
  
 }
 
  // MARK: CREATE in background context and fetch in main one for usage.
 func backgroundCreate<T: NSManagedObject>(persist: Bool = false,
                                           objectType: T.Type,
                                           with updates: ((T) throws -> ())? = nil) -> AnyPublisher<T, Error> {
  Future<T, Error> { [unowned self] promise in
   let bgMOC = bgContext // cerate one BG MOC ONCE & use it...
   bgMOC.perform {
    let newObject = T(context:  bgMOC)
    (newObject as? NMGeoLocationProvidable)?.locationsProvider = locationsProvider
    promise(.success(newObject))
   }
  }
  .flatMap{ $0.updated(updates) }
  .flatMap{ $0.persisted(persist) }
  .flatMap{ $0.withFileStorage() }
  .flatMap{ bgObject in
    Future<T, Error> { [unowned self] promise in
     context.perform {
      let mainContextObject = context.object(with: bgObject.objectID) as! T
      promise(.success(mainContextObject))
     }
    }
  }.eraseToAnyPublisher()
  
 }
 
  // MARK: CREATE in main context with GL info.
 func create<T, G, N>(persist: Bool = false,
                      objectType: T.Type,
                      with geocoderType: G.Type,
                      using networkMonitorType: N.Type,
                      with updates: ((T) throws -> ())? = nil)  -> AnyPublisher<T, Error>
                      where T: NSManagedObject,
                            G: NMGeocoderProtocol,
                            N: NMNetworkMonitorProtocol
 
 {
  
  create(persist: persist, objectType: T.self, with: updates)
   .flatMap{ $0.withGeoLocations(with: G.self, using: N.self) }
   .map { $0 as! T}
   .eraseToAnyPublisher()
  
 }
 
}

