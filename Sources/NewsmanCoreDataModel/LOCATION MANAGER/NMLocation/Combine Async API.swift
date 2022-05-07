
import CoreLocation
import struct Combine.AnyPublisher
import struct Combine.Just
import class Foundation.NSValue

@available(iOS 14.0, *)
public extension NMLocation{
 
 

 func getPlacemarkPublisher<G, N>( _ geocoderType: G.Type,
                                   _ networkWaiterType: N.Type) -> AnyPublisher<G.NMPlacemark?, Error>
                         where G: NMGeocoderProtocol,
                               N: NMNetworkMonitorProtocol {
                                
  var placemarkPublisher: AnyPublisher<G.NMPlacemark?, Error>{
   guard let cachedPP = Self.locationsCache[self]  else {
    let newPP = geocoderType.init().placemarkPublisher(for: self.location)
    Self.locationsCache[self] = newPP.compactMap{ $0 as NMPlacemarkAddressRepresentable? }.eraseToAnyPublisher()
    return newPP
   }
   return cachedPP.compactMap{ $0 as? G.NMPlacemark? }.eraseToAnyPublisher()
  }
  
  let networkWaiter = networkWaiterType.init()
  let location = self.location
  
  return placemarkPublisher
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
         .deferred
         .retry(Self.maxRetries)
         .eraseToAnyPublisher()
        
       default: throw error
      }
     default: throw error
    }
    
   }.eraseToAnyPublisher()
 }
 

}//public extension NMLocation {...}
