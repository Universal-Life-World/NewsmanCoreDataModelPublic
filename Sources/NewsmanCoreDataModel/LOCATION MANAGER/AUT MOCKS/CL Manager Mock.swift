
import CoreLocation
import Foundation

@available(iOS 14.0, *)
public class NMLocationManagerMock: CLLocationManager
{
 
 private let delegateQueue = DispatchQueue(label: "delegateQueue",
                                           qos: .userInitiated,
                                           attributes: [.concurrent])
 
 private let isLocationServicesEnabled_IQ = DispatchQueue(label: "isLocationServicesEnabled_IQ",
                                                                 attributes: [.concurrent])
 private var _isLocationServicesEnabled = true
 private var isLocationServicesEnabled: Bool
 {
  get { isLocationServicesEnabled_IQ.sync { _isLocationServicesEnabled } }
  set { isLocationServicesEnabled_IQ.async(flags: [.barrier]){ [ self ] in
   _isLocationServicesEnabled = newValue }
  }
 }
 
 private let isLocationUnknown_IQ = DispatchQueue(label: "isLocationUnknown_IQ",
                                                                 attributes: [.concurrent])
 private var _isLocationUnknown = false
 
 public var isLocationUnknown: Bool
 {
  get { isLocationUnknown_IQ.sync { _isLocationUnknown } }
  set { isLocationUnknown_IQ.sync{  _isLocationUnknown = newValue } }
 }
 
 
 private let status_IQ = DispatchQueue(label: "status_IQ", attributes: [.concurrent])
 private var _status: CLAuthorizationStatus = .notDetermined
 

 private var status: CLAuthorizationStatus
 {
  get { status_IQ.sync { _status } }
  set { status_IQ.async(flags: [.barrier]){ [ self ] in
   
    if _status != newValue {
     _status = newValue
     delegateQueue.async { [self] in
      delegate?.locationManagerDidChangeAuthorization?(self)
     }
    }
   }
   
  }
 }
 
 public func disableLocationServices()
 {
  guard isLocationServicesEnabled else { return }
  isLocationServicesEnabled = false
  status = .denied
 }
 
 public func enableLocationServicesWhenInUse()
 {
  if isLocationServicesEnabled { return }
  isLocationServicesEnabled = true
  
  #if !os(macOS)
  status = .authorizedWhenInUse
  #else
  status = .authorized
  #endif
  
 }
 
 public func enableLocationServicesAlways()
 {
  if isLocationServicesEnabled { return }
  isLocationServicesEnabled = true
  status = .authorizedAlways
 }
 
 private var _isNetworkAvailable = true
 private let isNetworkAvailable_IQ = DispatchQueue(label: "isNetworkAvailable_IQ", attributes: [.concurrent])
 
 private var isNetworkAvailable: Bool
 {
  get { isNetworkAvailable_IQ.sync { _isNetworkAvailable } }
  set { isNetworkAvailable_IQ.async(flags: [.barrier]){ [ self ] in _isNetworkAvailable = newValue } }
 }
 
 
 public func makeNetworkAvailable()
 {
  if isNetworkAvailable { return }
  isNetworkAvailable = true
  status = .notDetermined
 }
 
 public func makeNetworkUnavailable()
 {
 
  guard isNetworkAvailable else { return }
  isNetworkAvailable = false
  status = .denied
  
 }
 
 
 public override init() {}
 
 
 
 public override var authorizationStatus: CLAuthorizationStatus {
  //print (#function, status.rawValue)
    status
  //status
 }
 
 public override static func locationServicesEnabled() -> Bool { true }
 
 private let delegate_IQ = DispatchQueue(label: "delegate_IQ", attributes: [.concurrent])
 
 private weak var _delegate: CLLocationManagerDelegate?
 
 public override var delegate: CLLocationManagerDelegate?
 {
  get { delegate_IQ.sync { _delegate } }
  set {
   delegate_IQ.sync {
    _delegate = newValue
    delegateQueue.async {
     newValue?.locationManagerDidChangeAuthorization?(self)
    }
   }
  }
 }
 
 public override func requestWhenInUseAuthorization(){
  
   guard authorizationStatus == .notDetermined else { return }
   guard isLocationServicesEnabled && isNetworkAvailable else {
    status = .denied
    return
   }
   
   #if !os(macOS)
   status = .authorizedWhenInUse
   #else
   status = .authorized
   #endif
  
 }
 private var detectedLocations: [CLLocation]
 {
  [CLLocation(latitude: .random(in: -90...90), longitude: .random(in: -180...180))]
 }
 
 public override func requestAlwaysAuthorization() {
  
   guard authorizationStatus == .notDetermined else { return }
   guard isLocationServicesEnabled && isNetworkAvailable else {
    status = .denied
    return
   }
   
   status = .authorizedAlways
  
  
 }
 
 private let isUpdatingLocation_IQ = DispatchQueue(label: "isUpdatingLocation_IQ", attributes: [.concurrent])
 private var _isUpdatingLocation = false
 
 private var isUpdatingLocation: Bool
 {
  get { isUpdatingLocation_IQ.sync { _isUpdatingLocation } }
  set { isUpdatingLocation_IQ.async(flags: [.barrier]){ [ self ] in _isUpdatingLocation = newValue } }
 }
 
 public override func startUpdatingLocation() {
  
   //print("START! Detecting Geo Location {\(#function)} in Thread [\(Thread.current)]")
  
   if isUpdatingLocation { return }
   
   guard isLocationServicesEnabled && isNetworkAvailable else {
    delegate?.locationManager?(self, didFailWithError: CLError(.denied))
    return
   }
   
   if isLocationUnknown {
    delegate?.locationManager?(self, didFailWithError: CLError(.locationUnknown))
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
//     print("WAITING while detecting Geo Location {\(#function)} in Thread [\(Thread.current)]")
     
     let timeElapsed = DispatchTimeInterval.nanoseconds(.random(in: 100...1000))
     
     delegateQueue.asyncAfter(deadline: .now() + timeElapsed) { [ unowned self ] in
     
//      print("READY! Geo Location Detected in \(timeElapsed) NS!")
      delegate?.locationManager?(self, didUpdateLocations: detectedLocations)
       
     }
     
    @unknown default: break
   }
  
 }
 
 public override func stopUpdatingLocation() {
  
//  print("STOP! Detecting Geo Location {\(#function)} in Thread [\(Thread.current)]")
  
  
   guard isUpdatingLocation else { return }
   isUpdatingLocation = false
  
 }
 
 public override func requestLocation() {
  startUpdatingLocation()
  stopUpdatingLocation()
 }
 
 
}
