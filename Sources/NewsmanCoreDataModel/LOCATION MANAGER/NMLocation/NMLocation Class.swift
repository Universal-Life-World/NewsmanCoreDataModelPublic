
import CoreLocation
import class Foundation.NSCache
import class Foundation.NSValue
import struct Foundation.Date
import struct CoreGraphics.CGPoint
import class Dispatch.DispatchSemaphore


extension NSValue {
 convenience init(clLocation: CLLocation) {
  
#if os(macOS)
  self.init(point: CGPoint(x: clLocation.coordinate.latitude,
                             y: clLocation.coordinate.longitude))
#else
  self.init(cgPoint: CGPoint(x: clLocation.coordinate.latitude,
                             y: clLocation.coordinate.longitude))
#endif
  
 }
}

@available(iOS 13.0, *)
public class NMPlacemarksCache {
 var container = [NMLocation: NMPlacemarkAddressRepresentable]()

 final subscript(_ location: NMLocation) -> NMPlacemarkAddressRepresentable? {
  get { container[location] }
  set { container[location] = newValue }
 }
 
 
 
}

@available(iOS 15.0, *)
@available(macOS 12.0.0, *)
public actor NMPlacemarksCacheActor{
 
 private var tasksMap = [NMLocation: Task<NMPlacemarkAddressRepresentable, Error>]()

 public func placemark(for location: NMLocation) async -> NMPlacemarkAddressRepresentable? {
  guard let cachedTask = tasksMap[location] else { return nil }
  do {
   return try await cachedTask.value
  } catch {
    tasksMap[location] = nil
    return nil
  }
 }
 
 public func removePlacemarkTask(for location: NMLocation) {
  tasksMap[location] = nil
 }
 
 public func setPlacemarkTask(for location: NMLocation, task: Task<NMPlacemarkAddressRepresentable, Error>){
  if tasksMap[location] == nil {
   tasksMap[location] = task
  }
  //tasksMap.updateValue(task, forKey: location)?.cancel()
 }
}

@available(iOS 13.0, *)
public final class NMLocation: Hashable {

 public static let locationsCache = NMPlacemarksCache()
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 public static let locationsCacheActor = NMPlacemarksCacheActor()
 
 static let locationCacheMutex = DispatchSemaphore(value: 1)
 
 public static func == (lhs: NMLocation, rhs: NMLocation) -> Bool {
  lhs.location.coordinate.latitude == rhs.location.coordinate.latitude &&
  lhs.location.coordinate.longitude == rhs.location.coordinate.longitude
 }
 

 public static let invalid = NMLocation(location: CLLocation(coordinate: kCLLocationCoordinate2DInvalid,
                                                             altitude: 0,
                                                             horizontalAccuracy: 0,
                                                             verticalAccuracy: 0,
                                                             timestamp: Date()))
 
 public var isValid: Bool { CLLocationCoordinate2DIsValid(location.coordinate) }
 
 
 public func hash(into hasher: inout Hasher) {
  hasher.combine(location.coordinate.latitude)
  hasher.combine(location.coordinate.longitude)
 }
 
 public init (location: CLLocation) {
  self.location = location
 }
 
 let location: CLLocation
 
 var retryCount = 0
 public static var maxRetries = 5
 
// deinit {
//  print ("NM LOCATION FOR [\(location)] DEALLOCATED!")
// }
 
}





