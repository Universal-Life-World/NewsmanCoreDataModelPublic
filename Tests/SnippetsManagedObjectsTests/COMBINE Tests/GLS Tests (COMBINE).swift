import XCTest
import NewsmanCoreDataModel
import CoreLocation
import CoreData

@available(iOS 14.0, *)
extension NMBaseSnippetsCombineAPITests {
 //MARK: Test that when all snippets are created they are correctly subscribed to the GL info fields updates using Combine API after cerated snippet is returned using default GL stainless interval == .infinity!
  func test_All_Snippets_Creation_And_Persistance_With_GLS_Available_and_CACHED_using_COMBINE_API() {
   
   //ARRANGE...
   //DEFAULT SET-UP! ALL GEO LOCATIONS ARE NOT STALE & USE CACHED ONES! GLSI == .infinity!
 
   var SUTS = [NMBaseSnippet]() //CREATED SNIPPETS MO.
   let PERSISTED = true // PERSISTANCE!
   let modelMainContext = model.context // GET MAIN MODEL CONTEXT!
   let expectation = XCTestExpectation(description: "All Snippets Types Creation with Combine")
   var SUTS_Updated = [NMBaseSnippet]() //CREATED AND THEN UPDATED WITH GLS INFO FIELDS.
   
   let GLSExpectations = NMBaseSnippet.SnippetType.allCases.map { snippetType -> XCTNSNotificationExpectation in
    
    let contextDidChangeExp = XCTNSNotificationExpectation(name: .NSManagedObjectContextObjectsDidChange,
                                                           object: modelMainContext)
   
    contextDidChangeExp.handler = { notification in
     guard let userInfo = notification.userInfo else { return false }
     guard let updated = userInfo[NSUpdatedObjectsKey] as? Set<NMBaseSnippet> else { return false }
     guard let SUT = updated.first(where: {$0.type == snippetType}) else { return false }
     guard SUT.latitude != nil && SUT.longitude != nil && SUT.location != nil else { return false }
     SUTS_Updated.append(SUT)
     return true
    }
   
    return contextDidChangeExp
   }
   
   let entities = [NMBaseSnippet.self, NMTextSnippet.self, NMPhotoSnippet.self,
                   NMVideoSnippet.self, NMAudioSnippet.self, NMMixedSnippet.self]
   
    //ACTION...
   entities
    .publisher
    .flatMap{ [unowned self] in
     model.create(persist: PERSISTED, entityType: $0,
                  with: NMLocationsGeocoderMock.self,
                  using: NMNetworkWaiterMock.self)
     
    }
    .compactMap{ $0 as? NMBaseSnippet }
    .collect()
    .subscribe(on: DispatchQueue.global(qos: .utility))
    .receive(on: DispatchQueue.main)
    .sink { completion in
     switch completion {
      case .finished: break
      case .failure(let error): XCTFail(error.localizedDescription)
     }
    } receiveValue: {
     
      XCTAssertEqual($0.count , entities.count)
      SUTS.append(contentsOf: $0)
      expectation.fulfill()
     
     
    }.store(in: &disposeBag)
   
   //ACTION (CREATE) WAIT...
   let creationResult = XCTWaiter.wait(for: [expectation], timeout: 0.5)
   
   //ASSERT...
   XCTAssertEqual(creationResult, .completed)
   
   
   //ACTION (UPDATE GL INFO FIELDS) WAIT...
   let locExpResult = XCTWaiter.wait(for: GLSExpectations, timeout: 1)
   
   //ASSERT...
   XCTAssertEqual(locExpResult, .completed)
   XCTAssertEqual(SUTS_Updated, SUTS)
   
   let locations = Set(SUTS.compactMap(\.geoLocation))
   XCTAssertTrue(locations.count == 1) //GL FIELS THE SAME (CACHED)
   
   let addresses = Set(SUTS.compactMap(\.location))
   XCTAssertTrue(addresses.count == 1) //GC ADDRESS THE SAME...
   
  
   
   
   //FINALLY FILE STORAGE CLEAN-UP...
   storageRemoveHelperSync(for: SUTS)
   
 }//func test_All_Snippets_Creation_And_Persistance_With_GLS_Available_and_CACHED_using_COMBINE_API()...
  
//MARK: Test that when all snippets are created they are correctly subscribed to the GL info fields updates using Combine API after created snippet is returned using GL stainless interval == 0!
 func test_All_Snippets_Creation_And_Persistance_With_GLS_Available_and_ALWAYS_NEW_GL_using_COMBINE_API() {
  
  //ARRANGE...
  
  addTeardownBlock { //RECOVER DEFAULTS...
   NMGeoLocationsProvider.locationStalenessInterval = .infinity // set to default state
  }
  
  NMGeoLocationsProvider.locationStalenessInterval = 0 //ALL GEO LOCATIONS ARE NEW ONES - UNIQUE! GLSI == 0
  
  var SUTS = [NMBaseSnippet]() //CREATED SNIPPETS MO.
  let PERSISTED = true // PERSISTANCE!
  let modelMainContext = model.context // GET MAIN MODEL CONTEXT!
  let expectation = XCTestExpectation(description: "All Snippets Types Creation with Combine")
  var SUTS_Updated = [NMBaseSnippet]() //CREATED AND THEN UPDATED WITH GLS INFO FIELDS.
  
  let GLSExpectations = NMBaseSnippet.SnippetType.allCases.map { snippetType -> XCTNSNotificationExpectation in
   
   let contextDidChangeExp = XCTNSNotificationExpectation(name: .NSManagedObjectContextObjectsDidChange,
                                                          object: modelMainContext)
   
   contextDidChangeExp.handler = { notification in
    guard let userInfo = notification.userInfo else { return false }
    guard let updated = userInfo[NSUpdatedObjectsKey] as? Set<NMBaseSnippet> else { return false }
    guard let SUT = updated.first(where: {$0.type == snippetType}) else { return false }
    guard SUT.latitude != nil && SUT.longitude != nil && SUT.location != nil else { return false }
    SUTS_Updated.append(SUT)
    return true
   }
   
   return contextDidChangeExp
  }
  
  let entities = [NMBaseSnippet.self, NMTextSnippet.self, NMPhotoSnippet.self,
                  NMVideoSnippet.self, NMAudioSnippet.self, NMMixedSnippet.self]
  
   //ACTION...
  entities
   .publisher
   .flatMap{ [unowned self] in
    model.create(persist: PERSISTED, entityType: $0,
                 with: NMLocationsGeocoderMock.self,
                 using: NMNetworkWaiterMock.self)
    
   }
   .compactMap{ $0 as? NMBaseSnippet }
   .collect()
   .subscribe(on: DispatchQueue.global(qos: .utility))
   .receive(on: DispatchQueue.main)
   .sink { completion in
    switch completion {
     case .finished: break
     case .failure(let error): XCTFail(error.localizedDescription)
    }
   } receiveValue: {
    
    XCTAssertEqual($0.count , entities.count)
    SUTS.append(contentsOf: $0)
    expectation.fulfill()
    
    
    
   }.store(in: &disposeBag)
  
   //ACTION (CREATE) WAIT...
  let creationResult = XCTWaiter.wait(for: [expectation], timeout: 0.5)
  
   //ASSERT...
  XCTAssertEqual(creationResult, .completed)
  
  
   //ACTION (UPDATE GL INFO FIELDS) WAIT...
  let locExpResult = XCTWaiter.wait(for: GLSExpectations, timeout: 1)
  
   //ASSERT...
  XCTAssertEqual(locExpResult, .completed)
  XCTAssertEqual(SUTS_Updated, SUTS)
  
  let locations = Set(SUTS.compactMap(\.geoLocation))
  XCTAssertTrue(locations.count == entities.count)
  
  let addresses = Set(SUTS.compactMap(\.location))
  XCTAssertTrue(addresses.count == entities.count)
  
  
   //FINALLY FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
  
 }
 
//MARK: Test that when all snippets are created whereas GLS is initially available & internet is available but GCS throws CLError.geocoderFoundPartialResult the geoLocation field is not NIL but location field is NIL!
 
