import Foundation
import CoreLocation

extension NMBaseSnippet {
 
 public static let geoLocation2DKey = "geoLocation2D"
 
 @NSManaged fileprivate var primitiveLongitude: NSNumber?
 @NSManaged fileprivate var primitiveLatitude:  NSNumber?
 @NSManaged fileprivate var primitiveLocation:  String?
 
 //MARK: Accessors for GEOLocation2D
 public var geoLocation2D: CLLocationCoordinate2D? {
  
  get {
   willAccessValue(forKey: Self.geoLocation2DKey)
   guard let longitude = primitiveLongitude?.doubleValue,
         let latitude  = primitiveLatitude?.doubleValue else { return nil }
   
   didAccessValue(forKey: Self.geoLocation2DKey)
   return .init(latitude: latitude, longitude: longitude)
  }
  
  set {
   
   guard let location2D = newValue else { return }
   willChangeValue(forKey: Self.geoLocation2DKey)
   primitiveLatitude =   NSNumber(value: location2D.latitude)
   primitiveLongitude =  NSNumber(value: location2D.longitude)
   didChangeValue(forKey: Self.geoLocation2DKey)
  }
 }
 
 
  //MARK: Silent Accessors for GEOLocation2D.
 public var silentGeoLocation2D: CLLocationCoordinate2D? {
  
  get {
   guard let longitude = primitiveLongitude?.doubleValue,
         let latitude  = primitiveLatitude?.doubleValue else { return nil }
   return .init(latitude: latitude, longitude: longitude)
  }
  
  set {
   guard let location2D = newValue else { return }
   primitiveLatitude  =  NSNumber(value: location2D.latitude)
   primitiveLongitude =  NSNumber(value: location2D.longitude)
  }
 }
 
  //MARK: Silent Accessors for Location String Field.
 public var silentLocation: String? {
  get { primitiveLocation }
  set { primitiveLocation = newValue }
 }
 
}
