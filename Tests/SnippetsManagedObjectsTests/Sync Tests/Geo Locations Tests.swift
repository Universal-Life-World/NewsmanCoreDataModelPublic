
import XCTest
import NewsmanCoreDataModel

extension NMBaseSnippetsTests
{
 
 final func createHelper<T: NMBaseSnippet>(_ objectType:T.Type,
                                           _ persisted: Bool = false,
                                           _ snippetType: NMBaseSnippet.SnippetType,
                                           _ handlerQueue: DispatchQueue,
                                           _ handler: @escaping (T) throws -> () )
 {
  model.create(persist: persisted, objectType: T.self) { result in
   handlerQueue.async {
    switch result {
     case let .success(snippet):
      do {
       try handler(snippet)
      }
      catch {
       XCTFail(error.localizedDescription)
      }
      
     case let .failure(error):
      XCTFail(error.localizedDescription)
    }
   }
  }
 }
 
 final func test_snippet_creation_with_geo_locations_services_available()
 {
  let persisted = true
  let queue = DispatchQueue(label: "test_snippet_creation_with_geo_locations")
  
  var SUTS = [NMBaseSnippet]()
  
  let creationGroup = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   let expectation = XCTestExpectation(description: "All Snippets Types Creation")
   
   switch snippetType {
    case .base: createHelper(NMBaseSnippet.self, persisted, snippetType, queue) {
     SUTS.append($0)
     expectation.fulfill()
    }
     
    case .photo: createHelper(NMPhotoSnippet.self, persisted, snippetType, queue) {
     SUTS.append($0)
     expectation.fulfill()
    }
     
    case .audio: createHelper(NMAudioSnippet.self, persisted, snippetType, queue) {
     SUTS.append($0)
     expectation.fulfill()
    }
     
    case .video: createHelper(NMVideoSnippet.self, persisted, snippetType, queue) {
     SUTS.append($0)
     expectation.fulfill()
    }
     
    case .text: createHelper(NMTextSnippet.self, persisted, snippetType, queue) {
     SUTS.append($0)
     expectation.fulfill()
    }
     
    case .mixed: createHelper(NMMixedSnippet.self, persisted, snippetType, queue) {
     SUTS.append($0)
     expectation.fulfill()
    }
   }
   
   return expectation
  }
  
  let resultWhenCreated = XCTWaiter.wait(for: creationGroup, timeout: 1)
  
  XCTAssertEqual(resultWhenCreated, .completed)
  
  let locExpGroup = SUTS.map{ (sut: NMBaseSnippet) -> [XCTKVOExpectation] in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: sut)
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: sut)
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: sut)
   
   sut.updateGeoLocations(with: NMLocationsGeocoderMock.self, using: NMNetworkWaiterMock.self)
   
   return [latExp, lonExp , locExp ] }.flatMap{$0}
  
  let resultWithLocationsUpdates = XCTWaiter.wait(for: locExpGroup, timeout: 3)
  XCTAssertEqual(resultWithLocationsUpdates, .completed)
  
  storageRemoveHelperSync(for: SUTS)
  
  
  
 }
 
 
 
 
}
