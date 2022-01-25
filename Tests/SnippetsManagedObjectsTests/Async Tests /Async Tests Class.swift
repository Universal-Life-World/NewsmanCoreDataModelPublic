
import XCTest
import NewsmanCoreDataModel

final class NMBaseSnippetsAsyncTests: XCTestCase
{
 static var model: NMCoreDataModel!
 static weak var locationManagerMock: NMLocationManagerMock!
 
 override class func setUp()
 {
  let locationManager = NMLocationManagerMock()
  locationManagerMock = locationManager
  let locationsProvider = NMGeoLocationsProvider(provider: locationManager)
  model = NMCoreDataModel(name: "Newsman",for: .inMemorySQLight, locationsProvider: locationsProvider)
 }
 
 
 override func setUp() { }
 
 override func tearDown() { }
 
 override func setUpWithError() throws {}
 
 override func tearDownWithError() throws { }
 
 override class func tearDown() { model = nil }
 
 

}
