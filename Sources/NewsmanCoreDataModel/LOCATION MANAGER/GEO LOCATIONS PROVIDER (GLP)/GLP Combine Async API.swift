
import CoreLocation
import class Combine.Future
import struct Combine.AnyPublisher
import struct Combine.Just
import struct Combine.Empty
import class Dispatch.DispatchQueue

@available(iOS 13.0, *)
public extension NMGeoLocationsProvider {
 var locationFixFuture: Future <CLLocation?, Error> {
  Future<CLLocation?, Error>{ [ unowned self ] promise in
   
   dispatchPrecondition(condition: .onQueue(fixPublisherQueue))
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
 
 typealias TimeOut = DispatchQueue.SchedulerTimeType.Stride
 
 @available(iOS 14.0, *)
 private func locationUnknownPublisher(_ timeOut: TimeOut,
                                       _ incTimeOut: TimeOut,
                                       _ maxTimeOut: TimeOut) -> AnyPublisher<CLLocation?, Error>
 {
   //print("#function \(timeOut)")"
  dispatchPrecondition(condition: .onQueue(fixPublisherQueue))
  guard timeOut <= maxTimeOut else {
   return Just(cachedLocation).setFailureType(to: Error.self).eraseToAnyPublisher()
  }
  
  return Just(locationFixFuture)
   .delay(for: timeOut, scheduler: fixPublisherQueue)
   .flatMap{ $0 }
   .tryCatch { [ weak self ] (error: Error) -> AnyPublisher<CLLocation?, Error> in
     guard let self = self else { return Empty().eraseToAnyPublisher() }
     switch error {
      case let error as CLError:
       switch error.code {
        case .locationUnknown: return self.locationUnknownPublisher(timeOut + incTimeOut, incTimeOut, maxTimeOut)
        default: throw error
       }
      default: throw Failures.unknownFailure(with: error)
     }
   }.eraseToAnyPublisher()
 }
 
 var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
  statusSubject
   .handleEvents(receiveOutput: { [ unowned self ] status in
    guard let status = status else {
     locationProvider.requestWhenInUseAuthorization()
     return 
    }
    switch status {
     case .notDetermined: locationProvider.requestWhenInUseAuthorization()
     case .restricted: fallthrough
     case .denied: break
     default: break
    }
   })
   .compactMap{ $0 }
   #if !os(macOS)
   .filter{ $0 == .authorizedAlways || $0 == .authorizedWhenInUse}
   #else
   .filter{ $0 == .authorized }
   #endif
   .subscribe(on: fixPublisherQueue)
   .receive(on: fixPublisherQueue)
   .eraseToAnyPublisher()
  
 }
 
 
 @available(iOS 14.0, *)
 var locationFixPublisher: AnyPublisher<NMLocation, Error> {
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
   //.first{ $0.isValid }
   .subscribe(on: fixPublisherQueue)
   .receive(on: fixPublisherQueue)//.print()
   .eraseToAnyPublisher()
 }
}
