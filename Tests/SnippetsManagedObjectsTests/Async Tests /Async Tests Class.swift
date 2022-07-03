
import XCTest
import NewsmanCoreDataModel
import CoreData

@available(iOS 14.0, *)
class NMBaseSnippetsAsyncTests: XCTestCase, NMSnippetsTestsStorageRemovable {
 var model: NMCoreDataModel!
 
 weak var locationManagerMock: NMLocationManagerMock!
 weak var locationsProvider: NMGeoLocationsProvider!
 weak var weakModel: NMCoreDataModel!
 weak var MOC: NSManagedObjectContext!
 weak var modelContainer: NSPersistentContainer!
 
 private typealias SUTBlock = () -> NSManagedObject?

 private var SUTBlocks = [SUTBlock]()
 
 var SUTS: [NSManagedObject] {
  get { SUTBlocks.compactMap{ $0() } }
  set {
   
   SUTBlocks.removeAll()
 
   newValue.forEach { SUT in SUTBlocks.append({ [ weak SUT ] () -> NSManagedObject? in SUT }) }
   
   WEAK_SUTS.removeAll()
   WEAK_SUTS.append(newValue)
  }
 }
 
 let WEAK_SUTS = WeakContainer<NSManagedObject>()
 
 static let WEAK_MOCS = WeakContainer<NSManagedObjectContext>()
 
 override class func setUp() {}
 
 override func setUp() {
  let locationManager = NMLocationManagerMock()
  self.locationManagerMock = locationManager
  
  
  let locationsProvider = NMGeoLocationsProvider(provider: locationManager)
  
  self.locationsProvider = locationsProvider
  
  model = NMCoreDataModel(name: "Newsman",
                          for: .inMemorySQLight,
                          locationsProvider: locationsProvider)
  self.weakModel = model
  self.MOC = model.context
 // Self.WEAK_MOCS.append(model.context)
  self.modelContainer = model.persistentContainer
 }
 
 
 private func assertNoMemoryLeaksAfterTearDown(){
  
 
  XCTAssertNil(weakModel)
  XCTAssertNil(modelContainer)
 
  DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
   [ weak MOC = self.MOC, WEAK_SUTS = self.WEAK_SUTS,
     weak locationManagerMock = self.locationManagerMock,
     weak locationsProvider = self.locationsProvider ] in
   XCTAssertTrue(WEAK_SUTS.isEmpty)
   XCTAssertNil(locationManagerMock)
   XCTAssertNil(locationsProvider)
   XCTAssertNil(MOC)
  }
  
 
  
  
  //XCTAssertTrue(WEAK_SUTS.isEmpty)
  
 }
 
 override func tearDown() {
  
  //model.context.reset()
  
  model = nil
 
  assertNoMemoryLeaksAfterTearDown()
  
 }
 

 
 override func setUpWithError() throws {}
 
 override func tearDownWithError() throws { }
 
// override class func tearDown() {
//  DispatchQueue.main.async {
//   XCTAssertTrue(WEAK_MOCS.isEmpty)
//  }
// }
 
 

}
