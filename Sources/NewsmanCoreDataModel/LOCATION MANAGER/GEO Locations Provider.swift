
import CoreLocation
import Foundation
import Combine
import RxSwift

public protocol NMLocationProvider
{
 static func locationServicesEnabled() -> Bool
 
 var delegate: CLLocationManagerDelegate? { get set }
 
 func requestWhenInUseAuthorization()
  // Requests the user’s permission to use location services while the app is in use.
 
 func requestAlwaysAuthorization()
  //Requests the user’s permission to use location services regardless of whether the app is in use.
 
 func startUpdatingLocation()
  // Starts the generation of updates that report the user’s current location.
 
 func stopUpdatingLocation()
  // Stops the generation of location updates.
 
 func requestLocation()
  // Requests the one-time delivery of the user’s current location.
 
 
}

extension CLLocationManager: NMLocationProvider {}

@available(iOS 13.0, *)
public final class NMGeoLocationsProvider: NSObject, CLLocationManagerDelegate
{
 
 public var locationProvider: NMLocationProvider
 public static var maxRetries = 5
 public static var locationStalenessInterval:  TimeInterval = 1.0
 
 fileprivate typealias NMLocationFixHandler = (Result<CLLocation?, Error>) -> ()
 fileprivate var handler: NMLocationFixHandler?
 
 fileprivate typealias FixContinuation = CheckedContinuation<CLLocation?, Error>
 
 fileprivate var locationFixContinuation: FixContinuation?
 
 fileprivate let delegateResultMutex = DispatchSemaphore(value: 1)
 
 private let fixPublisherQueue = DispatchQueue.main
 private let subsQueue = DispatchQueue.global()
 
 public enum Failures: Error {
  case maxRetryCountExceeded
  case unknownFailure (with: Error)
 }
 
 
 
 public init(provider: NMLocationProvider = CLLocationManager())
 {
  self.locationProvider = provider
  super.init()
  locationProvider.delegate = self
 }
 
 @Published fileprivate var status: CLAuthorizationStatus?
 
 private var cachedLocation: CLLocation?
 
 private var isCachedLocationStale: Bool {
  guard let location = cachedLocation else { return true }
  return abs(location.timestamp.timeIntervalSinceNow) > Self.locationStalenessInterval
 }
 
 var locationFixFuture: Future <CLLocation?, Error> {
  Future<CLLocation?, Error>{ [ unowned self ] promise in
   
   print("WAITING FOR CLD MUTEX... in {\(#function)} Thread [\(Thread.current)]")
   
   delegateResultMutex.wait()
   guard isCachedLocationStale else {
    promise(.success(cachedLocation))
    delegateResultMutex.signal()
    return
   }
   print("UPDATE FUTURE HANDLER TO FETCH LOCATION {\(#function)} Thread [\(Thread.current)]")
   
   handler = promise
   locationProvider.requestLocation()
  }
 }
 

 
 public typealias TimeOut = DispatchQueue.SchedulerTimeType.Stride
 
 @available(iOS 14.0, *)
 private func locationUnknownPublisher(_ timeOut: TimeOut,
                                       _ incTimeOut: TimeOut,
                                       _ maxTimeOut: TimeOut) -> AnyPublisher<CLLocation?, Error>
 {
  //print("#function \(timeOut)")"
  guard timeOut <= maxTimeOut else {
   return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
  }
  
  return Just(locationFixFuture)
   .delay(for: timeOut, scheduler: fixPublisherQueue)
   .flatMap{ $0 }
   .tryCatch { [ unowned self ] (error: Error) -> AnyPublisher<CLLocation?, Error> in
     switch error {
      case let error as CLError:
       switch error.code {
        case .locationUnknown:
         return locationUnknownPublisher(timeOut + incTimeOut, incTimeOut, maxTimeOut)
        default: throw error
       }
      default: throw Failures.unknownFailure(with: error)
       
    }
   
   }.eraseToAnyPublisher()
 }

