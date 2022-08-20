
import Foundation
import CoreData
import CoreLocation
import Combine


@available(iOS 13.0, *)
public protocol NMGeoLocationProvidable where Self: NSManagedObject {

 var locationsProvider: NMGeoLocationsProvider?           { get set }
 var latitude: NSNumber?                                  { get set }
 var longitude: NSNumber?                                 { get set }
 var location: String?                                    { get set }
 
 var geoLocationSubscription: AnyCancellable?             { get set } //NEEDED ONLY FOR COMBINE API!
 
 //@available(iOS 15.0, macOS 12.0, *)
 //func updateGeoLocationsAfterFetch() //PROVIDED IN PROTO EXT!
 
 var updateGeoLocationsTask: Task<NSManagedObject, Error>? { get set } //NEEDED FOR FULLY ASYNC API!
 
// func updateGeoLocations<G, N> (with geocoderType: G.Type,
//                                using networkWaiterType: N.Type)
//                                where G: NMGeocoderProtocol,
//                                      N: NMNetworkMonitorProtocol //PROVIDED IN PROTO EXT!
}


extension NMBaseSnippet: NMGeoLocationProvidable {}
extension NMBaseContent: NMGeoLocationProvidable {}

@available(iOS 15.0, macOS 12.0, *)
//THIS VARIANT IS USED FOR UNIT TESTING ONLY USING NW & GCS MOCKS!!!
//USES FULLY ASYNC API FOR ALL SUBCLASSES OF BASE SNIPPET.
public extension NMBaseSnippet {
 
 func updateGeoLocationsAfterFetch() { //print("\(#function)")
  locationsProvider = managedObjectContext?.locationsProvider
  let workingTask = updateGeoLocationsTask
  updateGeoLocationsTask = Task.detached(priority: .medium) {
   if let snippet = try? await workingTask?.value { return snippet }
   
   return try await self.withGeoLocations(with: NMLocationsGeocoderMock.self,
                                          using: NMNetworkWaiterMock.self)
  }
 }
}//public extension NMBaseSnippet...

@available(iOS 15.0, macOS 12.0, *)
 //THIS VARIANT IS USED FOR UNIT TESTING ONLY USING NW & GCS MOCKS!!!
 //USES FULLY ASYNC API FOR ALL SUBCLASSES OF NMBASECONTENT.
public extension NMBaseContent {
 
 func updateGeoLocationsAfterFetch() { //print("\(#function)")
  locationsProvider = managedObjectContext?.locationsProvider
  let workingTask = updateGeoLocationsTask
  updateGeoLocationsTask = Task.detached(priority: .medium) {
   if let snippet = try? await workingTask?.value { return snippet }
   
   return try await self.withGeoLocations(with: NMLocationsGeocoderMock.self,
                                          using: NMNetworkWaiterMock.self)
  }
 }
}//public extension NMBaseSnippet...


//THIS IS FULLY FLEDGED VARIANT USING REAL NW WAIER & GEOCODER!!
//USES FULLY ASYNC API FOR ALL CONFORMERS OF THIS PROTOCOL.
@available(iOS 15.0, macOS 12.0, *)
public extension NMGeoLocationProvidable {
 
 func updateGeoLocationsAfterFetch() {
  locationsProvider = managedObjectContext?.locationsProvider
  let workingTask = updateGeoLocationsTask
  updateGeoLocationsTask = Task.detached(priority: .medium) {
   if let snippet = try? await workingTask?.value { return snippet }
   return try await self.withGeoLocations(with: CLGeocoder.self,
                                          using: NMNetworkWaiter.self)
  }
 }
 
}//public extension NMGeoLocationProvidable...






extension NMGeoLocationProvidable {
 
 public var dergreesLatitude: CLLocationDegrees? {
  
  get { latitude?.doubleValue }
  
  set {
   guard let newLatitude = newValue else { return }
   latitude = NSNumber(value: newLatitude)
  }
  
 }
 
 public var dergreesLongitude: CLLocationDegrees? {
  
  get { longitude?.doubleValue }
  
  set {
   guard let newLongitude = newValue else { return }
   longitude = NSNumber(value: newLongitude)
  }
 }
 
 

 public var geoLocation: NMLocation? {
  
  get {
   guard let longitude = dergreesLongitude, let latitude = dergreesLatitude else { return nil }
   let location2D = CLLocation(latitude: latitude, longitude: longitude)
   return NMLocation(location: location2D)
  }
  
  set {
   dergreesLatitude  = newValue?.location.coordinate.latitude
   dergreesLongitude = newValue?.location.coordinate.longitude
   
  }
 }
 
}// ext....

//@available(iOS 14.0, *)
@available(iOS 15.0, macOS 12.0, *)
extension NMGeoLocationProvidable {
 

 public var geoLocationAsync: NMLocation? {
  get async throws {
   guard let context = managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .object, operation: .updateObject)
   }
   
   return await context.perform{ [unowned self] in self.geoLocation }
  }
 }
 

 public var addressAsync: String? {
  get async throws {
   guard let context = managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .object, operation: .updateObject)
   }
   return await context.perform { [unowned self] in location }
  }
 }
 
}



@available(iOS 14.0, macOS 12.0, *)
extension NMGeoLocationProvidable {
 
 
 //MARK: COMBINE BASED METHOD TO UPDATE GPS COORDINATES OF CONFORMED OBJECT AND THEN GEOCODE THEM INTO STRING ADDRESS.
 
 @available(iOS 14.0, *)
 public func updateGeoLocations<G, N> (with geocoderType: G.Type = CLGeocoder.self as! G.Type,
                                       using networkWaiterType: N.Type = NMNetworkWaiter.self as! N.Type)
                                       where G: NMGeocoderProtocol,
                                             N: NMNetworkMonitorProtocol  {
  
  guard let MOC = managedObjectContext else { return }
                                              
  MOC.perform { [ unowned self ] in
   if geoLocation != nil { return }
   
   geoLocationSubscription = locationsProvider?
    .locationFixPublisher
    .handleEvents(receiveOutput: { [ unowned self ] location in
      managedObjectContext?.perform { [ unowned self ] in
       geoLocation = location
       print ("UPDATE LOCATION FOR \(String(describing: Swift.type(of: self)))")
      }
    })
    .flatMap { $0.getPlacemarkPublisher(geocoderType.self, networkWaiterType.self) }
    .replaceError(with: nil)
    .compactMap { $0?.addressString }
    .sink { [ unowned self, unowned MOC ] address in
      MOC.perform { [ unowned self ] in location = address }
    }
  }
 }
 
}



