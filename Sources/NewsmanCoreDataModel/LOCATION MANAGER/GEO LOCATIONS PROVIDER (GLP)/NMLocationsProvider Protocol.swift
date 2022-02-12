
import protocol CoreLocation.CLLocationManagerDelegate
import class CoreLocation.CLLocationManager

extension CLLocationManager: NMLocationProvider {}

public protocol NMLocationProvider
{
 static func locationServicesEnabled() -> Bool
 
 var delegate: CLLocationManagerDelegate? { get set }
 
 func requestWhenInUseAuthorization()
  // Requests the user’s permission to use location services while the app is in use.
 
 func requestAlwaysAuthorization()
  //Requests the user’s permission to use location services regardless of whether the app is in use.
 
 func startUpdatingLocation()
  // Starts the generation of updates that report the user’s current location.
 
 func stopUpdatingLocation()
  // Stops the generation of location updates.
 
 func requestLocation()
  // Requests the one-time delivery of the user’s current location.
 
}
