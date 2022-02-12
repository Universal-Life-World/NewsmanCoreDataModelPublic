
import CoreLocation
import struct Combine.AnyPublisher
import struct Combine.Just
import class Foundation.NSValue

@available(iOS 14.0, *)
public extension NMLocation {

 func getPlacemarkPublisher<G, N>( _ geocoderType: G.Type,
                                   _ networkWaiterType: N.Type) -> AnyPublisher<G.NMPlacemark?, Error>
                         where G: NMGeocoderProtocol,
                               N: NMNetworkMonitorProtocol
 {
  Self.locationCacheMutex.wait()
  
  if let cachedPlacemark = Self.locationsCache[self] as? G.NMPlacemark{
   return Just(cachedPlacemark)
    .setFailureType(to: Error.self)
    .handleEvents( receiveCompletion: {_ in Self.locationCacheMutex.signal() },
                   receiveCancel:     {     Self.locationCacheMutex.signal() })
    .eraseToAnyPublisher()
  }
  
  let networkWaiter = networkWaiterType.init()
  let location = self.location
  
  return geocoderType.init().placemarkPublisher(for: location)
   .tryCatch { (error: Error) -> AnyPublisher<G.NMPlacemark?, Error> in
    switch error {
     case let error as CLError:
      switch error.code {
       case .network:
        return networkWaiter
         .monitorPublisher
         .flatMap{ _ in geocoderType.init().placemarkPublisher(for: location) }
         .eraseToAnyPublisher()
        
       case .geocodeFoundPartialResult: fallthrough
       case .geocodeFoundNoResult:
        return geocoderType.init()
         .placemarkPublisher(for: location)
         .retry(Self.maxRetries)
         .eraseToAnyPublisher()
        
       default: throw error
      }
     default: throw error
    }
    
   }.handleEvents(receiveOutput: {
      guard let placemark = $0 else { return }
      Self.locationsCache[self] = placemark
      Self.locationCacheMutex.signal()
   }, receiveCompletion: {_ in Self.locationCacheMutex.signal() },
      receiveCancel:     {     Self.locationCacheMutex.signal() })
 
   .eraseToAnyPublisher()
 }
 

}//public extension NMLocation {...}
