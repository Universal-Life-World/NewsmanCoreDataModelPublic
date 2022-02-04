
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
 
 func reverseGeocodeLocation(_ location: CLLocation) async throws -> [NMPlacemark]
                     
 @available(iOS 15.0, *) @available(macOS 12.0.0, *)
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
 
 public static let invalid = NMLocation(location: CLLocation(coordinate: kCLLocationCoordinate2DInvalid,
                                                             altitude: 0,
                                                             horizontalAccuracy: 0,
                                                             verticalAccuracy: 0,
                                                             timestamp: Date()))
 
 public var isValid: Bool { CLLocationCoordinate2DIsValid(location.coordinate) }
 
 public init (location: CLLocation)
 {
  self.location = location
  super.init()
 }
 
 let location: CLLocation
 
 //private var detectedPlacemark: CLPlacemark?
 
 private var retryCount = 2
 public static var maxRetries = 5
 
// private var geocoder: Any?
// private var networkWaiter: Any?
 
 
 func getPlacemarkPublisher<G, N>( _ geocoderType: G.Type,
                                   _ networkWaiterType: N.Type) -> AnyPublisher<G.NMPlacemark?, Error>
  where G:NMGeocoderProtocol,
        N: NMNetworkMonitorProtocol
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
         .retry(Self.maxRetries)
         .eraseToAnyPublisher()
        
       default: throw error
      }
     default: throw error
    }
    
  }
  .eraseToAnyPublisher()
 }
 
 @available(iOS 15.0, *) @available(macOS 12.0.0, *)
 public func getPlacemark<G, N> (with GC: G.Type = CLGeocoder.self as! G.Type,
                                 using NW: N.Type = NMNetworkWaiter.self as! N.Type) async throws -> G.NMPlacemark
 where G: NMGeocoderProtocol,
       N: NMNetworkMonitorProtocol
 {
  guard retryCount < Self.maxRetries else { throw NMGeoLocationsProvider.Failures.maxRetryCountExceeded }
  
  retryCount += 1
  
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


 
 
}





