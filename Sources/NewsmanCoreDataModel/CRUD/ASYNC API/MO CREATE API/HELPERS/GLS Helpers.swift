import CoreData

@available(iOS 15.0, macOS 12.0, *)
public extension NSManagedObject {
 
 //MARK: ASYNC METHOD TO UPDATE GPS COORDINATES OF CONFORMED OBJECT AND THEN GEOCODE THEM INTO STRING ADDRESS.
 func withGeoLocations<G, N>(with geocoderType: G.Type,
                             using networkMonitorType: N.Type) async throws -> NSManagedObject
 where G: NMGeocoderProtocol, N: NMNetworkMonitorProtocol {
        
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
