
import XCTest
import NewsmanCoreDataModel

@available(iOS 15.0, *) @available(macOS 12.0.0, *)
extension NMBaseSnippetsAsyncTests
{
 //MARK: Test that when all snippets are created they are correctly subscribed to the location fields updates.
 final func test_All_Snippets_Creation_And_Persistance_With_GEO_Locations_Updates_Available() async throws
 {
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
 
 //MARK: Test that when all snippets are created when location services unavailable the location fields are not mutated in MO.
 
 final func test_All_Snippets_creation_with_GEO_locations_Initially_UNAvailable() async throws
 {
  let SUTS = try await createAllSnippets(persisted: true)
  
  Self.locationManagerMock.disableLocationServices() // DISABLE GEO LOC SERVICE...
  
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
  
  Self.locationManagerMock.disableLocationServices()
  
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
  
  Self.locationManagerMock.enableLocationServicesWhenInUse()
  
  let resultWhenEnabled = XCTWaiter.wait(for: locExpWhenEnabled, timeout: 0.1)
  XCTAssertEqual(resultWhenEnabled, .completed)
  
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 //MARK: Test that when all snippets are created when location services initially available & internet is unavailable the latitude & longitude are received and location string is not mutated as soon as internet becomes available again.
 
 func test_All_Snippets_creation_with_GEO_locations_Available_AND_NO_Internet() async throws
 {
 
  let SUTS = try await createAllSnippets(persisted: true)
  
  NMLocationsGeocoderMock.disableNetwork()
  
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
  
  let resultWhenEnabled = XCTWaiter.wait(for: locExpWhenEnabled, timeout: 0.1)
  XCTAssertEqual(resultWhenEnabled, .completed)
  
  try await storageRemoveHelperAsync(for: SUTS)
 }// func test_All_Snippets_creation_with_GEO_locations_Available_AND_NO_Internet...
 
}//extension NMBaseSnippetsAsyncTests...
