
//import NewsmanCoreDataModel
//import XCTest
//
//@available(iOS 15.0, macOS 12.0, *)
//extension NMSnippetsManipulationAsyncTests {
// final func test_when_ALL_SNIPPETS_DELETED_with_recovery_it_is_recovered_properly_from_JSON_data() async throws {
//  
//   //ARRANGE...
//  let PERSIST = true // WITH PERSISTANCE!
//  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
//  
//  let tree = try await model { context in
//   
//   PhotoContainer(context: context, persist: PERSIST){ [ unowned self ] in
//    SUTS.append($0)
//    $0.nameTag = "s1"
//    $0.contentElementsGroupingType = .plain(sortedBy: .ascending(keyPath: \NMBaseContent.tag))
//   } folders: {
//    PhotoFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f1" } elements: {
//     Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e111" }
//     Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e112" }
//    }
//    
//   } elements: {
//    Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e11" }
//    Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e12" }
//   }
//   
//   VideoContainer(context: context, persist: PERSIST){ [ unowned self ] in
//    SUTS.append($0)
//    $0.nameTag = "s2"
//    $0.contentElementsGroupingType = .plain(sortedBy: .ascending(keyPath: \NMBaseContent.tag))
//   } folders: {
//    VideoFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f2" } elements: {
//     Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e221" }
//     Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e222" }
//    }
//    
//   } elements: {
//    Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e21" }
//    Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e22" }
//   }
//   
//   
//   AudioContainer(context: context, persist: PERSIST){ [ unowned self ] in
//    SUTS.append($0)
//    $0.nameTag = "s3"
//    $0.contentElementsGroupingType = .plain(sortedBy: .ascending(keyPath: \NMBaseContent.tag))
//   } folders: {
//    AudioFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f3" } elements: {
//     Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e331" }
//     Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e332" }
//    }
//    
//   } elements: {
//    Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e31" }
//    Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e32" }
//   }
//   
//   TextContainer(context: context, persist: PERSIST){ [ unowned self ] in
//    SUTS.append($0)
//    $0.nameTag = "s4"
//    $0.contentElementsGroupingType = .plain(sortedBy: .ascending(keyPath: \NMBaseContent.tag))
//   } folders: {
//    TextFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f4" } elements: {
//     Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e441" }
//     Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e442" }
//    }
//    
//   } elements: {
//    Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e41" }
//    Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e42" }
//   }
//   
//   MixedContainer(context: context, persist: PERSIST){ [ unowned self ] in
//    SUTS.append($0)
//    $0.nameTag = "s5"
//    $0.contentElementsGroupingType = .plain(sortedBy: .ascending(keyPath: \NMBaseContent.tag))
//   } mixedElements: {
//    
//    MixedFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f5" } elements: {
//     Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e551" }
//     Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e552" }
//    }
//    
//    Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e51" }
//    Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e52" }
//   }
//   
//  }//tree
//  
//  
//   //ASSERT BEFORE DELETE WITH RECOVERY...
//  
//  
//  let SUT_DTO = try await SUT.asyncDTO //generate DTO before removal to compare later for DTO equality
//  let SUT_UM = await SUT.undoManager   //fix SUT undo manager before delete
//  
//  
//  
//   //await XCTAssertTrueAsync   (await NMUndoManager.registeredManagers.isEmpty)
//  
//  try await SUT.deleteRecoverably(persist: PERSIST)
//  
//   //ASSERT UNDO STATES AFTER DELETE AND BEFORE UNDO ACTION!
//  try await beforeUndoStatesAssertions(undoManager: SUT_UM, sessionCount: 1)
//  
//  if PERSIST {
//   await XCTAssertThrowsErrorAsync  ( try await SUT.snippetID,    errorType: ContextError.self )
//   await XCTAssertThrowsErrorAsync  ( try await SUT_F1.folderID,  errorType: ContextError.self )
//   await XCTAssertThrowsErrorAsync  ( try await SUT_F2.folderID,  errorType: ContextError.self )
//   await XCTAssertThrowsErrorAsync  ( try await SUT_E1.elementID, errorType: ContextError.self )
//   await XCTAssertThrowsErrorAsync  ( try await SUT_E2.elementID, errorType: ContextError.self )
//   
//   await XCTAssertThrowsErrorAsync  ( try await SUT_F1.snippetAsync, errorType: ContextError.self )
//   await XCTAssertThrowsErrorAsync  ( try await SUT_F2.snippetAsync, errorType: ContextError.self )
//   await XCTAssertThrowsErrorAsync  ( try await SUT_E1.snippetAsync, errorType: ContextError.self )
//   await XCTAssertThrowsErrorAsync  ( try await SUT_E2.snippetAsync, errorType: ContextError.self )
//   
//   for element in FOLDERED {
//    await XCTAssertThrowsErrorAsync ( try await element.elementID, errorType: ContextError.self )
//   }
//  }
//   //UNDO TO RECOVER DELETED SNIPPET...
//   //try await NMGlobalUndoManager.undo()
//  try await SUT_UM.undo()
//  
//   //ASSERT AFTER UNDO...
//  try await undoRedoStatesAssertions(undoManager: SUT_UM,
//                                     sessionCount: 1,
//                                     executedUndoCount: 1,
//                                     executedRedoCount: 0)
//  
//  let RECOVERED_SUT = try await XCTUnwrapAsync(await NMPhotoSnippet.existingSnippet(with: SUT_ID,
//                                                                                    in: modelMainContext))
//  
//  await XCTAssertEqualAsync(SUT_UM, await RECOVERED_SUT.undoManager)
//  
//  let RECOVERED_SUT_DTO = try await RECOVERED_SUT.asyncDTO
//  
//  XCTAssertEqual(RECOVERED_SUT_DTO, SUT_DTO)
//  
//  await modelMainContext.perform {
//   
//   XCTAssertNotEqual(RECOVERED_SUT, SUT)
//   let foldersCount = RECOVERED_SUT.folders.count
//   XCTAssertEqual(foldersCount, 2)
//   let unfolderedCount = RECOVERED_SUT.unfolderedContentElements.count
//   XCTAssertEqual(unfolderedCount, 2)
//   let folderedCount = RECOVERED_SUT.folderedContentElements.count
//   XCTAssertEqual(folderedCount, 4)
//   XCTAssertEqual(SUTS_COUNT, folderedCount + unfolderedCount + foldersCount + 1)
//   
//   XCTAssertEqual(RECOVERED_SUT.contentElementsGroupingType,
//                  .plain(sortedBy: .ascending(keyPath: \NMBaseContent.tag)))
//   
//   XCTAssertEqual(RECOVERED_SUT.nameTag, "s1")
//   XCTAssertEqual(Set(RECOVERED_SUT.folders.compactMap(\.tag)), Set((1...2).map{"f\($0)"}))
//   XCTAssertEqual(Set(RECOVERED_SUT.unfolderedContentElements.compactMap(\.tag)), Set((1...2).map{"e\($0)"}))
//   XCTAssertEqual(Set(RECOVERED_SUT.folderedContentElements.compactMap(\.tag)),
//                  Set(((1...2) ✖️ (1...2)).map{"e\($0)"}))
//  }
//  
//  
//   //REDO TO TO DELETE RECOVERED SNIPPET...
//   //try await NMGlobalUndoManager.redo()
//  try await SUT_UM.redo()
//  
//   //ASSERT AFTER REDO...
//  try await undoRedoStatesAssertions(undoManager: SUT_UM,
//                                     sessionCount: 1,
//                                     executedUndoCount: 1,
//                                     executedRedoCount: 1)
//  
//  await XCTAssertNilAsync(try await NMPhotoSnippet.existingSnippet(with: SUT_ID, in: modelMainContext))
//  
//   //FINALLY - TRY STORAGE CLEAN-UP!
//  await XCTAssertThrowsErrorAsync (try await self.storageRemoveHelperAsync(for: [SUT]),
//                                   errorType: ContextError.self ) //REMOVED CANNOT BE CLEANED-UP!
//  
//  await XCTAssertThrowsErrorAsync (try await self.storageRemoveHelperAsync(for: [RECOVERED_SUT]),
//                                   errorType: ContextError.self ) //REMOVED CANNOT BE CLEANED-UP!
//  
//   //  try await storageRemoveHelperAsync(for: [RECOVERED_SUT!])
//  
// }//test case
// 
// 
//}//extension NMSnippetsManipulationAsyncTests{...}
