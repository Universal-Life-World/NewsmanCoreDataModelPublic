
import CoreLocation
import Dispatch
import Combine


@available(iOS 13.0, *)
public final class NMGeoLocationsProvider: NSObject, CLLocationManagerDelegate {
 
 deinit{
  print ("NMGeoLocationsProvider is DESTROYED!")
 }
 
 public var locationProvider: NMLocationProvider
 public static var maxRetries = 5
 public static var maxTimeOut: DispatchTimeInterval = .milliseconds(100)
 public static var timeOutIncrement: DispatchTimeInterval = .milliseconds(10)
 public static var locationStalenessInterval: TimeInterval = .infinity
 
 
 typealias NMLocationFixHandler = (Result<CLLocation?, Error>) -> ()
 var handler: NMLocationFixHandler?
 
 typealias FixContinuation = CheckedContinuation<CLLocation?, Error>
 
 var locationFixContinuation: FixContinuation?
 
 let delegateResultMutex = DispatchSemaphore(value: 1)
 
 let fixPublisherQueue = DispatchQueue(label: "Location Fix Publishing Queue")
 
 public enum Failures: Error {
  case maxRetryCountExceeded(count: Int)
  case maxTimeOutExceeded(timeOut: DispatchTimeInterval)
  case unknownFailure (with: Error)
  case unknownStatus(status: CLAuthorizationStatus)

 }
 
 
 public init(provider: NMLocationProvider = CLLocationManager()) {
  self.locationProvider = provider
  super.init()
  locationProvider.delegate = self
 }
 
 
 let statusSubject = CurrentValueSubject<CLAuthorizationStatus?, Never>(nil)
 
 var cachedLocation: CLLocation?
 
 var isCachedLocationStale: Bool {
  guard let location = cachedLocation else { return true }
  return abs(location.timestamp.timeIntervalSinceNow) > Self.locationStalenessInterval
 }
 
 
 @available(iOS 14.0, *)
 public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
  let status = manager.authorizationStatus //print(#function, status)
  statusSubject.send(status)
 }
 
 private func callHandlerWithMutex(_ result: Result<CLLocation?, Error>) {
   defer {
    cachedLocation = try? result.get() 
    delegateResultMutex.signal()
    //print("UNBLOCK RESULT MUTEX WITH \(result) IN {\(#function)} IN Thread [\(Thread.current)]")
   }
   
   switch (handler, locationFixContinuation) {
    case let (h?, nil):
     h(result)
     handler = nil
    case let (nil, c?):
     c.resume(with: result) //print ("RESUMED [\(c)] with RESULT - \(result)")
     locationFixContinuation = nil
    default: break
   }
  
 }
 public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  callHandlerWithMutex(.success(locations.last))
 }
 
 public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
  callHandlerWithMutex(.failure(error))
 }
 
}




//public protocol NMLocationsManageable
//{
// var locationProvider: NMLocationProvider { get }
// 
// var locationFix: NMLocation { get async throws }
// var locationMonitor: AsyncThrowingStream<NMLocation, Error> { get }
// 
// var locationFixPublisher: AnyPublisher<NMLocation, Error> { get }
// var locationMonitorPublisher: AnyPublisher<NMLocation, Error> { get }
// 
// var locationFixSingle: Single<NMLocation> { get }
// var locationObservable: PublishSubject<NMLocation> { get }
//}
