//*************************************************************************************************************
//MARK: FULLY ASYNC GEO LOCATIONS API.
//*************************************************************************************************************

import XCTest
import NewsmanCoreDataModel
import CoreData


@available(iOS 15.0, *)
@available(macOS 12.0.0, *)
final class NMBaseSnippetsGeoLocationAsyncAPITests: NMBaseSnippetsAsyncTests
{
//MARK: Test that when all snippets are created their fields updated if GEO location services (GLS) & GEO coding services (GCS) are  available.
  
 final func test_GEO_LOCATIONS_DETECTION_WHEN_ALL_SERVICES_AVAILABLE_ASYNC () async throws
 {
  //ARRANGE...
  //DEFAULT SET-UP! ALL GEO LOCATIONS ARE NOT STALE & USE CACHED ONES! GLSI == .infinity!
 
  //ACTION...
  let SUTS = try await createAllSnippetsWithGeoLocations()
  
  //ASSERT (IN CONTEXT QUEUE)...
  await model.context.perform {
   XCTAssertEqual(SUTS.compactMap{ $0.latitude  }.count, SUTS.count)
   XCTAssertEqual(SUTS.compactMap{ $0.longitude }.count, SUTS.count)
   XCTAssertEqual(SUTS.compactMap{ $0.location  }.count, SUTS.count)
  }
  
  // FINALLY REMOVE SNIPPET FILE STORAGE...
  try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup...
  
 } //final func test_All_Snippets_Creation_And_Persistance_With_GEO_Locations_Available_ASYNC ()...
  
  
//MARK: Test that when all snippets are created their fields updated if GLS & GCS available using caching logic of last detected GL with GL stainless interval (GLSI) set to maximum value (= .infinity)
 
 final func test_WITH_CACHED_GEO_LOCATION_ASYNC () async throws {
  
  //ARRANGE...
  //DEFAULT SET-UP! ALL GEO LOCATIONS ARE NOT STALE & USE CACHED ONES! GLSI == .infinity!

  //ACTION...
  let SUTS = try await createAllSnippetsWithGeoLocations()
  
  //ASSERT (IN CONTEXT QUEUE)...
  await model.context.perform {
   let geoLocations = SUTS.compactMap{ $0.geoLocation }
   let addresses = SUTS.compactMap{ $0.location }
   let suts_count = SUTS.count
   
   XCTAssertEqual(geoLocations.count, suts_count)
   XCTAssertEqual(addresses.count, suts_count)
   XCTAssertTrue(Set(geoLocations).count == 1)
   XCTAssertTrue(Set(addresses).count == 1)
  }
  
  // FINALLY REMOVE SNIPPET FILE STORAGE...
  try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup...
  
 }//final func test_All_Snippets_Creation_And_Persistance_With_CACHED_GEO_locations_ASYN...
 
 //MARK: Test that when all snippets are created their fields updated if GLS & GCS are available without caching last detected GL, using GLSI == 0
 
 final func test_WITHOUT_CACHING_GEO_LOCATION_ASYNC () async throws {
  
  addTeardownBlock { //RECOVER DEFAULTS...
   NMGeoLocationsProvider.locationStalenessInterval = .infinity // set to default state
  }
  
  //ARRANGE...
  NMGeoLocationsProvider.locationStalenessInterval = 0 //ALL GEO LOCATIONS ARE NEW ONES - UNIQUE! GLSI == 0
  
  //ACTION...
  let SUTS = try await createAllSnippetsWithGeoLocations()
  
  //ASSERT (IN CONTEXT QUEUE)...
  
  await model.context.perform {
   let geoLocations = SUTS.compactMap{ $0.geoLocation }
   let addresses = SUTS.compactMap{ $0.location }
   let suts_count = SUTS.count
   
   XCTAssertEqual(geoLocations.count, suts_count)
   XCTAssertEqual(addresses.count, suts_count)
   XCTAssertTrue(Set(geoLocations).count == suts_count)
   XCTAssertTrue(Set(addresses).count == suts_count)
  }
  
  //FINALLY REMOVE FILE STORAGE...
  try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup...
  
 }//final func test_All_Snippets_Creation_And_Persistance_WITHOUT_CACHING_GEO_locations_ASYNC

//MARK: Test that when all snippets are created whereas GLS is initially available & internet is available but GCS throws CLError.geocoderFoundPartialResult the Failures.maxRetryCountExceeded(count: retryCount) is finally thrown after max retry count exceeded!
 
