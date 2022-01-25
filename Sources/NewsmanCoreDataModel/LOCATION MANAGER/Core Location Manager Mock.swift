
import CoreLocation
import Foundation

public class NMLocationManagerMock: CLLocationManager
{
 private static var isLocationServicesEnabled = true
 
 private let isolationQueue = DispatchQueue(label: "NMLocationManagerMock.isolation", attributes: [.concurrent])
 
 public func disableLocationServices()
 {
  isolationQueue.sync {
   guard Self.isLocationServicesEnabled else { return }
   Self.isLocationServicesEnabled = false
   status = .denied
  }
 }
 
 public func enableLocationServicesWhenInUse()
 {
  isolationQueue.sync {
   if Self.isLocationServicesEnabled { return }
   Self.isLocationServicesEnabled = true
   
   #if !os(macOS)
   status = .authorizedWhenInUse
   #else
   status = .authorized
   #endif
  }
 }
 
 public func enableLocationServicesAlways()
 {
  isolationQueue.sync {
   if Self.isLocationServicesEnabled { return }
   Self.isLocationServicesEnabled = true
   status = .authorizedAlways
  }
 }
 
 private static var isNetworkAvailable = true
 
 public func makeNetworkAvailable()
 {
  isolationQueue.sync {
   if Self.isNetworkAvailable { return }
   Self.isNetworkAvailable = true
   status = .notDetermined
  }
 }
 
 public func makeNetworkUnavailable()
 {
  isolationQueue.sync {
   guard Self.isNetworkAvailable else { return }
   Self.isNetworkAvailable = false
   status = .denied
  }
 }
 
 
 public override init() {}
 
 private var status: CLAuthorizationStatus = .notDetermined
 {
  didSet {
   //print (#function, oldValue.rawValue, status.rawValue)
   if status != oldValue {
    delegate?.locationManagerDidChangeAuthorization?(self)
   }
  }
 }
 
 public override var authorizationStatus: CLAuthorizationStatus {
  //print (#function, status.rawValue)
  isolationQueue.sync {  status }
  
 }
 
 public override static func locationServicesEnabled() -> Bool { isLocationServicesEnabled }
 
 private weak var _delegate: CLLocationManagerDelegate?
 
 public override var delegate: CLLocationManagerDelegate?
 {
  get { isolationQueue.sync {_delegate } }
  set {
   isolationQueue.sync {
    _delegate = newValue
    newValue?.locationManagerDidChangeAuthorization?(self)
   }
  }
 }
 
 public override func requestWhenInUseAuthorization(){
  isolationQueue.sync {
   guard authorizationStatus == .notDetermined else { return }
   guard Self.isLocationServicesEnabled && Self.isNetworkAvailable else {
    status = .denied
    return
   }
   
   #if !os(macOS)
   status = .authorizedWhenInUse
   #else
   status = .authorized
   #endif
  }
 }
 private var detectedLocations: [CLLocation]
 {
  [CLLocation(latitude: .random(in: -90...90), longitude: .random(in: -180...180))]
 }
 
 public override func requestAlwaysAuthorization() {
  isolationQueue.sync {
   guard authorizationStatus == .notDetermined else { return }
   guard Self.isLocationServicesEnabled && Self.isNetworkAvailable else {
    status = .denied
    return
   }
   
   status = .authorizedAlways
  }
  
 }
 
 private var isUpdatingLocation = false
 
 public override func startUpdatingLocation() {
  //print(#function)
  isolationQueue.sync {
   if isUpdatingLocation { return }
   
   guard Self.isLocationServicesEnabled && Self.isNetworkAvailable else {
    delegate?.locationManager?(self, didFailWithError: CLError(.denied))
    return
   }
   
   switch authorizationStatus {
    case .notDetermined: fallthrough
    case .restricted: fallthrough
    case .denied: delegate?.locationManager?(self, didFailWithError: CLError(.denied))
    case .authorizedAlways: fallthrough
    case .authorizedWhenInUse: fallthrough
    case .authorized:
     isUpdatingLocation = true
     delegate?.locationManager?(self, didUpdateLocations: detectedLocations)
     
    @unknown default: break
   }
  }
 }
 
 public override func stopUpdatingLocation() {
  isolationQueue.sync {
   guard isUpdatingLocation else { return }
   isUpdatingLocation = false
  }
 }
 
 public override func requestLocation() {
  startUpdatingLocation()
  stopUpdatingLocation()
 }
 
 
}
