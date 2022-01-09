

import XCTest
import NewsmanCoreDataModel

class NMBaseSnippetsTests: XCTestCase
{
 static var model: NMCoreDataModel!
 
 var sut: NMBaseSnippet!
 {
  willSet
  {
   if newValue == nil, let storageProvider = sut as? NMFileStorageManageable, let id = sut.id
   {
    let className = String(describing: type(of: self.sut))
    storageProvider.removeFileStorage{ result in
     switch result {
      case .success():
      print ("\(className) [\(id)] FILE STORAGE IS DELETED SUCCESSFULLY AFTER TEST!")
      case .failure(let error):
       print (error.localizedDescription)
     
     }
    }
   }
  }
 }
 
 override class func setUp()
 {
  model = NMCoreDataModel(name: "Newsman", for: .inMemorySQLight)
 }
 
 override func setUp() {}
 
 override func tearDown() { sut = nil }
 
 override func setUpWithError() throws {}

 override func tearDownWithError() throws { }
 
 override class func tearDown() { model = nil }
 
 
}