 private var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
  $status.print()
   .compactMap{ $0 }
   .handleEvents(receiveOutput: { [ unowned self ] status in
    switch status {
     case .notDetermined: locationProvider.requestWhenInUseAuthorization()
     case .restricted: fallthrough
     case .denied: break
     default: break
    }
   })
  #if !os(macOS)
   .filter{ $0 == .authorizedAlways || $0 == .authorizedWhenInUse}
  #else
   .filter{ $0 == .authorized }
  #endif
   .eraseToAnyPublisher()
 }
 
 
 @available(iOS 14.0, *)
 public var locationFixPublisher: AnyPublisher<NMLocation, Error> {
  authorizationStatusPublisher
  .flatMap { [ unowned self ] _ in locationFixFuture }
  .tryCatch{ [ unowned self ] (error: Error) -> AnyPublisher<CLLocation?, Error> in
   switch error {
    case let error as CLError:
     switch error.code {
      case .locationUnknown:
       return locationUnknownPublisher(.milliseconds(10),  .milliseconds(10), .milliseconds(100))
      default: throw error
     }
    default: throw Failures.unknownFailure(with: error)
     
   }
  }
  .compactMap{ $0 }
  .map{ NMLocation(location: $0) }
  .tryCatch{ [ unowned self ] (error: Error) -> AnyPublisher<NMLocation, Error> in
    switch error {
     case let error as CLError:
      switch error.code {
       case .network: fallthrough
       case .denied: return locationFixPublisher
       default: throw error
      }
     default: throw Failures.unknownFailure(with: error)
      
    }
  }
  .first{ $0.isValid }
  .subscribe(on: subsQueue)
  .receive(on: fixPublisherQueue)
  .print()
  .eraseToAnyPublisher()
 }
 
 @available(iOS 14.0, *)
 public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

  let status = manager.authorizationStatus
  print (#function, status)
  self.status = status  //manager.authorizationStatus
 }
 
 
 private func callHandlerWithMutex(_ result: Result<CLLocation?, Error>)
 {
  defer {
   delegateResultMutex.signal()
   print("UNBLOCK RESULT MUTEX WITH \(result) IN {\(#function)} IN Thread [\(Thread.current)]")
  }
  
  switch (handler, locationFixContinuation){
   case let (h?, nil):
    h(result)
    cachedLocation = try? result.get()
    handler = nil
   
   case let (nil, c?):
    c.resume(with: result)
    locationFixContinuation = nil
 
   default: break
  }
 }

 public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  callHandlerWithMutex(.success(locations.last))
  //resumeContinuationWithMutex(.success(locations.last))
 }
 
 public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
  callHandlerWithMutex(.failure(error))
  //resumeContinuationWithMutex(.failure(error))
 }
 
}

@available(iOS 15.0, *)
@available(macOS 12.0.0, *)
public extension NMGeoLocationsProvider
{
 private func getLocationFix(retryCount: Int, maxRetries: Int) async throws -> NMLocation
 {
  guard retryCount < maxRetries else { throw Failures.maxRetryCountExceeded }
  
  locationProvider.requestWhenInUseAuthorization()
  
 #if !os(macOS)
  _ = await $status.values.first{ $0 == .authorizedAlways || $0 == .authorizedWhenInUse }
 #else
  _ = await $status.values.first{ $0 == .authorized }
 #endif
  
  do {
   let location = try await withCheckedThrowingContinuation{ (c: FixContinuation) -> () in
    
    delegateResultMutex.wait()
    locationFixContinuation = c
    print ("NEW CONTINUATION IS SET [\(c)]!")
    locationProvider.requestLocation()
    
   }
   
   guard let location = location else {
    return try await getLocationFix(retryCount: retryCount + 1, maxRetries: maxRetries)
   }
   
   return NMLocation(location: location)
  }
  catch is CLError {
   return try await getLocationFix(retryCount: retryCount + 1, maxRetries: maxRetries)
  }
  
  catch {
   throw Failures.unknownFailure(with: error)
  }

 }
 
 var locationFix: NMLocation {
  get async throws {
   try await getLocationFix(retryCount: 0, maxRetries: Self.maxRetries)
 
  }

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
