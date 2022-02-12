
import class Foundation.NSValue
import CoreLocation




@available(iOS 15.0, *)
@available(macOS 12.0.0, *)
public extension NMLocation {
 
 func getPlacemark<G, N> (with GC: G.Type, using NW: N.Type) async throws -> G.NMPlacemark
                where G: NMGeocoderProtocol,
                      N: NMNetworkMonitorProtocol
 {
  
//  defer { Self.locationCacheMutex.signal() }
//  Self.locationCacheMutex.wait()
  
  if let cachedPlacemark = try await Self.locationsCacheActor.placemark(for: self) as? G.NMPlacemark {
//   print ("USING CACHED PLACEMARK \(cachedPlacemark.addressString)")
   return cachedPlacemark
  }
  
  let geocodingTask = Task.detached(priority: .medium) { [self] () -> NMPlacemarkAddressRepresentable in
//   print ("GEOCODER TASK START...")
   guard retryCount <= Self.maxRetries else {
    throw NMGeoLocationsProvider.Failures.maxRetryCountExceeded(count: retryCount)
 
   }
   
   retryCount += 1
   
   let geocoder = GC.init()
   
   do {
    try Task.checkCancellation()
    guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {
     return try await getPlacemark(with: GC.self, using: NW.self)
    }
    
    //Self.locationsCache[self] = placemark
    
    return placemark
   }
   catch is CancellationError {
//    print ("GEOCODING TASK IS CANCELLED!")
    guard let cachedPlacemark = try await Self.locationsCacheActor.placemark(for: self) as? G.NMPlacemark else {
     return try await getPlacemark(with: GC.self, using: NW.self)
    }
    return cachedPlacemark
   }
   catch CLError.geocodeFoundPartialResult, CLError.geocodeFoundNoResult {
    return try await getPlacemark(with: GC.self, using: NW.self)
   }
   catch CLError.network {
    let networkWaiter = NW.init()
    await networkWaiter.waitForNetwork()
    return try await getPlacemark(with: GC.self, using: NW.self)
   }
   catch {
    throw NMGeoLocationsProvider.Failures.unknownFailure(with: error)
   }
   
  }
  
  await Self.locationsCacheActor.setPlacemarkTask(for: self, task: geocodingTask)
  
  return try await geocodingTask.value as! G.NMPlacemark
  
 }

}//public extension NMLocation...
