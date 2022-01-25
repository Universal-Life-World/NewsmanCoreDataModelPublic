
import CoreLocation
import Foundation
import Combine
import RxSwift
import Network


public protocol NMPlacemarkAddressRepresentable
{
 init()
 var addressString: String { get }
}

extension CLPlacemark: NMPlacemarkAddressRepresentable
{
 
 @objc public var addressString: String
 {
  var location = ""
  if let country    = self.country                 {location += country          }
  if let region     = self.administrativeArea      {location += ", " + region    }
  if let district   = self.subAdministrativeArea   {location += ", " + district  }
  if let city       = self.locality                {location += ", " + city      }
  if let subcity    = self.subLocality             {location += ", " + subcity   }
  if let street     = self.thoroughfare            {location += ", " + street    }
  if let substreet  = self.subThoroughfare         {location += ", " + substreet }
  return location
 }
}

public protocol NMGeocoderProtocol
{
 associatedtype NMPlacemark: NMPlacemarkAddressRepresentable
 
 typealias NMGeocodeCompletionHandler = ([NMPlacemark]?, Error?) -> ()
 
 init()
 func reverseGeocodeLocation(_ location: CLLocation,
                               completionHandler: @escaping NMGeocodeCompletionHandler)
                     
 
 func placemarkPublisher(for location: CLLocation) -> AnyPublisher<NMPlacemark?, Error>
}

extension NMGeocoderProtocol
{
 public func placemarkPublisher(for location: CLLocation) -> AnyPublisher<NMPlacemark?, Error>
 {
  Deferred {
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
   }
  }.eraseToAnyPublisher()
 }
}

extension CLGeocoder: NMGeocoderProtocol
{
 public typealias NMPlacemark = CLPlacemark
 
}


 public final class NMLocation: NSObject
{
 //public static var geocoderType: Geocoder.Type = CLGeocoder.self
// public static var networkMonitorType: NMNetworkMonitorProtocol.Type = NMNetworkWaiter.self
 
 public init (location: CLLocation)
 {
  self.location = location
  super.init()
 }
 
 let location: CLLocation
 
 //private var detectedPlacemark: CLPlacemark?
 
 private var retryCount = 2
 
// private var geocoder: Any?
// private var networkWaiter: Any?
 
 
 func getPlacemarkPublisher<G, N>( _ geocoderType: G.Type, _ networkWaiterType: N.Type) -> AnyPublisher<G.NMPlacemark?, Error> where G:NMGeocoderProtocol, N: NMNetworkMonitorProtocol
 {
//  let geocoder = geocoderType.init()
  let networkWaiter = networkWaiterType.init()
  
  return geocoderType.init().placemarkPublisher(for: location)
   .tryCatch { [unowned self] (error: Error) -> AnyPublisher<G.NMPlacemark?, Error> in
    switch error {
     case let error as CLError:
      switch error.code {
       case .network:
        return networkWaiter.monitorPublisher
         .flatMap{[ self ] _ in geocoderType.init().placemarkPublisher(for: location) }
         .eraseToAnyPublisher()
        
       case .geocodeFoundPartialResult: fallthrough
       case .geocodeFoundNoResult:
        return geocoderType.init().placemarkPublisher(for: location)
         .retry(retryCount)
         .eraseToAnyPublisher()
        
       default: throw error
      }
     default: throw error
    }
    
  }
  .eraseToAnyPublisher()
 }
 
// @available(iOS 15.0, *) @available(macOS 12.0.0, *)
// var placemark: CLPlacemark? {
//  get async throws {
//   try await placemarkPublisher.values.compactMap{$0}.first(where: {_ in true})
//    //   if let placemark = detectedPlacemark { return placemark }
////   detectedPlacemark = try await CLGeocoder().reverseGeocodeLocation(location).first
////   return detectedPlacemark
//  }
// }
//
// @available(iOS 15.0, *) @available(macOS 12.0.0, *)
// var addressString: String? {
//  get async throws { try await placemark?.addressString }
// }
 
 
}