 final func test_GEOCODING_PARTIAL_RESULT_WITH_MAX_RETRY_EXCEEDED_using_COMBINE_API ()  {
  
  addTeardownBlock { //RECOVER DEFAULTS...
   NMLocationsGeocoderMock.setGeocodeFoundFullResult() // set to default state
  }
  
  //ARRANGE...
  //DEFAULT SET-UP! ALL GEO LOCATIONS ARE NOT STALE & USE CACHED ONES! GLSI == .infinity!
  NMLocationsGeocoderMock.setGeocodeFoundPartialResult()
  
  var SUTS = [NMBaseSnippet]() //CREATED SNIPPETS MO.
  let PERSISTED = true // PERSISTANCE!
  let modelMainContext = model.context // GET MAIN MODEL CONTEXT!
  let expectation = XCTestExpectation(description: "All Snippets Types Creation with Combine")
  var SUTS_Updated = [NMBaseSnippet]() //CREATED AND THEN UPDATED WITH GLS INFO FIELDS.
  
  let GLSExpectations = NMBaseSnippet.SnippetType.allCases.map { snippetType -> XCTNSNotificationExpectation in
   
   let contextDidChangeExp = XCTNSNotificationExpectation(name: .NSManagedObjectContextObjectsDidChange,
                                                          object: modelMainContext)
   
   contextDidChangeExp.handler = { notification in
    guard let userInfo = notification.userInfo else { return false }
    guard let updated = userInfo[NSUpdatedObjectsKey] as? Set<NMBaseSnippet> else { return false }
    guard let SUT = updated.first(where: {$0.type == snippetType}) else { return false }
    guard SUT.latitude != nil && SUT.longitude != nil && SUT.location == nil else { return false }
    SUTS_Updated.append(SUT)
    return true
   }
   
   return contextDidChangeExp
  }
  
  let entities = [NMBaseSnippet.self, NMTextSnippet.self, NMPhotoSnippet.self,
                  NMVideoSnippet.self, NMAudioSnippet.self, NMMixedSnippet.self]
  
   //ACTION...
  entities
   .publisher
   .flatMap{ [unowned self] in
    model.create(persist: PERSISTED, entityType: $0,
                 with: NMLocationsGeocoderMock.self,
                 using: NMNetworkWaiterMock.self)
    
   }
   .compactMap{ $0 as? NMBaseSnippet }
   .collect()
   .subscribe(on: DispatchQueue.global(qos: .utility))
   .receive(on: DispatchQueue.main)
   .sink { completion in
    switch completion {
     case .finished: break
     case .failure(let error): XCTFail(error.localizedDescription)
    }
   } receiveValue: {
    
    XCTAssertEqual($0.count , entities.count)
    SUTS.append(contentsOf: $0)
    expectation.fulfill()
    
    
    
   }.store(in: &disposeBag)
  
   //ACTION (CREATE) WAIT...
  let creationResult = XCTWaiter.wait(for: [expectation], timeout: 0.5)
  
   //ASSERT...
  XCTAssertEqual(creationResult, .completed)
  
  
   //ACTION (UPDATE GL INFO FIELDS) WAIT...
  let locExpResult = XCTWaiter.wait(for: GLSExpectations, timeout: 1)
  
   //ASSERT...
  XCTAssertEqual(locExpResult, .completed)
  XCTAssertEqual(SUTS_Updated, SUTS)
  
  let locations = Set(SUTS.compactMap(\.geoLocation))
  XCTAssertTrue(locations.count == 1)
  
  let addresses = Set(SUTS.compactMap(\.location))
  XCTAssertTrue(addresses.isEmpty)
  
  
   //FINALLY FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
 }
 
 
 //MARK: Test that when all snippets are created whereas GLS is initially available without caching (GLSI = 0) & Internet access is available but GCS throws CLError.geocoderFoundPartialResult & then GLS produces full result after a number of retries the GLS & GCS finally succeed!
 
