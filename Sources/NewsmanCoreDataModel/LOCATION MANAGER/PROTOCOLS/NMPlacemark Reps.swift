
import class CoreLocation.CLPlacemark

public protocol NMPlacemarkAddressRepresentable where Self: AnyObject
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