 final func test_GEOCODING_PARTIAL_RESULT_WITH_MAX_RETRY_EXCEEDED_ASYNC() async throws {
  
  addTeardownBlock { //RECOVER DEFAULTS...
   NMLocationsGeocoderMock.setGeocodeFoundFullResult() // set to default state
  }
  
  //ARRANGE...
  NMLocationsGeocoderMock.setGeocodeFoundPartialResult()
  
  do {
   
  //ACTION...
   let _ = try await createAllSnippetsWithGeoLocations()
  } catch NMGeoLocationsProvider.Failures.maxRetryCountExceeded(count: let retryCount) {
  
  //ASSERT...
   XCTAssertTrue(retryCount > NMLocation.maxRetries,
                 "API RETRY COUNT MUST EXCEED PRESET [\(NMLocation.maxRetries)]")
   
  //FETCH SNIPPETS AND ASSERT IN CONTEXT QUEUE...
   let SUTS = try await snippetsFetchHelper()
   
    // ASSERT (IN CONTEXT QUEUE) THAT SNIPPETS HAVE BEEN CREATED WITHOUT GL FIELDS...
   await model.context.perform {
    
    let geoLocations = SUTS.compactMap{ $0.geoLocation }
    let addresses = SUTS.compactMap{ $0.location }
    
    XCTAssertEqual(SUTS.count, 6, "THE FETCH MUST HAVE ALL SNIPPET TYPES!")
    XCTAssertEqual(geoLocations.count, 6, "ALL SNIPPETS MUST HAVE GL DETECTED")
    XCTAssertEqual(addresses.count, 0, "ALL SNIPPETS MUST HAVE GEOCODED ADDRESS == NIL")
    
   }
   
    //SNIPPETS FILE STORAGE FOLDERS REMOVAL...
   try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup...
  } catch {
    XCTFail("UNEXPECTED ERROR THROWN DURING TEST \(error.localizedDescription)!!!")
  }
 }
 
//MARK: Test that when all snippets are created whereas GLS is initially available without caching (GLSI = 0) & Internet access is available but GCS throws CLError.geocoderFoundPartialResult & then GLS produces full result after a number of retries the GLS & GCS finally succeed!
 
 final func test_GEOCODING_PARTIAL_RESULT_AND_THEN_FULL_RESULT_WITH_ALL_NEW_ASYNC() async throws {
  
  addTeardownBlock { //RECOVER DEFAULTS AFTER TEST...
   NMLocationsGeocoderMock.setGeocodeFoundFullResult() // set to default state
   NMGeoLocationsProvider.locationStalenessInterval = .infinity
   NMLocation.maxRetries = 5
  }
  
  //ARRAGE...
  NMGeoLocationsProvider.locationStalenessInterval = 0 //ALL GEO LOCATIONS ARE NEW ONES - UNIQUE!
  NMLocationsGeocoderMock.setGeocodeFoundPartialResult()
  NMLocation.maxRetries = .max
  
  //ACTION AGAIN...
  Task.detached (priority: .high){
   try await Task.sleep(timeInterval: .milliseconds(200))
   NMLocationsGeocoderMock.setGeocodeFoundFullResult()
  }
  
  //ACTION...
  let SUTS = try await createAllSnippetsWithGeoLocations()
  
  //ASSERT (IN CONTEXT QUEUE)...
  await model.context.perform {
   let geoLocations = SUTS.compactMap{ $0.geoLocation }
   let addresses = SUTS.compactMap{ $0.location }
   let suts_count = SUTS.count
   
   XCTAssertEqual(geoLocations.count, suts_count)
   XCTAssertEqual(addresses.count, suts_count)
   XCTAssertTrue(Set(geoLocations).count == suts_count)
   XCTAssertTrue(Set(addresses).count == suts_count)
  }
  
  //SNIPPETS FILE STORAGE FOLDERS REMOVAL...
  try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup..
 }
 
  
//MARK: Test that when all snippets are created whereas GLS is initially available with caching (GLSI = +∞) & Internet access is available but GCS throws CLError.geocoderFoundPartialResult & then GLS produces full result after a numberof retries the GLS & GCS finally succeed!
 
