import XCTest
import NewsmanCoreDataModel

@available(iOS 14.0, *)
protocol NMSnippetsTestsStorageRemovable where Self: XCTestCase {
 var model: NMCoreDataModel! { get set }
}

@available(iOS 14.0, *)
extension NMSnippetsTestsStorageRemovable{
 
 func storageRemoveHelperSync(for snippets: [NMBaseSnippet]) {
  
  let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  
  let withFileStorage = snippets.compactMap { $0 as? NMFileStorageManageable }
  
  let removeExpectations = withFileStorage.compactMap { snippet -> XCTestExpectation? in
   
   let removeExpectation = XCTestExpectation(description: "Remove Snippet Storage Expectation")
   
   guard let context = snippet.managedObjectContext else {
    XCTFail("Snippet Must Have MOC during file storage removal")
    return nil
   }
   
   snippet.removeFileStorage{ result in
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
       
      case .failure(let error):
       XCTFail(error.localizedDescription)
     }
    }
   }
   return removeExpectation
  }
  
  
  let result = XCTWaiter.wait(for: removeExpectations, timeout: 0.1)
  XCTAssertEqual(result, .completed)
  
 }//final func storageRemoveHelper with callback...
}

@available(iOS 15.0, macOS 12.0, *)
extension NMSnippetsTestsStorageRemovable{
 func storageRemoveHelperAsync(for snippets: [NMBaseSnippet]) async throws {
  let withFileStorage = snippets.compactMap{ $0 as? NMFileStorageManageable }
  let ids = try await withThrowingTaskGroup(of: NMFileStorageManageable.self,
                                            returning: [UUID].self) { group in
   withFileStorage.forEach{ snippet in
    group.addTask{
     try await snippet.removeFileStorage()
     return snippet
    }
   }
   return try await group.compactMap{ snippet in // make sure we get snippet id in proper MOC!!!
    await snippet.managedObjectContext?.perform { snippet.id }
   }.reduce(into: []) { $0.append($1)}
  }
  
  XCTAssertEqual(withFileStorage.count, ids.count)
  
  let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  let paths = ids.map{ docsFolder.appendingPathComponent($0.uuidString).path }
  
  XCTAssertTrue(paths.allSatisfy{!FileManager.default.fileExists(atPath: $0)})
  
 }//final func storageRemoveHelperAsync...
}
