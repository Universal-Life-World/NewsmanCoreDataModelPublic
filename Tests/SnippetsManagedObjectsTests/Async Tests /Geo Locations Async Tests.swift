
import XCTest
import NewsmanCoreDataModel

@available(iOS 15.0, macOS 12.0, *)
class NMBaseSnippetsGeoLocationCombineAPITests: NMBaseSnippetsAsyncTests
{
 //MARK: Test that when all snippets are created they are correctly subscribed to the location fields updates.
 final func test_All_Snippets_Creation_And_Persistance_With_GEO_Locations_Updates_Available() async throws {
  let SUTS = try await createAllSnippets(persisted: true)
  
  let locExp = SUTS.map{ (SUT: NMBaseSnippet) -> [ XCTKVOExpectation ] in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: SUT)
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: SUT)
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: SUT)
   
   SUT.updateGeoLocations(with: NMLocationsGeocoderMock.self, using: NMNetworkWaiterMock.self)
   
   return [ latExp, lonExp , locExp ] }.flatMap{$0}
  
  let result = XCTWaiter.wait(for: locExp, timeout: 0.1)
  XCTAssertEqual(result, .completed)
  
  try await storageRemoveHelperAsync(for: SUTS)
  
 }//final func test_All_Snippets_Creation_And_Persistance_With_GEO_Locations_Updates_Available...
 
 
 //MARK: Test that when all snippets are created they are correctly subscribed to the location fields updates and get the same cached location within the Location Manager Staleness Interval.
 final func test_All_Snippets_Creation_And_Persistance_With_CACHED_GEO_Locations_Available() async throws
 {
  //LOCATIONS ARE ALWAYS NOT STALE! USE CACHED ONES!
  let SUTS = try await createAllSnippets(persisted: true)
  
  let locExp = SUTS.map{ (SUT: NMBaseSnippet) -> [ XCTKVOExpectation ] in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: SUT)
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: SUT)
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: SUT)
   
   SUT.updateGeoLocations(with: NMLocationsGeocoderMock.self, using: NMNetworkWaiterMock.self)
   
   return [ latExp, lonExp , locExp ] }.flatMap{ $0 }
  
  let result = XCTWaiter.wait(for: locExp, timeout: 0.01)
  XCTAssertEqual(result, .completed)
  let uniqueLocations = Set(SUTS.compactMap{$0.geoLocation})
  XCTAssertTrue(uniqueLocations.count == 1) // ALL THE SAME CACHED ONES!
  let addresses = SUTS.compactMap{ $0.location }
  XCTAssertTrue(Set(addresses).count == 1)
  
  try await storageRemoveHelperAsync(for: SUTS)
  
 }//final func test_All_Snippets_Creation_And_Persistance_With_GEO_Locations_Updates_Available...
 
 
