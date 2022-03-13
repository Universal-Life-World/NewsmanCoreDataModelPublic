

import XCTest
import NewsmanCoreDataModel
import Combine

@available(iOS 14.0, *)
class NMBaseSnippetsCombineAPITests: XCTestCase, NMSnippetsTestsStorageRemovable {
 
 var model: NMCoreDataModel!
 
 var disposeBag = Set<AnyCancellable>()
 
 weak var locationManagerMock: NMLocationManagerMock!
 
 override class func setUp() {}
 
 override func setUp() {
  let locationManager = NMLocationManagerMock()
  locationManagerMock = locationManager
  
  let locationsProvider = NMGeoLocationsProvider(provider: locationManager)
  model = NMCoreDataModel(name: "Newsman",for: .inMemorySQLight, locationsProvider: locationsProvider)
 }
 
 override func tearDown() { model = nil; disposeBag.removeAll() }
 
 override func setUpWithError() throws {}
 
 override func tearDownWithError() throws { }
 
 override class func tearDown() { }
 
 
 
}

