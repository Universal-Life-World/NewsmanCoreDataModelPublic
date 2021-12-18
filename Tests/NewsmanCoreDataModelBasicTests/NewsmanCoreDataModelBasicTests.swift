import XCTest
import NewsmanCoreDataModel

final class NMCoreDataModelBasicTests: XCTestCase
{
 
 var sut: NMCoreDataModel!
 
 override class func setUp()
 {
  print("CLASS function", #function)
 }
 
 override func setUpWithError() throws
 {
  print(#function)
 }
 
 override func setUp()
 {
  print(#function)
  sut = NMCoreDataModel.instance
 }
 
 override func tearDown()
 {
  print(#function)
  sut = nil
 }
 
 override func tearDownWithError() throws
 {
  print(#function)
 }

 override class func tearDown()
 {
  print("CLASS function", #function)
 }

 func test_that_this_model_is_singleton() throws
 {

  let newSut = NMCoreDataModel.instance
 
  XCTAssertTrue(newSut === sut, "The model is not a singleton")
 
 
 }
 
// func test_that_this_model() throws
// {
//
// }
}

