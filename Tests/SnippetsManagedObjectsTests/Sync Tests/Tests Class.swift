

import XCTest
import NewsmanCoreDataModel


final class NMBaseSnippetsTests: XCTestCase
{
 static var model: NMCoreDataModel!
 static weak var locationManagerMock: NMLocationManagerMock!
 
 func fileStorageCleanup(for sut: NMBaseSnippet) {
  guard let storageProvider = sut as? NMFileStorageManageable else { return }
 
  let className = String(describing: type(of: sut))
  storageProvider.removeFileStorage{ [ id = storageProvider.id ] result in
   switch result {
    case .success():
     print ("\(className) [\(id!)] FILE STORAGE IS DELETED SUCCESSFULLY AFTER TEST!")
    case .failure(let error):
     print (error.localizedDescription)
   
   }
  }
 }
 
 var suts: [NMBaseSnippet]! {
  willSet {
   if newValue == nil && suts != nil { suts.forEach { fileStorageCleanup(for: $0)} }
  }
 }
 
 var sut: NMBaseSnippet! {
  willSet  {
   if newValue == nil && sut != nil  { fileStorageCleanup(for: sut) }
  }
 }
 
 override class func setUp()
 {
  let locationManager = NMLocationManagerMock()
  locationManagerMock = locationManager
  
  let locationsProvider = NMGeoLocationsProvider(provider: locationManager)
  model = NMCoreDataModel(name: "Newsman", for: .inMemorySQLight, locationsProvider: locationsProvider)

 }
 
 
 override func setUp() { suts = [] }
 
 override func tearDown() { sut = nil; suts = nil }
 
 override func setUpWithError() throws {}

 override func tearDownWithError() throws { }
 
 override class func tearDown() { model = nil }
 
 
}
