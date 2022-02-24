
import class Foundation.NSValue
import CoreLocation

@available(iOS 15.0, *)
@available(macOS 12.0.0, *)
public extension NMLocation {
 
 func getPlacemark<G, N> (with GC: G.Type, using NW: N.Type) async throws -> G.NMPlacemark
                where G: NMGeocoderProtocol,
                      N: NMNetworkMonitorProtocol
 {
  try Task.checkCancellation()
  
  if retryCount == 0 {
   let cachedPlacemark = await Self.locationsCacheActor.placemark(for: self)
                       
   if let cachedPlacemark = cachedPlacemark as? G.NMPlacemark {
    print ("USING CACHED PLACEMARK \(cachedPlacemark.addressString)")
    return cachedPlacemark
   }
  }
  
  let geocodingTask = Task.detached(priority: .medium) { [ self ] () -> NMPlacemarkAddressRepresentable in
   print ("GEOCODER TASK START...")
   try Task.checkCancellation()
   guard retryCount <= Self.maxRetries else {
    throw NMGeoLocationsProvider.Failures.maxRetryCountExceeded(count: retryCount)
 
   }
   
   retryCount += 1
   print ("GEOCODER TASK RETRY (\(retryCount))")
   
   let geocoder = GC.init()
   
   do {
    guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {
     return try await getPlacemark(with: GC.self, using: NW.self)
    }
    
    return placemark
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
