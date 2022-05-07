import XCTest
import NewsmanCoreDataModel
import CoreLocation

@available(iOS 14.0, *)
extension NMBaseSnippetsCombineAPITests {
 
 func test_Snippets_CREATED_correctly_without_persistance_using_Combine_API() {
  
  //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = false
  var SUTS = [NMBaseSnippet]()
  
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   
   let expectation = XCTestExpectation(description: "All Snippets Types Creation with Combine")
   
   switch snippetType {
    case .base:
     snippet_creation_with_checkup_helper(objectType: NMBaseSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType){
      SUTS.append($0)
      expectation.fulfill()
     }
    case .photo:
     snippet_creation_with_checkup_helper(objectType: NMPhotoSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .audio:
     snippet_creation_with_checkup_helper(objectType: NMAudioSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .video:
     snippet_creation_with_checkup_helper(objectType: NMVideoSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .text:
     snippet_creation_with_checkup_helper(objectType: NMTextSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .mixed:
     snippet_creation_with_checkup_helper(objectType: NMMixedSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
   }
   
   return expectation
  }
  
  //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
  //ASSERT...
  XCTAssertEqual(result, .completed)
  XCTAssertEqual(SUTS.count, SUTS_COUNT)
  
  let contexts = SUTS.compactMap(\.managedObjectContext)
  XCTAssertEqual(contexts.count, SUTS_COUNT)
  XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
  XCTAssertEqual(Set(contexts).first, model.context) // Assert that snippets' MOC is model main MOC!
  
  //FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
  
  
 }
 
 func test_Snippets_CREATED_correctly_AND_PERSISTED_IN_MAIN_CONTEXT_using_Combine_API() {
  
  //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true
  var SUTS = [NMBaseSnippet]()
  
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   
   let expectation = XCTestExpectation(description: "All Snippets Types Creation with Combine")
   
   switch snippetType {
    case .base:
     snippet_creation_with_checkup_helper(objectType: NMBaseSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .photo:
     snippet_creation_with_checkup_helper(objectType: NMPhotoSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .audio:
     snippet_creation_with_checkup_helper(objectType: NMAudioSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .video:
     snippet_creation_with_checkup_helper(objectType: NMVideoSnippet.self,
                                          persist:PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .text:
     snippet_creation_with_checkup_helper(objectType: NMTextSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .mixed:
     snippet_creation_with_checkup_helper(objectType: NMMixedSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
   }
   
   return expectation
  }
  
  //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
  //ASSERT...
  XCTAssertEqual(result, .completed)
  XCTAssertEqual(SUTS.count, SUTS_COUNT)
  
  let contexts = SUTS.compactMap(\.managedObjectContext)
  XCTAssertEqual(contexts.count, SUTS_COUNT)
  XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
  XCTAssertEqual(Set(contexts).first, model.context) // Assert that snippets' MOC is model main MOC!
  
  //FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
  
  
 }
 
 func test_Snippets_CREATED_correctly_AND_PERSISTED_IN_MAIN_CONTEXT_with_ENTITY_DESCRIPTIONS_using_Combine_API() {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true
  var SUTS = [NMBaseSnippet]()
  let entities = [NMBaseSnippet.self, NMTextSnippet.self, NMPhotoSnippet.self,
                  NMVideoSnippet.self, NMAudioSnippet.self, NMMixedSnippet.self]
  
  let snippetTypes: [NMBaseSnippet.SnippetType] = [.base, .text, .photo, .video, .audio, .mixed]
  
  
  let expectations = zip(entities, snippetTypes).map{ (entity, snippetType) -> XCTestExpectation in
   
   let expectation = XCTestExpectation(description: "All Snippets Types Creation with Combine")
   
   snippet_creation_with_checkup_helper(entityType: entity.self,
                                        persist: PERSISTED,
                                        snippetType: snippetType) {
    SUTS.append($0 as! NMBaseSnippet)
    expectation.fulfill()
   }
   
   return expectation
  }
  
   //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
   //ASSERT...
  XCTAssertEqual(result, .completed)
  XCTAssertEqual(SUTS.count, SUTS_COUNT)
  
  let contexts = SUTS.compactMap(\.managedObjectContext)
  XCTAssertEqual(contexts.count, SUTS_COUNT)
  XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
  XCTAssertEqual(Set(contexts).first, model.context) // Assert that snippets' MOC is model main MOC!
  
   //FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
  
  
 }
 
 func test_Snippets_CREATED_correctly_AND_PERSISTED_IN_Background_MOC_using_Combine_API() {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true
  var SUTS = [NMBaseSnippet]()
  
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   
   let expectation = XCTestExpectation(description: "All Snippets Types Creation in BG MOC with Combine")
   
   switch snippetType {
    case .base:
     snippet_background_creation_with_checkup_helper(objectType: NMBaseSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .photo:
     snippet_background_creation_with_checkup_helper(objectType: NMPhotoSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .audio:
     snippet_background_creation_with_checkup_helper(objectType: NMAudioSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .video:
     snippet_background_creation_with_checkup_helper(objectType: NMVideoSnippet.self,
                                                     persist:PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .text:
     snippet_background_creation_with_checkup_helper(objectType: NMTextSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .mixed:
     snippet_background_creation_with_checkup_helper(objectType: NMMixedSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
   }
   
   return expectation
  }
  
   //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
   //ASSERT...
  XCTAssertEqual(result, .completed)
  XCTAssertEqual(SUTS.count, SUTS_COUNT)
  
  let contexts = SUTS.compactMap(\.managedObjectContext)
  XCTAssertEqual(contexts.count, SUTS_COUNT)
  XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
  XCTAssertEqual(Set(contexts).first, model.context) // Assert that snippets' MOC is model main MOC!
  
   //FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
  
  
 }
 
 func test_Snippets_deleted_when_modification_block_throws_using_ENTITY_DESCRIPTION() {
  
  //ARRANGE...
  
  let entities = [NMBaseSnippet.self, NMTextSnippet.self, NMPhotoSnippet.self,
                  NMVideoSnippet.self, NMAudioSnippet.self, NMMixedSnippet.self]
  
  let snippetTypes: [NMBaseSnippet.SnippetType] = [.base, .text, .photo, .video, .audio, .mixed]
  
  
  let expectations = zip(entities, snippetTypes).map{ (entity, snippetType) -> XCTestExpectation in
   
   let expectation = XCTestExpectation(description: "All Snippets Types Throwing Modification")
   
   snippet_throwing_modification_helper(entityType: entity.self,
                                        snippetType: snippetType) { expectation.fulfill() }
   
   return expectation
  }
  
 
  
  //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
  //ASSERT...
  XCTAssertEqual(result, .completed)
 }
 
 func test_Snippets_deleted_when_modification_block_throws_created() {
  
   //ARRANGE...
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   let expectation = XCTestExpectation(description: "All Snippets Types Throwing Modification")
   switch snippetType
   {
    case .base:
     snippet_throwing_modification_helper(objectType: NMBaseSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .photo:
     snippet_throwing_modification_helper(objectType: NMPhotoSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .audio:
     snippet_throwing_modification_helper(objectType: NMAudioSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .video:
     snippet_throwing_modification_helper(objectType: NMVideoSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .text:
     snippet_throwing_modification_helper(objectType: NMTextSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .mixed:
     snippet_throwing_modification_helper(objectType: NMMixedSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
   }
   
   return expectation
  }
  
   //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
   //ASSERT...
  XCTAssertEqual(result, .completed)
 }
 
 final func test_HOMOGENEOUS_Snippets_CREATED_IN_BACKGROUND_MOC_Correctly_with_NO_Persistance(){
  
   //ARRANGE...
  let SUTS_COUNT = 10
  let nameTag = "Random Named"
  let PERSISTED = false // NO PERSISTANCE!
  let modelMainContext = model.context // GET MAIN MODEL CONTEXT!
  let expectation = XCTestExpectation(description: "Homogeneous Snippets Creation in BG MOC with Combine")
  
   //ACTION...
  model.backgroundCreate(persist: PERSISTED,
                         objectType: NMBaseSnippet.self,
                         objectCount: SUTS_COUNT) { SUTS in
   XCTAssertTrue(SUTS.count == SUTS_COUNT)
   SUTS.randomElement()?.nameTag = nameTag
  }.sink { result in
   switch result {
    case .finished: break
    case .failure(let error):
     XCTFail(error.localizedDescription)
   }
   
  } receiveValue: { SUTS in
    //ASSERT...
   modelMainContext.perform {
    XCTAssertTrue(SUTS.allSatisfy{$0.objectID.isTemporaryID})
    let contexts = Set(SUTS.compactMap(\.managedObjectContext))
    XCTAssertTrue(contexts.count == 1)
    XCTAssertTrue(contexts.first!.concurrencyType == .mainQueueConcurrencyType)
    XCTAssertTrue(contexts.first! == modelMainContext)
    XCTAssertEqual(SUTS.compactMap{ $0.id }.count, 0) //no data in row PSC row cache yet!
    XCTAssertFalse(SUTS.contains{ $0.nameTag == nameTag }) //no data in row PSC row cache yet!
                                                      
    self.storageRemoveHelperSync(for: SUTS) //FILE STORAGE CLEAN-UP...
    expectation.fulfill()
   }
   
  }.store(in: &disposeBag)
  
  let result = XCTWaiter.wait(for: [expectation], timeout: 0.1)
  
  //ASSERT EXPECTATION...
  XCTAssertEqual(result, .completed)
  
 }
 
 final func test_HOMOGENEOUS_Snippets_CREATED_IN_BACKGROUND_MOC_Correctly_with_Persistance(){
  
   //ARRANGE...
  let SUTS_COUNT = 10
  let nameTag = "Random Named"
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = model.context // GET MAIN MODEL CONTEXT!
  let expectation = XCTestExpectation(description: "Homogeneous Snippets Creation in BG MOC with Combine")
  
   //ACTION...
  model.backgroundCreate(persist: PERSISTED,
                         objectType: NMBaseSnippet.self,
                         objectCount: SUTS_COUNT) { SUTS in
   XCTAssertTrue(SUTS.count == SUTS_COUNT)
   SUTS.randomElement()?.nameTag = nameTag
  }.sink { result in
   switch result {
    case .finished: break
    case .failure(let error):
     XCTFail(error.localizedDescription)
   }
   
  } receiveValue: { SUTS in
   
   modelMainContext.perform {
    XCTAssertFalse(SUTS.allSatisfy{$0.objectID.isTemporaryID})
    let contexts = Set(SUTS.compactMap(\.managedObjectContext))
    XCTAssertTrue(contexts.count == 1)
    XCTAssertTrue(contexts.first!.concurrencyType == .mainQueueConcurrencyType)
    XCTAssertTrue(contexts.first! == modelMainContext)
    XCTAssertEqual(SUTS.compactMap{ $0.id }.count, SUTS_COUNT) //now data in PSC row cache!
    XCTAssertTrue(SUTS.contains{ $0.nameTag == nameTag }) //now data in PSC row cache!
    
    self.storageRemoveHelperSync(for: SUTS) //FILE STORAGE CLEAN-UP...
    expectation.fulfill()
   }
   
  }.store(in: &disposeBag)
  
  let result = XCTWaiter.wait(for: [expectation], timeout: 0.1)
  
  //ASSERT EXPECTATION...
  XCTAssertEqual(result, .completed)
  
 }
 
 
 
}
