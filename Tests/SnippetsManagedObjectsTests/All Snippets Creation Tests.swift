
import XCTest
import NewsmanCoreDataModel

extension NMBaseSnippetsTests
{

 func test_Snippets_CREATED_correctly_without_persistance()
 {
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   let expectation = XCTestExpectation(description: "All Snippets Types Creation")
   switch snippetType
   {
    case .base:
     snippet_creation_helper(objectType: NMBaseSnippet.self, snippetType: snippetType)
     { [ unowned self ] in
      suts.append($0)
      expectation.fulfill()
     }
    case .photo:
     snippet_creation_helper(objectType: NMPhotoSnippet.self, snippetType: snippetType)
     { [ unowned self ] in
      suts.append($0)
      expectation.fulfill()
     }
    case .audio:
     snippet_creation_helper(objectType: NMAudioSnippet.self, snippetType: snippetType)
     { [ unowned self ] in
      suts.append($0)
      expectation.fulfill()
     }
    case .video:
     snippet_creation_helper(objectType: NMVideoSnippet.self, snippetType: snippetType)
     { [ unowned self ] in
      suts.append($0)
      expectation.fulfill()
     }
    case .text:
     snippet_creation_helper(objectType: NMTextSnippet.self, snippetType: snippetType)
     { [ unowned self ] in
      suts.append($0)
      expectation.fulfill()
     }
    case .mixed:
     snippet_creation_helper(objectType: NMMixedSnippet.self, snippetType: snippetType)
     { [ unowned self ] in
      suts.append($0)
      expectation.fulfill()
     }
    }
    
   return expectation
  }
 
  let result = XCTWaiter.wait(for: expectations, timeout: 0.01)
  XCTAssertEqual(result, .completed)
 }
 
 
 final func snippet_throwing_modification_helper<T: NMBaseSnippet>(objectType:T.Type,
                                                                   snippetType: NMBaseSnippet.SnippetType,
                                                                   handler: @escaping () -> () )
 {
  Self.model.create(persist: true, objectType: T.self) {
    throw SnippetTestError.failed(snippet: $0)
   } handler: { result in
     switch result {
      case .success(let photoSnippet):
       XCTFail("Snippet \(photoSnippet) must be removed from context!")

      case .failure(let error as SnippetTestError<T>):
       guard case let .failed(snippet) = error else {
        XCTFail("UNKNOWN TEST ERROR CASE \(error.localizedDescription)")
        return
       }
       XCTAssertTrue(snippet.objectID.isTemporaryID)
       XCTAssertTrue(snippet.hasChanges)
       XCTAssertTrue(snippet.isDeleted)
      
       if let path = (snippet as? NMFileStorageManageable)?.url?.path {
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
       }
      
      default:
       XCTFail("UNEXPECTED TEST RESULT \(result)")
     }
     handler()
   }
 }
 
 func test_Snippets_deleted_when_modification_block_throws()
 {
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
 
  let result = XCTWaiter.wait(for: expectations, timeout: 0.01)
  XCTAssertEqual(result, .completed)
 }
 
 
}


//MARK: ASYNC TESTING...

@available(iOS 15.0, *) @available(macOS 12.0.0, *)
extension NMBaseSnippetsTests
{
 
 func storageRemoveHelperAsync(_ snippets: [NMBaseSnippet]) async throws
 {
  let ids = try await withThrowingTaskGroup(of: NMFileStorageManageable.self, returning: [UUID].self)
  { group in
   snippets.compactMap{$0 as? NMFileStorageManageable}.forEach{ snippet in
    group.addTask{
     try await snippet.removeFileStorage()
     return snippet
    }
   }
   return try await group.reduce(into: []) {$0.append($1.id)}.compactMap{$0}
  }
  
  XCTAssertEqual(snippets.count - 1, ids.count)
  
  let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  let paths = ids.map{ docsFolder.appendingPathComponent($0.uuidString).path }
  
  XCTAssertTrue(paths.allSatisfy{!FileManager.default.fileExists(atPath: $0)})
 }
 
 
 func test_Snippets_CREATED_correctly_NO_Persistance_ASYNC() async throws
 {
  async let s1 = snippet_creation_helper(objectType: NMBaseSnippet.self, snippetType: .base)
  async let s2 = snippet_creation_helper(objectType: NMPhotoSnippet.self, snippetType: .photo)
  async let s3 = snippet_creation_helper(objectType: NMAudioSnippet.self, snippetType: .audio)
  async let s4 = snippet_creation_helper(objectType: NMTextSnippet.self, snippetType: .text)
  async let s5 = snippet_creation_helper(objectType: NMVideoSnippet.self, snippetType: .video)
  async let s6 = snippet_creation_helper(objectType: NMMixedSnippet.self, snippetType: .mixed)
  
  let snippets = try await [s1,s2,s3,s4,s5,s6]
  
  XCTAssertEqual(snippets.compactMap{$0.id}.count, 6)
  
  try await storageRemoveHelperAsync(snippets)
 
 }
 
 func snippetsPersistanceCheckHelperAsync(_ snippets: [NMBaseSnippet]) async throws
 {
  let modelContext = Self.model.context
  
  try await modelContext.perform {
   for snippet in snippets
   {
    XCTAssertNotNil(snippet.id)
    let snippetContext = try XCTUnwrap (snippet.managedObjectContext)
    XCTAssertFalse(snippet.objectID.isTemporaryID)
    XCTAssertEqual(snippetContext, modelContext)
    XCTAssertFalse(snippet.hasChanges)
    let type = try XCTUnwrap (snippet.type)
    let pred = NSPredicate(format: "SELF == %@", snippet)
    switch type {
     case .base:
      let fr = NSFetchRequest<NMBaseSnippet>(entityName: "NMBaseSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
     case .photo:
      let fr = NSFetchRequest<NMPhotoSnippet>(entityName: "NMPhotoSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
     case .video:
      let fr = NSFetchRequest<NMVideoSnippet>(entityName: "NMVideoSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
     case .audio:
      let fr = NSFetchRequest<NMAudioSnippet>(entityName: "NMAudioSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
     case .text:
      let fr = NSFetchRequest<NMTextSnippet>(entityName: "NMTextSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
     case .mixed:
      let fr = NSFetchRequest<NMMixedSnippet>(entityName: "NMMixedSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
    }
   }
  }
  
 }
 
 func test_Snippets_CREATED_correctly_WITH_Persistance_ASYNC() async throws
 {
  async let s1 = Self.model.create(persist: true, objectType: NMBaseSnippet.self)
  async let s2 = Self.model.create(persist: true, objectType: NMPhotoSnippet.self)
  async let s3 = Self.model.create(persist: true, objectType: NMAudioSnippet.self)
  async let s4 = Self.model.create(persist: true, objectType: NMTextSnippet.self)
  async let s5 = Self.model.create(persist: true, objectType: NMVideoSnippet.self)
  async let s6 = Self.model.create(persist: true, objectType: NMMixedSnippet.self)
  
  let snippets = try await [s1,s2,s3,s4,s5,s6]
  
  try await snippetsPersistanceCheckHelperAsync(snippets)
  try await storageRemoveHelperAsync(snippets)
  
 }
}