 final func test_GEOCODING_PARTIAL_RESULT_AND_THEN_FULL_RESULT_WITH_CACHING_ASYNC() async throws {
  
  addTeardownBlock {
    //RECOVER DEFAULT SETTINGS...
   NMLocationsGeocoderMock.setGeocodeFoundFullResult() // set to default state
   NMLocation.maxRetries = 5
  }
  
  //ARRANGE...
  NMGeoLocationsProvider.locationStalenessInterval = .infinity //ALL SNIPPETS GET THE SAME CACHED GL!
  NMLocationsGeocoderMock.setGeocodeFoundPartialResult() // MOCK GCS PARTIAL RESULT ERROR...
  NMLocation.maxRetries = .max
  
  //ACTION AGAIN AFTER DELAY...
  Task.detached (priority: .medium){
   try await Task.sleep(timeInterval: .milliseconds(200))
   NMLocationsGeocoderMock.setGeocodeFoundFullResult() // MOCK RECOVER FROM GCS PARTIAL RESULT ERROR..
  }
  
  //ACTION AGAIN AFTER DELAY...
  let SUTS = try await createAllSnippetsWithGeoLocations()
  
  //ASSERT (IN CONTEXT QUEUE)...
  await model.context.perform {
   let geoLocations = SUTS.compactMap{ $0.geoLocation }
   let addresses = SUTS.compactMap{ $0.location }
   let suts_count = SUTS.count
   
   XCTAssertEqual(geoLocations.count, suts_count)
   XCTAssertEqual(addresses.count, suts_count)
   XCTAssertTrue(Set(geoLocations).count == 1)
   XCTAssertTrue(Set(addresses).count == 1)
  }
  
  //SNIPPETS FILE STORAGE FOLDERS REMOVAL...
  try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup..
 }
 
 
 //MARK: Test that when all snippets are created when location GLS is prohibited & then authorised by user.
 
