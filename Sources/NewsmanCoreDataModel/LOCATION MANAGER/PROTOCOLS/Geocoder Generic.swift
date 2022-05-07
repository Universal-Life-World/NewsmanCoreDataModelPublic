
import class CoreLocation.CLLocation
import class CoreLocation.CLGeocoder
import class CoreLocation.CLPlacemark

import struct Combine.AnyPublisher
import class  Combine.Future
import struct Combine.Deferred
import Combine

extension CLGeocoder: NMGeocoderProtocol {
 public typealias NMPlacemark = CLPlacemark
}

@available(iOS 13.0, *)
public protocol NMGeocoderProtocol {
 associatedtype NMPlacemark: NMPlacemarkAddressRepresentable
 
 typealias NMGeocodeCompletionHandler = ([NMPlacemark]?, Error?) -> ()
 
 init()
 func reverseGeocodeLocation(_ location: CLLocation,
                             completionHandler: @escaping NMGeocodeCompletionHandler)
 
 func reverseGeocodeLocation(_ location: CLLocation) async throws -> [NMPlacemark]
 
 func placemarkPublisher(for location: CLLocation) -> AnyPublisher<NMPlacemark?, Error>
 
}//public protocol NMGeocoderProtocol ...


@available(iOS 13.0, *)
public protocol NMGeocoderTypeProtocol: NMGeocoderProtocol {
}

@available(iOS 13.0, *)
extension NMGeocoderProtocol {
 public func placemarkPublisher(for location: CLLocation) -> AnyPublisher<NMPlacemark?, Error> {
  Future { [ self ] promise in
   reverseGeocodeLocation(location){ placemarks, error in
    switch (placemarks, error) {
     case (nil, let error?):
      promise(.failure(error))
     case (let placemarks?, nil):
      promise (.success(placemarks.first))
     default:
      promise(.success(nil))
      
    }
   }
  }.eraseToAnyPublisher()
 }
}//extension NMGeocoderProtocol { ... }

@available(iOS 13.0, *)
public extension AnyPublisher {
 var deferred: AnyPublisher<Output, Failure>{
  Deferred { self }.eraseToAnyPublisher()
  
 }
}


