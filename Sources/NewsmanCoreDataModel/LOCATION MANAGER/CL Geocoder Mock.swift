

import CoreLocation
import Foundation
import Combine
import RxSwift

public final class NMPlacemarkDummy: NMPlacemarkAddressRepresentable
{
 public init(){}
 public var addressString: String { "Test Address" }
}

extension Notification.Name
{
 static let networkDidBecomeAvailableMock = Notification.Name(rawValue: "networkAvailableMock")
 static let networkDidBecomeUnavailableMock = Notification.Name(rawValue: "networkUNAvailableMock")
}


public final class NMLocationsGeocoderMock: NMGeocoderProtocol
{
 
 public func reverseGeocodeLocation(_ location: CLLocation) async throws -> [NMPlacemarkDummy] {
  try await withCheckedThrowingContinuation { cont in
   reverseGeocodeLocation(location) { placemarks, error in
    switch (placemarks, error) {
     case (nil, let error?): cont.resume(throwing: error)
     case (let placemarks?, nil): cont.resume(returning: placemarks)
     default: fatalError()
      
    }
   }
  }
 }
 
 public typealias NMPlacemark = NMPlacemarkDummy
 
 private static let isolationQueue = DispatchQueue(label: "NMLocationsGeocoderMock.isolation",
                                            attributes: [.concurrent])

 public init() {}
 
 private static var isNetworkAvailable = true
 
 public static func enableNetwork()
 {
  isolationQueue.sync {
   if isNetworkAvailable { return }
   isNetworkAvailable = true
   NotificationCenter.default.post(name: .networkDidBecomeAvailableMock, object: nil, userInfo: nil)
  }
 }
 
 public static func disableNetwork()
 {
  isolationQueue.sync {
   guard isNetworkAvailable else { return }
   isNetworkAvailable = false
   NotificationCenter.default.post(name: .networkDidBecomeUnavailableMock, object: nil, userInfo: nil)
  }
 }
 
 public func reverseGeocodeLocation(_ location: CLLocation,
                                    completionHandler: @escaping NMGeocodeCompletionHandler) {
  Self.isolationQueue.sync {
   if Self.isNetworkAvailable {
    completionHandler([ NMPlacemarkDummy()], nil )
   } else {
    completionHandler(nil, CLError(.network) )
   }
  }
 }
}

@available(iOS 15.0, *) @available(macOS 12.0.0, *)
public actor NMLocationsGeocoderMockActor: NMGeocoderProtocol
{
 public func reverseGeocodeLocation(_ location: CLLocation) async throws -> [NMPlacemarkDummy] {
  if isNetworkAvailable { return [ NMPlacemarkDummy()] } else { throw CLError(.network) }
  
 }
 
 public typealias NMPlacemark = NMPlacemarkDummy
 
 public init() {}
 
 private var isNetworkAvailable = true
 
 public func enableNetwork()
 {
  if isNetworkAvailable { return }
  isNetworkAvailable = true

 }
 
 public func disableNetwork()
 {
  guard isNetworkAvailable else { return }
  isNetworkAvailable = false
 }
 
 nonisolated public func reverseGeocodeLocation(_ location: CLLocation,
  completionHandler:  @escaping NMGeocodeCompletionHandler) {
  
  Task {
   if await isNetworkAvailable {
    completionHandler([ NMPlacemarkDummy()], nil )
   } else {
    completionHandler(nil, CLError(.network) )
   }
  }
 }
 
}