 final func test_GEO_LOCATION_SERVICES_DENIED_and_then_Authorized_ASYNC() async throws {
  
  addTeardownBlock {
   NMGeoLocationsProvider.locationStalenessInterval = .infinity  //RECOVER DEFAULT SETTINGS...
  }
  
  //ARRANGE...
  locationManagerMock.disableLocationServices() //MOCK LOCATION SERVICES DENIED STATE...
  NMGeoLocationsProvider.locationStalenessInterval = 0 // ALL GL UNIQUE AND NOT STALE...
  
  //ACTION AGAIN AFTER DELAY...
  Task.detached{ [ self ] in
   try await Task.sleep(timeInterval: .milliseconds(300))
   locationManagerMock.enableLocationServicesWhenInUse() // MOCK LOCATION SERVICES AUTHORISED STATE...
  }
  
  //ACTION...
  let SUTS = try await createAllSnippetsWithGeoLocations()
  
  //ASSERT (IN CONTEXT QUEUE)...
  await model.context.perform {
   let geoLocations = SUTS.compactMap{ $0.geoLocation }
   let addresses = SUTS.compactMap{ $0.location }
   
   XCTAssertEqual(geoLocations.count, SUTS.count)
   XCTAssertEqual(addresses.count, SUTS.count)
   XCTAssertTrue(Set(geoLocations).count == SUTS.count)
   XCTAssertTrue(Set(addresses).count == SUTS.count)
  }
  
  //SNIPPETS FILE STORAGE FOLDERS REMOVAL...
  try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup...
  
 }//func test_All_Snippets_creation_with_GEO_locations_DENIED_and_then_Authorized_ASYNC
 
 
 
//MARK: Test that when all snippets are created whithout GL when refetched again the GL fields initialised.
 final func test_GEO_LOCATION_UNUSED_AND_WHEN_MO_FETCHED_FROM_MOC_DONE_ASYNC() async throws {
  
  addTeardownBlock {
   NMGeoLocationsProvider.locationStalenessInterval = .infinity  //RECOVER DEFAULT SETTINGS...
  }
  
   //ARRANGE...
  NMGeoLocationsProvider.locationStalenessInterval = 0 // ALL GL UNIQUE AND NOT STALE...
  
  
  //ACTION FIRST...
  let SUTS = try await createAllSnippets() //CREATE ALL 6 TYPES OF SNIPPETS WITHOUT GL INFO IN MAIN QUEUE MOC!
  
  //ASSERT WHEN CREATED AND INSERTED INTO MAIN MOC...
  
  let snippets_count = SUTS.count
  XCTAssertTrue(snippets_count == 6)
  
  await model.mainContext.perform {
   
   let geoLocations = SUTS.compactMap{ $0.geoLocation }
   let addresses = SUTS.compactMap{ $0.location }
 
   XCTAssertTrue(geoLocations.count == 0)
   XCTAssertTrue(addresses.count == 0)
  }
  
   //ARRANGE BG CONTEXT...
  let bgContext = await model.newBackgroundContext
 
  //ACTION SECOND! FETCH SNIPPETS FROM PSC IN BG CONTEXT...
  let SUTS_BG = try await bgContext.perform { () ->  [NMBaseSnippet] in
   
   //FETCH ALL SAVED SNIPPETS AS FULLY MATERIALISED MO IN BG CONTEXT...
   let fetchRequest = NSFetchRequest<NMBaseSnippet>(entityName: "NMBaseSnippet")
   fetchRequest.returnsObjectsAsFaults = false
   let SUTS = try bgContext.fetch(fetchRequest)
    
   //ASSERT WHEN FETCHED IN BG CONTEXT...
   let geoLocations = SUTS.compactMap{ $0.geoLocation }
   let addresses = SUTS.compactMap{ $0.location }
   XCTAssertEqual(geoLocations.count, 0)
   XCTAssertEqual(addresses.count, 0)
   
   return SUTS
  }
  
  XCTAssertEqual(SUTS_BG.count, snippets_count)
  
  try await Task.sleep(timeInterval: .milliseconds(100)) //AWAIT...
  
  //ASSERT (IN BG CONTEXT QUEUE) ALL SNIPPETS HAVE GL FIELDS INITIALIZED AFTER AWAKE FROM FETCH...
  await bgContext.perform {
   let geoLocations = SUTS_BG.compactMap{ $0.geoLocation }
   let addresses = SUTS_BG.compactMap{ $0.location }
   XCTAssertEqual(geoLocations.count, 6)
   XCTAssertEqual(addresses.count, 6)
   
  }
  
  try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup...
  
 }//func test_All_Snippets_creation_with_GEO_locations_DENIED_and_then_Authorized_ASYNC

//MARK: Test that when all snippets are created when location GLS & GCS are available but location unknown error occurs and then location detected after a number of retries.
 
