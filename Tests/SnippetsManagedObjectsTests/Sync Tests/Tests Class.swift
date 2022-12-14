

import XCTest
import NewsmanCoreDataModel
import Foundation

@available(iOS 14.0, *)
final class NMBaseSnippetsTests: XCTestCase, NMSnippetsTestsStorageRemovable
{
 var model: NMCoreDataModel!
 
 weak var locationManagerMock: NMLocationManagerMock!
 
 override class func setUp() { }
 
 override func setUp() {
  
  let locationManager = NMLocationManagerMock()
  locationManagerMock = locationManager
  
  let locationsProvider = NMGeoLocationsProvider(provider: locationManager)
  model = NMCoreDataModel(name: "Newsman", for: .inMemorySQLight, locationsProvider: locationsProvider)

 }
 
 override func tearDown() { model = nil }
 
 override func setUpWithError() throws {}

 override func tearDownWithError() throws { }
 
 override class func tearDown() { }
 
 
}
