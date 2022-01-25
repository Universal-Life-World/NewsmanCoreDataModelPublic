
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

public final class NMGeoLocationsProvider: NSObject, CLLocationManagerDelegate
{
 typealias NMLocationFixHandler = (Result<CLLocation?, Error>) -> ()
 public var locationProvider: NMLocationProvider
 private var handler: NMLocationFixHandler?
 
 public init(provider: NMLocationProvider = CLLocationManager())
 {
  self.locationProvider = provider
  super.init()
  locationProvider.delegate = self
 }
 
 @Published private var status: CLAuthorizationStatus?
 
 var locationFixFuture: Future <CLLocation?, Error> {
  Future<CLLocation?, Error>{ [ unowned self ] promise in
   handler = promise
   locationProvider.requestLocation()
  }
 }
 
 public var locationFixPublisher: AnyPublisher<NMLocation, Error> {
  $status//.print()
  .compactMap{ $0 }
  .handleEvents(receiveOutput: {[ unowned self ] status in
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
  .flatMap {[ unowned self ] _ in locationFixFuture }
  .tryCatch{ [ unowned self ] (error: Error) -> AnyPublisher<CLLocation?, Error> in
   switch error {
    case let error as CLError:
     switch error.code {
      case .locationUnknown:
       return Deferred { [unowned self] in locationFixFuture }
       .retry(5)
       .eraseToAnyPublisher()
      default: throw error
     }
    default: throw error
     
   }
  }
  .compactMap{$0}
  .map{ NMLocation(location: $0) }
  .tryCatch{ [ unowned self ] (error: Error) -> AnyPublisher<NMLocation, Error> in
   switch error {
    case let error as CLError:
     switch error.code {
      case .network: fallthrough
      case .denied: return locationFixPublisher
      default: throw error
     }
    default: throw error
     
   }
  }
  .first()
  .eraseToAnyPublisher()
 }
 
 public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

  let status = manager.authorizationStatus
  print (#function, status)
  self.status = status  //manager.authorizationStatus
 }
 
 public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  handler?(.success(locations.last))
 }
 
 public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
  handler?(.failure(error))
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
