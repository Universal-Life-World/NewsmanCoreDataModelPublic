
import CoreLocation

@available(iOS 15.0, *)
@available(macOS 12.0.0, *)
public extension NMGeoLocationsProvider {
 
 var locationFix: NMLocation {
  get async throws {
   try await getLocationFix(retryCount: 0,
                            maxRetries: Self.maxRetries,
                            timeOut: .zero,
                            timeOutInc: Self.timeOutIncrement,
                            maxTimeOut: Self.maxTimeOut)
  }
 }
 
 

 private final func requestAuthorization() async throws {
  
  try Task.checkCancellation()
  let authStatusSequence = statusSubject.values
  
  for await status in authStatusSequence {
   try Task.checkCancellation()
   guard let status = status else {
    locationProvider.requestWhenInUseAuthorization()
    continue
   }
   switch status {
    case .notDetermined: locationProvider.requestWhenInUseAuthorization()
    case .restricted: fallthrough
    case .denied: continue
   #if os(macOS)
    case .authorized: return
   #else
    case .authorizedWhenInUse: fallthrough
    case .authorizedAlways: return
   #endif
    
    @unknown default: throw Failures.unknownStatus(status: status)
   }
  }
 }
 
 
 
 
 private final func getLocationFix(retryCount: Int,
                                   maxRetries: Int,
                                   timeOut: DispatchTimeInterval = .never,
                                   timeOutInc: DispatchTimeInterval = .never,
                                   maxTimeOut: DispatchTimeInterval = .never) async throws -> NMLocation {
  
  try Task.checkCancellation()
  
  guard retryCount < maxRetries else { throw Failures.maxRetryCountExceeded(count: retryCount) }
  
  guard timeOut <= maxTimeOut else { throw Failures.maxTimeOutExceeded(timeOut: timeOut)}
  
  try await Task.sleep(timeInterval: timeOut)
  
   //print ("REQUEST AUTH STATUS...")
  locationProvider.requestWhenInUseAuthorization()
   //print ("AUTH STATUS DONE!")
  
   print ("AWAIT FOR AUTH STATUS...")
  
  
  try await requestAuthorization()
  
   print ("DONE!!! AWAIT FOR AUTH STATUS")
  
  do {
   let location = try await withCheckedThrowingContinuation{ (cont: FixContinuation) -> () in
    
    print ("WAITING FOR MUTEX...")
    delegateResultMutex.wait()
    print ("DONE!!! WAITING FOR MUTEX...")

    guard isCachedLocationStale else {
     cont.resume(returning: cachedLocation!)
     delegateResultMutex.signal()
     return
    }
    
    locationFixContinuation = cont
    print ("NEW CONTINUATION IS SET [\(cont)]!")
    locationProvider.requestLocation()
    
   }
   
   guard let location = location else {
    print ("LOCATION <<<NIL>>> --> RETRY : \(retryCount + 1)")
    return try await getLocationFix(retryCount: retryCount + 1, maxRetries: maxRetries)
   }
   
   return NMLocation(location: location)
  }
  catch CLError.locationUnknown {
   print ("LOCATION UNKNOWN --> RETRY : \(retryCount + 1). TIMEOUT: \(timeOut + timeOutInc)")
   return try await getLocationFix(retryCount: retryCount + 1,
                                   maxRetries: .max,
                                   timeOut:    timeOut + timeOutInc,
                                   timeOutInc: timeOutInc,
                                   maxTimeOut: maxTimeOut)
  }
  catch is CLError {
   return try await getLocationFix(retryCount: retryCount + 1, maxRetries: maxRetries)
  }
  
  catch {
   throw Failures.unknownFailure(with: error)
  }
  
 }
  
 
 
 
}