//MARK: Test that when all snippets are created they are correctly subscribed to the location fields updates and get the different values. Location Manager Staleness Interval == 0!
 final func test_All_Snippets_Creation_And_Persistance_With_GEO_Locations_STALENESS_and_caching() async throws
 {
   //LOCATIONS ARE ALWAYS STALE! USE NEW ONES!
  NMGeoLocationsProvider.locationStalenessInterval = 0
  
  let SUTS = try await createAllSnippets(persisted: true)
  
  
  let locExp = SUTS.map{ (SUT: NMBaseSnippet) -> [ XCTKVOExpectation ] in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: SUT)
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: SUT)
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: SUT)
   
   SUT.updateGeoLocations(with: NMLocationsGeocoderMock.self, using: NMNetworkWaiterMock.self)
   
   return [ latExp, lonExp , locExp ] }.flatMap{ $0 }
  
  let result = XCTWaiter.wait(for: locExp, timeout: 0.1)
  XCTAssertEqual(result, .completed)
  let suts_count = SUTS.count
  let uniqueLocations = Set(SUTS.compactMap{$0.geoLocation})
  XCTAssertTrue(uniqueLocations.count == suts_count) // ALL UNIQUE AS THE STALENESS == 0!
  let addresses = SUTS.compactMap{ $0.location }
  XCTAssertTrue(Set(addresses).count == suts_count)
  
  
  try await storageRemoveHelperAsync(for: SUTS)
  
 }//final func test_All_Snippets_Creation_And_Persistance_With_GEO_Locations_Updates_Available...
 
 
 //MARK: Test that when all snippets are created when location services unavailable the location fields are not mutated in MO.
 
 final func test_All_Snippets_creation_with_GEO_locations_Initially_UNAvailable() async throws
 {
  let SUTS = try await createAllSnippets(persisted: true)
  
  locationManagerMock.disableLocationServices() // DISABLE GEO LOC SERVICE...
  
  let locExp = SUTS.map{ (SUT: NMBaseSnippet) -> [ XCTKVOExpectation ] in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: SUT)
   latExp.isInverted = true
   
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: SUT)
   lonExp.isInverted = true
   
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: SUT)
   locExp.isInverted = true
   
   SUT.updateGeoLocations(with: NMLocationsGeocoderMock.self, using: NMNetworkWaiterMock.self)
   
   return [ latExp, lonExp , locExp ] }.flatMap{$0}
  
  let result = XCTWaiter.wait(for: locExp, timeout: 0.1)
  XCTAssertEqual(result, .completed)
  
  try await storageRemoveHelperAsync(for: SUTS)
  
 }//final func test_All_Snippets_creation_with_GEO_locations_Initially_UNAvailable
 
 //MARK: Test that when all snippets are created when location services initially unavailable the location fields are not mutated in MO and the mutated if services are activated.
 
 func test_snippet_creation_with_geo_locations_UNAvailable_AND_THEN_Available_ASYNC() async throws
 {
  
  let SUTS = try await createAllSnippets(persisted: true)
  
  locationManagerMock.disableLocationServices()
  
  let locExpDisabled = SUTS.map{ (sut: NMBaseSnippet) -> [ XCTKVOExpectation]  in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: sut)
   latExp.isInverted = true
   
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: sut)
   lonExp.isInverted = true
   
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: sut)
   locExp.isInverted = true
   
   sut.updateGeoLocations(with: NMLocationsGeocoderMock.self, using: NMNetworkWaiterMock.self)
   
   return [ latExp, lonExp , locExp ] }.flatMap{$0}
  
  let resultDisabled = XCTWaiter.wait(for: locExpDisabled, timeout: 0.1)
  XCTAssertEqual(resultDisabled, .completed)
  
  
  let locExpWhenEnabled = SUTS.map{ (sut: NMBaseSnippet) -> [ XCTKVOExpectation ] in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: sut)
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: sut)
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: sut)
   
   return [ latExp, lonExp , locExp ] }.flatMap{$0}
  
  locationManagerMock.enableLocationServicesWhenInUse()
  
  let resultWhenEnabled = XCTWaiter.wait(for: locExpWhenEnabled, timeout: 0.1)
  XCTAssertEqual(resultWhenEnabled, .completed)
  
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 //MARK: Test that when all snippets are created when location services initially available & internet is unavailable the latitude & longitude are received and location string is not mutated as soon as internet becomes available again.
 
 func test_All_Snippets_creation_with_GEO_locations_Available_AND_NO_Internet() async throws {
  
  NMGeoLocationsProvider.locationStalenessInterval = 0
  NMLocationsGeocoderMock.disableNetwork()
  
  let SUTS = try await createAllSnippets(persisted: true)
  
  let locExpDisabled = SUTS.map{ (sut: NMBaseSnippet) -> [ XCTKVOExpectation ]  in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: sut)
   //latExp.isInverted = true
   
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: sut)
   //lonExp.isInverted = true
   
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: sut)
   locExp.isInverted = true
   
   sut.updateGeoLocations(with: NMLocationsGeocoderMock.self, using: NMNetworkWaiterMock.self)
   
   return [ latExp, lonExp , locExp ] }.flatMap{$0}
  
  let resultDisabled = XCTWaiter.wait(for: locExpDisabled, timeout: 0.1)
  
  XCTAssertEqual(resultDisabled, .completed)
 
  let locExpWhenEnabled = SUTS.map{ (sut: NMBaseSnippet) -> [ XCTKVOExpectation ] in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: sut)
   latExp.isInverted = true
   
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: sut)
   lonExp.isInverted = true
   
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: sut)
   
   return [ latExp, lonExp , locExp ] }.flatMap{$0}
  
  NMLocationsGeocoderMock.enableNetwork()
  
  let resultWhenEnabled = XCTWaiter.wait(for: locExpWhenEnabled, timeout: 1)
  XCTAssertEqual(resultWhenEnabled, .completed)
  
  try await storageRemoveHelperAsync(for: SUTS)
 }// func test_All_Snippets_creation_with_GEO_locations_Available_AND_NO_Internet...
 
 
 //MARK: Test that when all snippets are created when location services initially available & internet is available but location unknown error occurs.
 
 func test_All_Snippets_creation_with_GEO_locations_Available_AND_Location_Unknown() async throws
 {
  locationManagerMock.isLocationUnknown = true
  
  let SUTS = try await createAllSnippets(persisted: true)
  
  let locExp = SUTS.map{ (SUT: NMBaseSnippet) -> [ XCTKVOExpectation ] in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: SUT)
   latExp.isInverted = true
   
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: SUT)
   lonExp.isInverted = true
   
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: SUT)
   locExp.isInverted = true
   
   SUT.updateGeoLocations(with: NMLocationsGeocoderMock.self, using: NMNetworkWaiterMock.self)
   
   return [ latExp, lonExp , locExp ] }.flatMap{ $0 }
  
  let result = XCTWaiter.wait(for: locExp, timeout: 0.1)
  XCTAssertEqual(result, .completed)
  
  try await storageRemoveHelperAsync(for: SUTS)
 }// func test_All_Snippets_creation_with_GEO_locations_Available_AND_Location_Unknown()
 
 //MARK: Test that when all snippets are created when location services initially available & internet is available but location unknown error occurs.
 func test_All_Snippets_creation_with_GEO_locations_Available_AND_Location_Unknown_AND_then_Detected() async throws
 {
  
  locationManagerMock.isLocationUnknown = true
  
  let SUTS = try await createAllSnippets(persisted: true)
 
  let locExp = SUTS.map{ (SUT: NMBaseSnippet) -> [ XCTKVOExpectation ] in
   
   let latExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.latitude),  object: SUT)
   //latExp.isInverted = true
   
   let lonExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.longitude), object: SUT)
   //lonExp.isInverted = true
   
   let locExp =  XCTKVOExpectation(keyPath: #keyPath(NMBaseSnippet.location),  object: SUT)
   // locExp.isInverted = true
   
   SUT.updateGeoLocations(with: NMLocationsGeocoderMock.self, using: NMNetworkWaiterMock.self)
   
   return [ latExp, lonExp , locExp ] }.flatMap{ $0 }
  
  Task.detached(priority: TaskPriority.high){ [ self ] in
   
   try await Task.sleep(timeInterval: .random(in: .nanoseconds(50)..<(.milliseconds(100))))
   
   locationManagerMock.isLocationUnknown = false
  }
  
  let waiter = XCTWaiter()
  waiter.wait(for: locExp, timeout: 0.5)

  XCTAssertFalse(waiter.fulfilledExpectations.isEmpty)
  
  try await storageRemoveHelperAsync(for: SUTS)
 }// func test_All_Snippets_creation_with_GEO_locations_Available_AND_Location_Unknown()
 
 


 
}//extension NMBaseSnippetsAsyncTests...

