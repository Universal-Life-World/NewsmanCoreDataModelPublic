import NewsmanCoreDataModel
import XCTest

//MARK: Test when Photo Folder is deleted with recovery with its content it is recovered properly after undo action with proper undo/redo states. The test uses generated Folder DTO to check for recovered contents equality.


@available(iOS 15.0, macOS 12.0, *)
extension NMSnippetsManipulationAsyncTests {
 
 final func test_when_FOLDER_DELETED_with_recovery_it_is_recovered_properly_from_JSON_data() async throws {
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
   //CREATE SOURCE SNIPPET...
  let SUT_SNIPPET = try await model.create(persist: PERSISTED,
                                           objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SUT_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   $0.colorFlag = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT = try await SUT_SNIPPET.createSingle(persist: PERSISTED,
                                               in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   $0.colorFlag = #colorLiteral(red: 0.8793543782, green: 0.2253175287, blue: 0.1012533999, alpha: 1)
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
   //ASSERT BEFORE DELETE WITH RECOVERY...
  
  await XCTAssertNotNilAsync ( try await SUT_SNIPPET.snippetID )
  await XCTAssertNotNilAsync ( try await SUT_FOLDER.folderID )
  await XCTAssertNotNilAsync ( try await SUT.elementID )
  await XCTAssertEqualAsync  ( try await SUT_FOLDER.snippetAsync, SUT_SNIPPET)
  await XCTAssertEqualAsync  ( try await SUT.snippetAsync, SUT_SNIPPET)
  await XCTAssertEqualAsync  ( try await SUT.folderAsync, SUT_FOLDER)
  await XCTAssertEqualAsync  ( try await SUT_FOLDER.folderedElementsAsync, [SUT])
  await XCTAssertEqualAsync  ( try await SUT_SNIPPET.folderedContentElementsAsync, [SUT])
  await XCTAssertEqualAsync  ( try await SUT_SNIPPET.unfolderedContentElementsAsync, [])
  
  let SUT_ID = try await SUT.elementID
  let SUT_FOLDER_ID = try await SUT_FOLDER.folderID
  let undoManager = SUT_FOLDER.undoManager //fix SUT Folder UM bedore delete
  
   //ACTION - DELETE WITH RECOVERY!
   //try await withGlobalUndoSession {
  try await SUT_FOLDER.deleteRecoverably(persist: PERSISTED)
   //}
  
  
  try await beforeUndoStatesAssertions(undoManager: undoManager, sessionCount: 1)
  
  
  await XCTAssertNotNilAsync        (try await SUT_SNIPPET.snippetID)
  await XCTAssertTrueAsync          (try await SUT_SNIPPET.foldersAsync.isEmpty)
  await XCTAssertTrueAsync          (try await SUT_SNIPPET.singleContentElementsAsync.isEmpty)
  
  await XCTAssertThrowsErrorAsync   (try await SUT_FOLDER.folderID)
  await XCTAssertThrowsErrorAsync   (try await SUT.elementID)
  await XCTAssertThrowsErrorAsync   (try await SUT_FOLDER.snippetAsync)
  await XCTAssertThrowsErrorAsync   (try await SUT.snippetAsync)
  await XCTAssertThrowsErrorAsync   (try await SUT_FOLDER.folderedElementsAsync.isEmpty)
  
   //UNDO TO RECOVER DELETED FOLDER...
  try await undoManager.undo()
  
   //ASSERT AFTER UNDO...
  
  try await undoRedoStatesAssertions(undoManager: undoManager,
                                     sessionCount: 1,
                                     executedUndoCount: 1,
                                     executedRedoCount: 0)
  
  
  let RECOVERED_SUT_FOLDER = try await XCTUnwrapAsync(await NMPhotoFolder.existingFolder(with: SUT_FOLDER_ID,
                                                                                         in: modelMainContext))
  
  let RECOVERED_SUT = try await XCTUnwrapAsync(await RECOVERED_SUT_FOLDER.folderedElementsAsync.first)
  
  XCTAssertEqual(undoManager, RECOVERED_SUT_FOLDER.undoManager)
  
  await modelMainContext.perform {
   XCTAssertNotNil(RECOVERED_SUT_FOLDER)
   XCTAssertNotNil(RECOVERED_SUT)
   XCTAssertEqual(SUT_SNIPPET.folders.first, RECOVERED_SUT_FOLDER)
   XCTAssertEqual(SUT_SNIPPET.singleContentElements.first, RECOVERED_SUT)
   XCTAssertEqual(RECOVERED_SUT_FOLDER.folderedElements.count, 1)
   XCTAssertEqual(RECOVERED_SUT_FOLDER.folderedElements.first!.id, SUT_ID)
   XCTAssertEqual(RECOVERED_SUT_FOLDER.snippet, SUT_SNIPPET)
   XCTAssertEqual(RECOVERED_SUT.folder, RECOVERED_SUT_FOLDER)
   XCTAssertEqual(RECOVERED_SUT.snippet, SUT_SNIPPET)
   
  }
  
  
   //REDO TO DELETE RECOVERED FOLDER...
  try await undoManager.redo()
  
  try await undoRedoStatesAssertions(undoManager: undoManager,
                                     sessionCount: 1,
                                     executedUndoCount: 1,
                                     executedRedoCount: 1)
  
  
  await XCTAssertNotNilAsync        (try await SUT_SNIPPET.snippetID)
  await XCTAssertTrueAsync          (try await SUT_SNIPPET.foldersAsync.isEmpty)
  await XCTAssertTrueAsync          (try await SUT_SNIPPET.singleContentElementsAsync.isEmpty)
  
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT_FOLDER.folderID)
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT.elementID)
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT_FOLDER.snippetAsync)
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT.snippetAsync)
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT_FOLDER.folderedElementsAsync.isEmpty)
  
  
   //FINALLY - TRY STORAGE CLEAN-UP!
  
  try await storageRemoveHelperAsync(for: [SUT_SNIPPET])
  
  
 }
 
 
}//extension NMSnippetsManipulationAsyncTests{...}