 final func test_GEOCODING_PARTIAL_RESULT_AND_THEN_FULL_RESULT_using_COMBINE_API()  {
  
  addTeardownBlock { //RECOVER DEFAULTS AFTER TEST...
   NMLocationsGeocoderMock.setGeocodeFoundFullResult() // set to default state
   NMGeoLocationsProvider.locationStalenessInterval = .infinity
   NMLocation.maxRetries = 5
  }
  
  //ARRAGE...
  NMGeoLocationsProvider.locationStalenessInterval = 0 //ALL GEO LOCATIONS ARE NEW ONES - UNIQUE!
  NMLocationsGeocoderMock.setGeocodeFoundPartialResult()
  NMLocation.maxRetries = .max
  
  var SUTS = [NMBaseSnippet]() //CREATED SNIPPETS MO.
  let PERSISTED = true // PERSISTANCE!
  let modelMainContext = model.context // GET MAIN MODEL CONTEXT!
  let expectation = XCTestExpectation(description: "All Snippets Types Creation with Combine")
  var SUTS_Updated = [NMBaseSnippet]() //CREATED AND THEN UPDATED WITH GLS INFO FIELDS.
  
  let GLSExpectations = NMBaseSnippet.SnippetType.allCases.map { snippetType -> XCTNSNotificationExpectation in
   
   let contextDidChangeExp = XCTNSNotificationExpectation(name: .NSManagedObjectContextObjectsDidChange,
                                                          object: modelMainContext)
   
   contextDidChangeExp.handler = { notification in
    guard let userInfo = notification.userInfo else { return false }
    guard let updated = userInfo[NSUpdatedObjectsKey] as? Set<NMBaseSnippet> else { return false }
    guard let SUT = updated.first(where: {$0.type == snippetType}) else { return false }
    guard SUT.latitude != nil && SUT.longitude != nil && SUT.location != nil else { return false }
    SUTS_Updated.append(SUT)
    return true
   }
   
   return contextDidChangeExp
  }
  
  let entities = [NMBaseSnippet.self, NMTextSnippet.self, NMPhotoSnippet.self,
                  NMVideoSnippet.self, NMAudioSnippet.self, NMMixedSnippet.self]
  
   //ACTION...
  DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)){
   NMLocationsGeocoderMock.setGeocodeFoundFullResult()
  }
  
  entities
   .publisher
   .flatMap{ [unowned self] in
    model.create(persist: PERSISTED, entityType: $0,
                 with: NMLocationsGeocoderMock.self,
                 using: NMNetworkWaiterMock.self)
    
   }
   .compactMap{ $0 as? NMBaseSnippet }
   .collect()
   .subscribe(on: DispatchQueue.global(qos: .utility))
   .receive(on: DispatchQueue.main)
   .sink { completion in
    switch completion {
     case .finished: break
     case .failure(let error): XCTFail(error.localizedDescription)
    }
   } receiveValue: {
    
    XCTAssertEqual($0.count , entities.count)
    SUTS.append(contentsOf: $0)
    expectation.fulfill()
    
    
    
   }.store(in: &disposeBag)
  
   //ACTION (CREATE) WAIT...
  let creationResult = XCTWaiter.wait(for: [expectation], timeout: 0.5)
  
   //ASSERT...
  XCTAssertEqual(creationResult, .completed)
  
  
   //ACTION (UPDATE GL INFO FIELDS) WAIT...
  let locExpResult = XCTWaiter.wait(for: GLSExpectations, timeout: 1)
  
   //ASSERT...
  XCTAssertEqual(locExpResult, .completed)
  XCTAssertEqual(SUTS_Updated, SUTS)
  
  let locations = Set(SUTS.compactMap(\.geoLocation))
  XCTAssertTrue(locations.count == entities.count)
  
  let addresses = Set(SUTS.compactMap(\.location))
  XCTAssertTrue(addresses.count == entities.count)
  
  
   //FINALLY FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
  
  
 }
}//extension NMBaseSnippetsCombineAPITests {...}
