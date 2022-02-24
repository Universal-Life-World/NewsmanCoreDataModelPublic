import XCTest
import NewsmanCoreDataModel

@available(iOS 14.0, *)
protocol NMSnippetsTestsStorageRemovable where Self: XCTestCase {
 var model: NMCoreDataModel! { get set }
}

@available(iOS 14.0, *)
extension NMSnippetsTestsStorageRemovable{
 
 func storageRemoveHelperSync(for snippets: [NMBaseSnippet]) {
  let context = model.context
  
  let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  
  let removeExpectations = snippets.compactMap { snippet -> XCTestExpectation? in
   
   let removeExpectation = XCTestExpectation(description: "Remove Snippet Storage Expectation")
   
   guard let fileStorageProvider = snippet as? NMFileStorageManageable else { return nil }
   
   fileStorageProvider.removeFileStorage{ result in
    context.perform {
     switch result {
      case .success():
       guard let snippet_id = snippet.id else {
        XCTFail("Snippet Must Have ID after file storage removal")
        break
       }
       
       let path = docsFolder.appendingPathComponent(snippet_id.uuidString).path
       XCTAssertFalse(FileManager.default.fileExists(atPath: path))
       removeExpectation.fulfill()
       
      case .failure(let error):  XCTFail(error.localizedDescription)
     }
    }
   }
   return removeExpectation
  }
  
  XCTAssertEqual(snippets.count - 1,  removeExpectations.count)
   // Minus 1 as the NMBaseSnippet has no file storage per se!
  
  let result = XCTWaiter.wait(for: removeExpectations, timeout: 0.1)
  XCTAssertEqual(result, .completed)
  
 }//final func storageRemoveHelper with callback...
}

@available(iOS 15.0, *)
@available(macOS 12.0, *)
extension NMSnippetsTestsStorageRemovable{
 func storageRemoveHelperAsync(for snippets: [NMBaseSnippet]) async throws {
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
  
  XCTAssertEqual(snippets.count - 1, ids.count) // Minus 1 as the NMBaseSnippet has no file storage per se!
  
  let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  let paths = ids.map{ docsFolder.appendingPathComponent($0.uuidString).path }
  
  XCTAssertTrue(paths.allSatisfy{!FileManager.default.fileExists(atPath: $0)})
  
 }//final func storageRemoveHelperAsync...
}