 final func test_LOCATION_UNKNOWN_ERROR_AND_THEN_Detected_ASYNC() async throws {
  
  addTeardownBlock {
   NMGeoLocationsProvider.locationStalenessInterval = .infinity  // recover default static vars!
  }
  
  //ARRANGE...
  NMGeoLocationsProvider.locationStalenessInterval = 0 // DETECT ALWAYS NEW GL...
  locationManagerMock.isLocationUnknown = true  // MOCK LOCATION UNKNOWN ERROR...
  
  //THEN ACTION AFTER ASYNC WITH DELAY...
  Task.detached{ [self] in
   try await Task.sleep(timeInterval: .milliseconds(200))
   locationManagerMock.isLocationUnknown = false // SWITCH OFF LOCATION UNKNOWN ERROR STATE...
  }
  
  //ACTION NOW...
  let SUTS = try await createAllSnippetsWithGeoLocations()
  
  //ASSERT (IN CONTEXT QUEUE)...
  await model.context.perform {
   let geoLocations = SUTS.compactMap{ $0.geoLocation }
   let addresses = SUTS.compactMap{ $0.location }
   XCTAssertEqual(geoLocations.count, SUTS.count)
   XCTAssertEqual(addresses.count, SUTS.count)
   XCTAssertTrue(Set(geoLocations).count == SUTS.count)
   XCTAssertTrue(Set(addresses).count == SUTS.count)
  }
  
  //SNIPPETS FILE STORAGE FOLDERS REMOVAL...
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 //MARK: Test that when all snippets are created when location services initially available & internet is available but location unknown error occurs and location finally not deteted the the Failures.maxTimeOutExceeded is thrown.
 
 final func test_LOCATION_UNKNOWN_THROWN_AND_NOT_RESOLVED_ASYNC() async throws {
  
  addTeardownBlock {
   NMGeoLocationsProvider.locationStalenessInterval = .infinity //RECOVER DEFAULT SETTINGS...
  }
  
  //ARRANGE...
  NMGeoLocationsProvider.locationStalenessInterval = 0 // DETECT ALWAYS NEW GL...
  locationManagerMock.isLocationUnknown = true // MOCK GL UNKNOWN ERROR...
  
  //DO NOT SWITCH OFF LOCATION UNKNOWN ERROR STATE...
  //ACTION...
  do {
   
   let _ = try await createAllSnippetsWithGeoLocations()
  } catch NMGeoLocationsProvider.Failures.maxTimeOutExceeded(timeOut: let timeout){
   
   //ASSERT...
   XCTAssertTrue(timeout > NMGeoLocationsProvider.maxTimeOut,
                 "API MAX TIME-OUT MUST EXCEED PRESET [\(NMGeoLocationsProvider.maxTimeOut)]")
   
   
   let SUTS = try await snippetsFetchHelper()
   
   // ASSERT (IN CONTEXT QUEUE) THAT SNIPPETS HAVE BEEN CREATED WITHOUT GL FIELDS...
   await model.context.perform {
    
    let geoLocations = SUTS.compactMap{ $0.geoLocation }
    let addresses = SUTS.compactMap{ $0.location }
    
    XCTAssertTrue(SUTS.count == 6, "THE FETCH MUST HAVE ALL SNIPPET TYPES!")
    XCTAssertTrue(geoLocations.count == 0, "ALL SNIPPETS MUST HAVE GL FIELDS == NIL")
    XCTAssertTrue(addresses.count == 0, "ALL SNIPPETS MUST HAVE GEOCODED ADDRESS == NIL")
 
   }
   
   //SNIPPETS FILE STORAGE FOLDERS REMOVAL...
   try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup...
   
  } catch {
   XCTFail("UNEXPECTED ERROR THROWN DURING THIS TEST [\(error.localizedDescription)]!!!")
  }
 }
 
 
 final func test_GLS_AVAILABLE_WITH_INTERNET_WAITING_ASYNC() async throws {
  
  addTeardownBlock {
   NMLocationsGeocoderMock.enableNetwork()  //RECOVER DEFAULT SETTINGS...
   NMGeoLocationsProvider.locationStalenessInterval = .infinity
  }
  
  //ARRANGE...
  NMLocationsGeocoderMock.disableNetwork() //MOCK NO INTERNET ACCESS STATE...
  NMGeoLocationsProvider.locationStalenessInterval = 0 // ALL GL UNIQUE AND NOT STALE...
  
  //ACTION AGAIN AFTER DELAY...
  Task.detached{ 
   try await Task.sleep(timeInterval: .milliseconds(300))
   NMLocationsGeocoderMock.enableNetwork() // MOCK INTERNET ACCESSBALE STATE...
  }
  
  //ACTION...
  let SUTS = try await createAllSnippetsWithGeoLocations()
  
  //ASSERT (IN CONTEXT QUEUE)...
  await model.context.perform {
   let geoLocations = SUTS.compactMap{ $0.geoLocation }
   let addresses = SUTS.compactMap{ $0.location }
   
   XCTAssertEqual(geoLocations.count, SUTS.count)
   XCTAssertEqual(addresses.count, SUTS.count)
   XCTAssertTrue(Set(geoLocations).count == SUTS.count)
   XCTAssertTrue(Set(addresses).count == SUTS.count)
  }
  
   //SNIPPETS FILE STORAGE FOLDERS REMOVAL...
  try await storageRemoveHelperAsync(for: SUTS) //snippets folders async cleaup...
  
 }//func test_All_Snippets_crea
 
}
