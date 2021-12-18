import XCTest
import NewsmanCoreDataModel

final class NMCoreDataModelBasicTests: XCTestCase
{
 
 var sut: NMCoreDataModel!
 
 override class func setUp()
 {
  //print("CLASS function", #function)
 }
 
 override func setUpWithError() throws
 {
  //print(#function)
 }
 
 override func setUp()
 {
  //print(#function)
 // sut = NMCoreDataModel(for: .inMemorySQLight)
 }
 
 override func tearDown()
 {
  //print(#function)
  sut = nil
 }
 
 override func tearDownWithError() throws
 {
  //print(#function)
 }

 override class func tearDown()
 {
  //print("CLASS function", #function)
 }

 func test_that_in_memory_model_loaded_with_default_MOM() throws
 {
  sut = NMCoreDataModel(for: .inMemorySQLight)
  XCTAssertNotNil(sut.context.persistentStoreCoordinator)
  XCTAssertEqual(sut.context.persistentStoreCoordinator!.persistentStores.count, 1)
  XCTAssertEqual(sut.context.persistentStoreCoordinator!.managedObjectModel.entities.count, 0)
 }
 
 
 func test_that_in_memory_model_loaded_with_named_MOM() throws
 {
  sut = NMCoreDataModel(name: "Newsman", for: .inMemorySQLight)
  XCTAssertNotNil(sut.context.persistentStoreCoordinator)
  XCTAssertEqual(sut.context.persistentStoreCoordinator!.persistentStores.count, 1)
  XCTAssertEqual(sut.context.persistentStoreCoordinator!.managedObjectModel.entities.count, 10)
 }
 
 
// func test_that_this_model() throws
// {
//
// }
}

