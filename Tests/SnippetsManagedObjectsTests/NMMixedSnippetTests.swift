import XCTest
import NewsmanCoreDataModel

extension NMBaseSnippetsTests
{
 func test_NMMixedSnippet_creation()
 {
  let expectation = expectation(description: "Create new NMVideoSnippet expectation with file storage init")
  snippet_creation_helper(objectType: NMMixedSnippet.self, snippetType: .mixed){ photo in
   expectation.fulfill()
  }
  waitForExpectations(timeout: 0.01)

 }
 
 @available(iOS 15.0, *) @available(macOS 12.0.0, *)
 func test_NMMixedSnippet_creation_async() async throws
 {
  
  _ = try await snippet_creation_helper(objectType: NMMixedSnippet.self, snippetType: .mixed)

 }
 
 
}
