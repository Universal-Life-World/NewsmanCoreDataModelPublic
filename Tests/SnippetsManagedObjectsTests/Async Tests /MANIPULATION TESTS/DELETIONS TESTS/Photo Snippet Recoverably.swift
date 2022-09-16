
import NewsmanCoreDataModel
import XCTest

//MARK: Test when Photo Snippet is deleted with recovery with its content it is recovered properly after undo action with proper undo/redo states. The test uses generated snippets DTOs to check for recovered contents equality.

@available(iOS 15.0, macOS 12.0, *)
extension NMSnippetsManipulationAsyncTests {
 final func test_when_SNIPPET_DELETED_with_recovery_it_is_recovered_properly_from_JSON_data() async throws {
  
   //ARRANGE...
  let PERSIST = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  let tree = try await model { context in
   
   PhotoContainer(context: context, persist: PERSIST){ [ unowned self ] in
    SUTS.append($0)
    $0.nameTag = "s1"
    $0.contentElementsGroupingType = .plain(sortedBy: .ascending(keyPath: \NMBaseContent.tag))
   } folders: {
    PhotoFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f1" } elements: {
     Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e11" }
     Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e12" }
    }
    
    PhotoFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f2" } elements: {
     Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e21" }
     Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e22" }
    }
    
   } elements: {
    Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e1" }
    Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e2" }
   }
  }//tree
  
  
   //ASSERT BEFORE DELETE WITH RECOVERY...
 
  
  let SUTS_COUNT = tree.count
  XCTAssertEqual(SUTS_COUNT, 9)
  let SUT: NMPhotoSnippet = try XCTUnwrap(tree[0])
  let SUT_F1: NMPhotoFolder = try XCTUnwrap(tree[0, 0])
  let SUT_F2: NMPhotoFolder = try XCTUnwrap(tree[0, 1])
  let SUT_E1: NMPhoto = try XCTUnwrap(tree[0, 2])
  let SUT_E2: NMPhoto = try XCTUnwrap(tree[0, 3])
  let FOLDERED = Set([tree[0,0,0], tree[0,0,1], tree[0,1,0], tree[0,1,1]].compactMap{$0 as? NMPhoto})
  
  await XCTAssertNoThrowAsync ( try await SUT.snippetID )
  
  let SUT_ID = try await SUT.snippetID
  let SUT_DTO = try await SUT.asyncDTO //generate DTO before removal to compare later for DTO equality
  let SUT_UM = SUT.undoManager   //fix SUT undo manager before delete
  
  await XCTAssertNoThrowAsync  ( try await SUT_F1.folderID )
  await XCTAssertNoThrowAsync  ( try await SUT_F2.folderID )
  await XCTAssertNoThrowAsync  ( try await SUT_E1.elementID )
  await XCTAssertNoThrowAsync  ( try await SUT_E2.elementID )
  await XCTAssertNilAsync      ( try await SUT_E1.folderAsync )
  await XCTAssertNilAsync      ( try await SUT_E2.folderAsync )
  
  await XCTAssertNoThrowAsync  ( try await SUT_F1.snippetAsync)
  await XCTAssertNoThrowAsync  ( try await SUT_F2.snippetAsync)
  await XCTAssertNoThrowAsync  ( try await SUT_E1.snippetAsync)
  await XCTAssertNoThrowAsync  ( try await SUT_E2.snippetAsync)
  
  await XCTAssertEqualAsync    ( try await SUT_F1.snippetAsync, SUT)
  await XCTAssertEqualAsync    ( try await SUT_F2.snippetAsync, SUT)
  await XCTAssertEqualAsync    ( try await SUT_E1.snippetAsync, SUT)
  await XCTAssertEqualAsync    ( try await SUT_E2.snippetAsync, SUT)
  
  await XCTAssertEqualAsync  ( try await SUT_F1.folderedElementsAsync.count, 2)
  await XCTAssertEqualAsync  ( try await SUT_F2.folderedElementsAsync.count, 2)
  await XCTAssertEqualAsync  ( try await Set(SUT_F1.folderedElementsAsync), Set([tree[0,0,0], tree[0,0,1]]))
  await XCTAssertEqualAsync  ( try await Set(SUT_F2.folderedElementsAsync), Set([tree[0,1,0], tree[0,1,1]]))
  
  await XCTAssertEqualAsync  ( try await SUT.folderedContentElementsAsync.count, 4)
  await XCTAssertEqualAsync  ( try await Set(SUT.folderedContentElementsAsync), FOLDERED)
  
  await XCTAssertEqualAsync  ( try await SUT.unfolderedContentElementsAsync.count, 2)
  await XCTAssertEqualAsync  ( try await Set(SUT.unfolderedContentElementsAsync), Set([SUT_E1, SUT_E2]))
  
   //await XCTAssertTrueAsync   (await NMUndoManager.registeredManagers.isEmpty)
  
  try await SUT.deleteRecoverably(persist: PERSIST)
  
   //ASSERT UNDO STATES AFTER DELETE AND BEFORE UNDO ACTION!
  try await beforeUndoStatesAssertions(undoManager: SUT_UM, sessionCount: 1)
  
  if PERSIST {
   await XCTAssertThrowsErrorAsync  ( try await SUT.snippetID,    errorType: ContextError.self )
   await XCTAssertThrowsErrorAsync  ( try await SUT_F1.folderID,  errorType: ContextError.self )
   await XCTAssertThrowsErrorAsync  ( try await SUT_F2.folderID,  errorType: ContextError.self )
   await XCTAssertThrowsErrorAsync  ( try await SUT_E1.elementID, errorType: ContextError.self )
   await XCTAssertThrowsErrorAsync  ( try await SUT_E2.elementID, errorType: ContextError.self )
   
   await XCTAssertThrowsErrorAsync  ( try await SUT_F1.snippetAsync, errorType: ContextError.self )
   await XCTAssertThrowsErrorAsync  ( try await SUT_F2.snippetAsync, errorType: ContextError.self )
   await XCTAssertThrowsErrorAsync  ( try await SUT_E1.snippetAsync, errorType: ContextError.self )
   await XCTAssertThrowsErrorAsync  ( try await SUT_E2.snippetAsync, errorType: ContextError.self )
   
   for element in FOLDERED {
    await XCTAssertThrowsErrorAsync ( try await element.elementID, errorType: ContextError.self )
   }
  }
   //UNDO TO RECOVER DELETED SNIPPET...
   //try await NMGlobalUndoManager.undo()
  try await SUT_UM.undo()
  
   //ASSERT AFTER UNDO...
  try await undoRedoStatesAssertions(undoManager: SUT_UM,
                                     sessionCount: 1,
                                     executedUndoCount: 1,
                                     executedRedoCount: 0)
  
  let RECOVERED_SUT = try await XCTUnwrapAsync(await NMPhotoSnippet.existingSnippet(with: SUT_ID,
                                                                                    in: modelMainContext))
  
  XCTAssertEqual(SUT_UM, RECOVERED_SUT.undoManager)
  
  let RECOVERED_SUT_DTO = try await RECOVERED_SUT.asyncDTO
  
  XCTAssertEqual(RECOVERED_SUT_DTO, SUT_DTO)
  
  await modelMainContext.perform {
   
   XCTAssertNotEqual(RECOVERED_SUT, SUT)
   let foldersCount = RECOVERED_SUT.folders.count
   XCTAssertEqual(foldersCount, 2)
   let unfolderedCount = RECOVERED_SUT.unfolderedContentElements.count
   XCTAssertEqual(unfolderedCount, 2)
   let folderedCount = RECOVERED_SUT.folderedContentElements.count
   XCTAssertEqual(folderedCount, 4)
   XCTAssertEqual(SUTS_COUNT, folderedCount + unfolderedCount + foldersCount + 1)
   
   XCTAssertEqual(RECOVERED_SUT.contentElementsGroupingType,
                  .plain(sortedBy: .ascending(keyPath: \NMBaseContent.tag)))
   
   XCTAssertEqual(RECOVERED_SUT.nameTag, "s1")
   XCTAssertEqual(Set(RECOVERED_SUT.folders.compactMap(\.tag)), Set((1...2).map{"f\($0)"}))
   XCTAssertEqual(Set(RECOVERED_SUT.unfolderedContentElements.compactMap(\.tag)), Set((1...2).map{"e\($0)"}))
   XCTAssertEqual(Set(RECOVERED_SUT.folderedContentElements.compactMap(\.tag)),
                  Set(((1...2) ✖️ (1...2)).map{"e\($0)"}))
  }
  
  
   //REDO TO TO DELETE RECOVERED SNIPPET...
   //try await NMGlobalUndoManager.redo()
  try await SUT_UM.redo()
  
   //ASSERT AFTER REDO...
  try await undoRedoStatesAssertions(undoManager: SUT_UM,
                                     sessionCount: 1,
                                     executedUndoCount: 1,
                                     executedRedoCount: 1)
  
  await XCTAssertNilAsync(try await NMPhotoSnippet.existingSnippet(with: SUT_ID, in: modelMainContext))
  
   //FINALLY - TRY STORAGE CLEAN-UP!
  await XCTAssertThrowsErrorAsync (try await self.storageRemoveHelperAsync(for: [SUT]),
                                   errorType: ContextError.self ) //REMOVED CANNOT BE CLEANED-UP!
  
  await XCTAssertThrowsErrorAsync (try await self.storageRemoveHelperAsync(for: [RECOVERED_SUT]),
                                   errorType: ContextError.self ) //REMOVED CANNOT BE CLEANED-UP!
  
   //  try await storageRemoveHelperAsync(for: [RECOVERED_SUT!])
  
 }//test case
 
  
}//extension NMSnippetsManipulationAsyncTests{...}
