
import XCTest
import NewsmanCoreDataModel

extension NMBaseSnippetsTests
{
 func test_NMPhotoSnippet_creation()
 {
  let expectation = expectation(description: "Create new NMPhotoSnippet expectation with file storage init")
  snippet_creation_helper(objectType: NMPhotoSnippet.self, snippetType: .photo){ photo in
   expectation.fulfill()
  }
  waitForExpectations(timeout: 0.01)

 }
 
 func test_NMPhotoSnippet_created_and_persisted()
 {
  let expectation = expectation(description: "Create persisted NMPhotoSnippet expectation with file storage init")
  Self.model.create(persist: true, objectType: NMPhotoSnippet.self) { result in
   
   switch result
   {
    case .success(let photoSnippet): self.sut = photoSnippet
    XCTAssertFalse(photoSnippet.objectID.isTemporaryID)
    XCTAssertNotNil(photoSnippet.id)
    case .failure(let error as NSError): XCTFail(error.localizedDescription)
   }
   expectation.fulfill()
   
  }
 
  waitForExpectations(timeout: 0.01)
 }
 
 @available(iOS 15.0, *) @available(macOS 12.0.0, *)
 func test_NMPhotoSnippet_creation_async() async throws
 {
  
  _ = try await snippet_creation_helper(objectType: NMPhotoSnippet.self, snippetType: .photo)

 }
 
 @available(iOS 15.0, *) @available(macOS 12.0.0, *)
 func test_NMPhotoSnippet_created_and_persisted_async() async throws
 {
  let photoSnippet = try await Self.model.create(persisted: true, objectType: NMPhotoSnippet.self)
  sut = photoSnippet
  XCTAssertFalse(photoSnippet.objectID.isTemporaryID)
  XCTAssertNotNil(photoSnippet.id)
 }
 
 @available(iOS 15.0, *) @available(macOS 12.0.0, *)
 func test_NMPhotoSnippet_invalidated_and_not_persisted_async() async throws
 {
  XCTAssertThrowsError({
   try await Self.model.create(persisted: true, objectType: NMPhotoSnippet.self)
   {
    $0.about = nil
   }
   
   
  }) { error in
   print (error.localizedDescription)
  }
 
 }
}
