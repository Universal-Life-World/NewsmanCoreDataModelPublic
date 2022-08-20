import NewsmanCoreDataModel
import XCTest
 
 //MARK: ALL SNIPPETS CONTAINERS & THEIR CONTENT OBJECT MANIPULATION UNIT TESTS.

@available(iOS 15.0, macOS 12.0, *)
final class NMSnippetsManipulationAsyncTests: NMBaseSnippetsAsyncTests {

 
 final func test_MODEL_Builders() async throws {
  
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS_COUNT = 5
  let PERSIST = true
  
 
  let snippetsTree = try await model { context in
    
   PhotoContainer(context: context, persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.nameTag = "s1" }
    folders: {
     PhotoFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f1" } elements: {
       Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e11" }
       Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e12" }
     }
     
     PhotoFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f2" } elements: {
      Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e21" }
      Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e22" }
     }
     
     for i in 3...10 {
      PhotoFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f\(i)" } elements: {
       Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)1" }
       Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)2" }
      }
     }
   } elements: {
    Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e1" }
    Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e2" }
    for i in 3...10 {
     Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)" }
    }
   }

   
   TextContainer(context: context, persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.nameTag = "s2" }
    folders: {
     TextFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f1" } elements: {
      Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e11" }
      Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e12" }
     }
     TextFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f2" } elements: {
      Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e21" }
      Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e22" }
     }
     
     for i in 3...10 {
      TextFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f\(i)" } elements: {
       Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)1" }
       Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)2" }
      }
     }
     
   } elements: {
    Text(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e1" }
    Text(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e2" }
    for i in 3...10 {
     Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)" }
    }
   }
   
   AudioContainer(context: context, persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.nameTag = "s3" }
    folders: {
     AudioFolder(persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.tag = "f1" } elements: {
      Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e11" }
      Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e12" }
     }
     
     AudioFolder(persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.tag = "f2" } elements: {
      Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e21" }
      Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e22" }
     }
     
     for i in 3...10 {
      AudioFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f\(i)" } elements: {
       Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)1" }
       Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)2" }
      }
     }
     
    } elements: {
     Audio(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e1" }
     Audio(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e2" }
     for i in 3...10 {
      Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)" }
     }
     
    }
   
   
   VideoContainer(context: context, persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.nameTag = "s4" }
    folders: {
     VideoFolder(persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.tag = "f1" } elements: {
      Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e11" }
      Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e12" }
     }
     VideoFolder(persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.tag = "f2" } elements: {
      Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e21" }
      Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e22" }
     }
     
     for i in 3...10 {
      VideoFolder(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "f\(i)" } elements: {
       Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)1" }
       Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)2" }
      }
     }
     
   } elements: {
    Video(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e1" }
    Video(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e2" }
    for i in 3...10 {
     Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)" }
    }
   }
   
   MixedContainer(context: context, persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.nameTag = "s5" }
    mixedElements: {
     PhotoFolder(persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.tag = "f1" } elements: {
      Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e11" }
      Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e12" }
     }
     
  
     //Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e1" }
     for i in 1...1 {
      Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e\(i)" }
     }
     
     for _ in 1...1 {
      TextFolder(persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.tag = "f2" } elements: {
       Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e21" }
       Text (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e22" }
      }
     }
     
     Text(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e2" }
     
     AudioFolder(persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.tag = "f3" } elements: {
      Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e31" }
      Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e32" }
     }
     Audio(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e3" }
     
     VideoFolder(persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.tag = "f4" } elements: {
      Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e41" }
      Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e42" }
     }
     
     Video(persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e4" }
     
     MixedFolder(persist: PERSIST){ [ unowned self ] in SUTS.append($0); $0.tag = "f5" } elements: {
      Audio (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e51" }
      Video (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e52" }
      Photo (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e53" }
      for _ in 1...1 {
       Text  (persist: PERSIST) { [ unowned self ] in SUTS.append($0); $0.tag = "e54" }
      }
     }
   }

  }
  
  try await modelMainContext.perform {
   
   for i in 0..<4 {
    let snippet = try XCTUnwrap(snippetsTree[i])
    XCTAssertEqual(snippet.nameTag, "s\(i+1)")
    
    for j in 0..<10 {
     let folder = try XCTUnwrap(snippetsTree[i, j])
     XCTAssertEqual(folder.tag, "f\(j+1)")
    
     for k in 0..<2 {
      let element = try XCTUnwrap(snippetsTree[i, j, k])
      XCTAssertEqual(element.tag, "e\(j+1)\(k+1)")
     }
     
    }
    
    for j in 10..<20 {
     let element = try XCTUnwrap(snippetsTree[i, j])
     XCTAssertEqual(element.tag, "e\(j-9)")
    }
    
    //Test mixed container case...
    let mixedSnippet = try XCTUnwrap(snippetsTree[4])
    XCTAssertEqual(mixedSnippet.nameTag, "s5")
    
    for j in 0..<9 {
     let mixedElement = try XCTUnwrap(snippetsTree[4, j])
     let index = j/2 + 1
     if j % 2 == 0 {
     
      XCTAssertEqual(mixedElement.tag, "f\(index)")
      
      for k in 0..<2 {
       let element = try XCTUnwrap(snippetsTree[4, j, k])
       XCTAssertEqual(element.tag, "e\(index)\(k+1)")
      }
     } else {
      XCTAssertEqual(mixedElement.tag, "e\(index)")
     }
    }
    
   }
    
   
   let f2: NMPhotoFolder = try XCTUnwrap(snippetsTree[0, 1])
   XCTAssertEqual(f2.tag, "f2")
   
   let err1: NMPhoto? = snippetsTree[0, 1]
   XCTAssertNil(err1)
   
   let err2: NMPhoto? = snippetsTree[0, 1, 8]
   XCTAssertNil(err2)
   
   let e21: NMPhoto = try XCTUnwrap(snippetsTree[0, 1, 0])
   XCTAssertEqual(e21.tag, "e21")
   let e22: NMPhoto = try XCTUnwrap(snippetsTree[0, 1, 1])
   XCTAssertEqual(e22.tag, "e22")
  }
  
  await modelMainContext.perform {
   let snippets = snippetsTree.snippets
   XCTAssertEqual(snippets.count, SUTS_COUNT)
   
   let regSnippets = modelMainContext.registeredObjects.compactMap{$0 as? NMBaseSnippet}
   XCTAssertEqual(regSnippets.count, SUTS_COUNT)
   XCTAssertEqual(Set(regSnippets) , Set(snippets))
   let snippetsTags = Set(regSnippets.compactMap(\.nameTag))
   XCTAssertEqual(snippetsTags, Set(["s1", "s2", "s3", "s4", "s5"]))
   
   func assertSnippet<S: NMContentElementsContainer>(snippet: S)
    where S.Element: NMContentElement,
          S.Element.Snippet == S.Folder.Snippet,
          S.Element == S.Folder.Element,
          S.Folder == S.Element.Folder,
          S == S.Element.Snippet {
   
    let folders = snippet.folders
    let singles = snippet.singleContentElements
    let foldered = snippet.folderedContentElements
    let unfoldered = snippet.unfolderedContentElements
    let folderedTags = folders.flatMap{$0.folderedElements.compactMap(\.tag)}
    let folderedElements = folders.flatMap{$0.folderedElements as [NMBaseContent]}
           
    XCTAssertEqual(folders.count, 10)
    XCTAssertEqual(foldered.count, 20)
           
    XCTAssertEqual(singles.count, 30)
    XCTAssertEqual(Set(folders.compactMap(\.tag)),    Set((1...10).map{"f\($0)"}) )
    XCTAssertEqual(Set(unfoldered.compactMap(\.tag)), Set((1...10).map{"e\($0)"}) )
    XCTAssertTrue(folders.allSatisfy{ $0.snippet == snippet })
    XCTAssertTrue(singles.allSatisfy{ $0.snippet == snippet })
    let folderedTagsSet = Set((1...10).map{["e\($0)1","e\($0)2"]}.flatMap{$0})
    XCTAssertEqual(Set(foldered.compactMap(\.tag)), folderedTagsSet)
    XCTAssertEqual(Set(folderedTags), folderedTagsSet)
    XCTAssertEqual(Set(folderedElements), Set(foldered))
           
   }
   
   for snippet in snippets {
    switch snippet {
     case let snippet as NMPhotoSnippet: assertSnippet(snippet: snippet)
     case let snippet as NMTextSnippet:  assertSnippet(snippet: snippet)
     case let snippet as NMAudioSnippet: assertSnippet(snippet: snippet)
     case let snippet as NMVideoSnippet: assertSnippet(snippet: snippet)

      
     case let snippet as NMMixedSnippet:
      
      XCTAssertEqual(snippet.folders.count, 5)
      XCTAssertEqual(Set(snippet.folders.compactMap(\.tag)), Set(["f1", "f2", "f3", "f4", "f5"]))
      
      XCTAssertEqual(snippet.singleContentElements.count, 16)
      XCTAssertEqual(Set(snippet.singleContentElements.compactMap(\.tag)),
                     Set(["e1", "e11", "e12",
                          "e2", "e21", "e22",
                          "e3", "e31", "e32",
                          "e4", "e41", "e42",
                          "e51","e52", "e53","e54"]))
      
      XCTAssertTrue(snippet.photoElementsFolders.allSatisfy{ $0.mixedSnippet == snippet && $0.snippet == nil })
      XCTAssertTrue(snippet .textElementsFolders.allSatisfy{ $0.mixedSnippet == snippet && $0.snippet == nil })
      XCTAssertTrue(snippet.audioElementsFolders.allSatisfy{ $0.mixedSnippet == snippet && $0.snippet == nil })
      XCTAssertTrue(snippet.videoElementsFolders.allSatisfy{ $0.mixedSnippet == snippet && $0.snippet == nil })
      
      XCTAssertTrue(snippet.mixedElementsFolders.allSatisfy{ $0.snippet == snippet })
      
      XCTAssertTrue(snippet.photoElements.allSatisfy{ $0.mixedSnippet == snippet && $0.snippet == nil })
      XCTAssertTrue(snippet.audioElements.allSatisfy{ $0.mixedSnippet == snippet && $0.snippet == nil })
      XCTAssertTrue(snippet.textsElements.allSatisfy{ $0.mixedSnippet == snippet && $0.snippet == nil })
      XCTAssertTrue(snippet.videoElements.allSatisfy{ $0.mixedSnippet == snippet && $0.snippet == nil })
    
      

     
     default: XCTFail()
    }
   }
   
  
   
  }
  
 }
 
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
  
  let undoManager = await NMGlobalUndoManager.shared.undoManager
  
  //ACTION - DELETE WITH RECOVERY!
  try await withGlobalUndoSession {
   try await SUT_FOLDER.deleteWithRecovery(persist: PERSISTED)
  }
  
  //ASSERT UNDO STATES AFTER DELETE AND BEFORE UNDO ACTION!
  await XCTAssertNilAsync    (await NMUndoSession.current)
  await XCTAssertFalseAsync  (await undoManager.isEmpty)
  await XCTAssertNotNilAsync (await undoManager.topUndo)
  await XCTAssertNotNilAsync (await undoManager.bottomUndo)
  await XCTAssertNotNilAsync (await undoManager.currentUndo)
  
  await XCTAssertEqualAllAsync({ await undoManager.topUndo },
                               { await undoManager.bottomUndo },
                               { await undoManager.currentUndo })
  
  await XCTAssertTrueAsync  (await undoManager.canUndo)
  await XCTAssertFalseAsync (await undoManager.canRedo)
  
  await XCTAssertEqualAsync (await undoManager.sessionCount, 1)
  await XCTAssertFalseAsync (await undoManager.currentUndo!.isEmpty)
  await XCTAssertFalseAsync (await undoManager.currentUndo!.isExecuted)
  await XCTAssertFalseAsync (await NMUndoSession.hasOpenSession)
 
  
  await XCTAssertNotNilAsync        (try await SUT_SNIPPET.snippetID)
  await XCTAssertTrueAsync          (try await SUT_SNIPPET.foldersAsync.isEmpty)
  await XCTAssertTrueAsync          (try await SUT_SNIPPET.singleContentElementsAsync.isEmpty)
  
  await XCTAssertThrowsErrorAsync   (try await SUT_FOLDER.folderID)
  await XCTAssertThrowsErrorAsync   (try await SUT.elementID)
  await XCTAssertThrowsErrorAsync   (try await SUT_FOLDER.snippetAsync)
  await XCTAssertThrowsErrorAsync   (try await SUT.snippetAsync)
  await XCTAssertThrowsErrorAsync   (try await SUT_FOLDER.folderedElementsAsync.isEmpty)
  
  
  //UNDO TO RECOVER DELETED FOLDER...
  try await NMGlobalUndoManager.undo()
  
 //ASSERT AFTER UNDO...
  await XCTAssertNilAsync    (await NMUndoSession.current)
  await XCTAssertFalseAsync  (await undoManager.isEmpty)
  await XCTAssertNotNilAsync (await undoManager.topUndo)      //The same state always!
  await XCTAssertNotNilAsync (await undoManager.bottomUndo)   //The same state always!
  await XCTAssertNilAsync    (await undoManager.currentUndo)  //No more undo sessions to execute!
  await XCTAssertFalseAsync  (await NMUndoSession.hasOpenSession) //No open sessions per se!
  
  await XCTAssertEqualAsync  (await undoManager.topUndo,
                              await undoManager.bottomUndo )  //One session is in UM Stack still!
  
  await XCTAssertFalseAsync  (await undoManager.canUndo)      //No more undos to execute!
  await XCTAssertTrueAsync   (await undoManager.canRedo)      //Can only redo!
  
  await XCTAssertEqualAsync (await undoManager.sessionCount, 1)
  
  await XCTAssertEqualAsync (try await undoManager.executedUndoCount, 1)
  await XCTAssertEqualAsync (try await undoManager.executedRedoCount, 0)
  
  await XCTAssertNilAsync   (try await undoManager.lastUnexecutedUndo)
  await XCTAssertNilAsync   (try await undoManager.firstUnexecutedUndo)
  
  await XCTAssertEqualAllAsync({ await undoManager.topUndo },
                               { await undoManager.bottomUndo },
                               { try await undoManager.lastExecutedUndo })
  
  await XCTAssertEqualAsync (try await undoManager.unexecutedRedoCount, 1)
  await XCTAssertEqualAsync (try await undoManager.unexecutedUndoCount, 0)
  
  let RECOVERED_SUT_FOLDER = try await NMPhotoFolder.existingFolder(with: SUT_FOLDER_ID, in: modelMainContext)
  let RECOVERED_SUT = try await RECOVERED_SUT_FOLDER!.folderedElementsAsync.first
  
  
  await modelMainContext.perform {
   XCTAssertNotNil(RECOVERED_SUT_FOLDER)
   XCTAssertNotNil(RECOVERED_SUT)
   XCTAssertEqual(SUT_SNIPPET.folders.first, RECOVERED_SUT_FOLDER)
   XCTAssertEqual(SUT_SNIPPET.singleContentElements.first, RECOVERED_SUT)
   XCTAssertEqual(RECOVERED_SUT_FOLDER!.folderedElements.count, 1)
   XCTAssertEqual(RECOVERED_SUT_FOLDER!.folderedElements.first!.id, SUT_ID)
   XCTAssertEqual(RECOVERED_SUT_FOLDER!.snippet, SUT_SNIPPET)
   XCTAssertEqual(RECOVERED_SUT!.folder, RECOVERED_SUT_FOLDER!)
   XCTAssertEqual(RECOVERED_SUT!.snippet, SUT_SNIPPET)
   
  }
  
  
  //REDO TO DELETE RECOVERED FOLDER...
  try await NMGlobalUndoManager.redo()
  
  await XCTAssertNilAsync    (await NMUndoSession.current)
  await XCTAssertFalseAsync  (await undoManager.isEmpty)
  await XCTAssertNotNilAsync (await undoManager.topUndo)      //The same state always!
  await XCTAssertNotNilAsync (await undoManager.bottomUndo)   //The same state always!
  await XCTAssertNotNilAsync (await undoManager.currentUndo)  //One session to execute!
  await XCTAssertFalseAsync  (await NMUndoSession.hasOpenSession) //No open sessions per se!
  
  await XCTAssertEqualAsync  (await undoManager.topUndo,
                              await undoManager.bottomUndo )  //One session is in UM Stack still!
  
  await XCTAssertTrueAsync   (await undoManager.canUndo)      //One undo to execute!
  await XCTAssertFalseAsync  (await undoManager.canRedo)      //No redo to execute !
  
  await XCTAssertEqualAsync  (await undoManager.sessionCount, 1)
 
  await XCTAssertEqualAsync  (try await undoManager.executedUndoCount, 0)
  await XCTAssertEqualAsync  (try await undoManager.executedRedoCount, 1)
  
  await XCTAssertNotNilAsync (try await undoManager.lastUnexecutedUndo)
  await XCTAssertNotNilAsync (try await undoManager.firstUnexecutedUndo)
  
  await XCTAssertEqualAllAsync({ await undoManager.topUndo },
                               { await undoManager.bottomUndo },
                               { try await undoManager.lastUnexecutedUndo })
  
  await XCTAssertEqualAsync (try await undoManager.unexecutedRedoCount, 0)
  await XCTAssertEqualAsync (try await undoManager.unexecutedUndoCount, 1)
  
  await XCTAssertNotNilAsync        (try await SUT_SNIPPET.snippetID)
  await XCTAssertTrueAsync          (try await SUT_SNIPPET.foldersAsync.isEmpty)
  await XCTAssertTrueAsync          (try await SUT_SNIPPET.singleContentElementsAsync.isEmpty)
  
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT_FOLDER!.folderID)
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT!.elementID)
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT_FOLDER!.snippetAsync)
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT!.snippetAsync)
  await XCTAssertThrowsErrorAsync   (try await RECOVERED_SUT_FOLDER!.folderedElementsAsync.isEmpty)
  
 }
 
 
 
 final func test_JSON_Serialization_of_content_elements() async throws {
  
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
   $0.geoLocation = .init(location: .init(latitude: 10, longitude: 10))
   $0.location = "Some Location"
   $0.priority = .hottest
   $0.colorFlag = .brown
   $0.arrowMenuPosition = .init(x: 100, y: 100)
   $0.arrowMenuTouchPoint = .init(x: 50, y: 50)
   $0[.plain(sortedBy: .ascending(keyPath: \.priority))] = 1
   $0[.dateGroups(sortedBy: .ascending(keyPath: \.priority))] = 0
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT = try await SUT_SNIPPET.createSingle(persist: PERSISTED,
                                                  in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   $0.colorFlag = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SUT_SNIPPET.createSingle(persist: PERSISTED,
                                                   in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   $0.colorFlag = #colorLiteral(red: 0.8793543782, green: 0.2253175287, blue: 0.1012533999, alpha: 1)
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  //ASSERT BEFORE CODING...
  
  await modelMainContext.perform {
   XCTAssertNotNil(SUT_SNIPPET.id)
   XCTAssertNotNil(SUT_FOLDER.id)
   XCTAssertNotNil(SUT.id)
   XCTAssertNotNil(SUT2.id)
   XCTAssertEqual(SUT_SNIPPET, SUT_FOLDER.snippet)
   XCTAssertEqual(SUT_SNIPPET, SUT.snippet)
   XCTAssertEqual(SUT_SNIPPET, SUT2.snippet)
   XCTAssertEqual(SUT_FOLDER, SUT.folder)
   XCTAssertEqual(SUT_FOLDER, SUT2.folder)
   XCTAssertEqual(SUT_FOLDER.folderedPhotos, NSSet(array: [SUT, SUT2]))
   XCTAssertEqual(SUT_SNIPPET.photoFolders,  NSSet(object: SUT_FOLDER))
   XCTAssertEqual(SUT_SNIPPET.photos,        NSSet(array: [SUT, SUT2]))
   XCTAssertEqual(SUT_FOLDER[.plain     (sortedBy: .ascending(keyPath: \.priority))], 1)
   XCTAssertEqual(SUT_FOLDER[.dateGroups(sortedBy: .ascending(keyPath: \.priority))], 0)
   
  }
  
  
  //ASSERT AFTER CODING...
  
  let SUT_DATA = try await SUT.jsonEncodedData
  try await SUT.delete(withFileStorageRecovery: true, persisted: false)
  let DECODED_SUT = try await NMPhoto.jsonDecoded(from: SUT_DATA, using: modelMainContext)
  
  try await modelMainContext.perform {
  
   XCTAssertNotEqual(DECODED_SUT, SUT)
   XCTAssertTrue(DECODED_SUT <=> SUT)
   XCTAssertTrue(SUT.isDeleted)
   XCTAssertNotNil(SUT.managedObjectContext)
   XCTAssertNotNil(DECODED_SUT.managedObjectContext)
   XCTAssertNotNil(DECODED_SUT.recoveryURL)
   XCTAssertEqual(SUT_SNIPPET, DECODED_SUT.snippet)
   XCTAssertEqual(SUT_FOLDER, DECODED_SUT.folder)
   let decodedURL = try XCTUnwrap(DECODED_SUT.url)
   XCTAssertTrue(FileManager.default.fileExists(atPath: decodedURL.path))
   
  }
  
 
  let SUT2_DATA = try await SUT2.jsonEncodedData
  try await SUT2.delete(withFileStorageRecovery: true, persisted: false)
  let DECODED_SUT2 = try await NMPhoto.jsonDecoded(from: SUT2_DATA, using: modelMainContext)
  
  try await modelMainContext.perform {
   
   XCTAssertNotEqual(DECODED_SUT2, SUT2)
   XCTAssertTrue(DECODED_SUT2 <=> SUT2)
   XCTAssertTrue(SUT2.isDeleted)
   XCTAssertNotNil(SUT2.managedObjectContext)
   XCTAssertNotNil(DECODED_SUT.managedObjectContext)
   XCTAssertNotNil(DECODED_SUT.recoveryURL)
   XCTAssertEqual(SUT_SNIPPET, DECODED_SUT2.snippet)
   XCTAssertEqual(SUT_FOLDER, DECODED_SUT2.folder)
   let decodedURL = try XCTUnwrap(DECODED_SUT2.url)
   XCTAssertTrue(FileManager.default.fileExists(atPath: decodedURL.path))
   
  }
  
  let SUT_FOLDER_DATA = try await SUT_FOLDER.jsonEncodedData
  try await SUT_FOLDER.delete(withFileStorageRecovery: true, persisted: false)
  let DECODED_SUT_FOLDER = try await NMPhotoFolder.jsonDecoded(from: SUT_FOLDER_DATA, using: modelMainContext)
  
  try await modelMainContext.perform {
  
   XCTAssertTrue      (DECODED_SUT_FOLDER <-> SUT_FOLDER)
   XCTAssertFalse     (DECODED_SUT_FOLDER <=> SUT_FOLDER)
   XCTAssertNotEqual  (SUT_FOLDER, DECODED_SUT_FOLDER)
   XCTAssertEqual     (SUT_FOLDER.id, DECODED_SUT_FOLDER.id)
   XCTAssertNil       (SUT_FOLDER.snippet)
   XCTAssertTrue      (SUT_FOLDER.isDeleted)
   XCTAssertTrue      (SUT_FOLDER.folderedElements.isEmpty)
   
   let decodedURL = try XCTUnwrap(DECODED_SUT_FOLDER.url)
   XCTAssertTrue(FileManager.default.fileExists(atPath: decodedURL.path))
   
   let decodedFoldered = DECODED_SUT_FOLDER.folderedElements
   XCTAssertEqual(decodedFoldered.count, 2)
   XCTAssertEqual(Set(decodedFoldered.compactMap(\.id)), Set([SUT.id, SUT2.id]))

   XCTAssertEqual(DECODED_SUT_FOLDER[.plain     (sortedBy: .ascending(keyPath: \.priority))], 1)
   XCTAssertEqual(DECODED_SUT_FOLDER[.dateGroups(sortedBy: .ascending(keyPath: \.priority))], 0)
   
   
  }
  
 }
 
//MARK: Test when SINGLE content (SUT) (NMContentElement) element moved async from source Parent snippet to destination snippet this object finishes in correct context and underlying file storage state. The source Folder (if Any) is auto deleted with empty file folder as empty folder or as an only contained element folder.
 
 final func test_when_SINGLE_content_element_MOVED_from_source_snippet_to_destination_snippet() async throws {
  
  //ARRANGE...
 
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  //CREATE SOURCE SNIPPET...
  let SOURCE_SNIPPET = try await model.create(persist: PERSISTED,
                                              objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SOURCE_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
 
  let SUT = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                  in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                  in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
   //CREATE SOURCE SNIPPET...
  let DEST_SNIPPET = try await model.create(persist: PERSISTED,
                                            objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Destination Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  

  // ASSERT BEFORE MOVE!
  
  let SUT_resourceURL_BEFORE = try await SUT.resourceContentURL
  let SUT2_resourceURL_BEFORE = try await SUT2.resourceContentURL
  
  let SUT_FOLDER_URL = await modelMainContext.perform { SUT_FOLDER.url }
 
  let SUT_FOLDER_BEFORE = SUT_FOLDER
  
  XCTAssertNotNil(SUT_FOLDER_URL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  
  await modelMainContext.perform {
   
   //SUT main
   XCTAssertNotNil (SUT.folder)
   XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL_BEFORE.path))
   XCTAssertEqual(SUT_resourceURL_BEFORE.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL_BEFORE.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL_BEFORE.pathComponents.dropLast(2).last, SOURCE_SNIPPET.id?.uuidString)
   
   //SUT2 in folder
   XCTAssertNotNil (SUT2.folder)
   XCTAssertEqual(SUT.folder, SUT2.folder)// both in the same folder before move!
   XCTAssertTrue(FileManager.default.fileExists(atPath: SUT2_resourceURL_BEFORE.path))
   XCTAssertEqual(SUT2_resourceURL_BEFORE.pathComponents.last, SUT2.id?.uuidString)
   XCTAssertEqual(SUT2_resourceURL_BEFORE.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(SUT2_resourceURL_BEFORE.pathComponents.dropLast(2).last, SOURCE_SNIPPET.id?.uuidString)
  }
  
  //ASSERT UNDO/REDO STATES BEFORE MOVE...
  await XCTAssertNilAsync   (await NMUndoSession.current)        //No open session!
  await XCTAssertTrueAsync  (await SUT.undoManager.isEmpty)      //UM has no closed session to undo/redo!
  await XCTAssertNilAsync   (await SUT.undoManager.topUndo)      //No top undo session in UM stack
  await XCTAssertNilAsync   (await SUT.undoManager.bottomUndo)   //No last undo session in UM stack
  await XCTAssertNilAsync   (await SUT.undoManager.currentUndo)  //No top undo session in UM stack
  await XCTAssertFalseAsync (await SUT.undoManager.canUndo)      //You cannot undo!
  await XCTAssertFalseAsync (await SUT.undoManager.canRedo)      //You cannot redo!
  await XCTAssertEqualAsync (await SUT.undoManager.sessionCount, 0) //UM Stack is empty yet!
  await XCTAssertEqualAsync (await NMUndoManager.registeredManagers.count, 0) //No UM registered globally!
  
  //ACTION...
  try await SUT.move(to: DEST_SNIPPET, persist: PERSISTED) { $0.tag = "MOVED SUT" } 
  
  //ASSERT...
  let SOURCE_resourceURL = try await SOURCE_SNIPPET.resourceSnippetURL
  //XCTAssertNotNil(SOURCE_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SOURCE_resourceURL.path))
  
  let DEST_resourceURL = try await DEST_SNIPPET.resourceSnippetURL

  XCTAssertTrue(FileManager.default.fileExists(atPath: DEST_resourceURL.path))
  XCTAssertFalse(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path)) //fixed before move!
  
  await XCTAssertThrowsErrorAsync(try await SUT_FOLDER.resourceFolderURL) //folder is deleted no resource available!
  
  let SUT_resourceURL_AFTER = try await SUT.resourceContentURL
  XCTAssertNotNil(SUT_resourceURL_AFTER)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL_AFTER.path))
  
  let SUT2_resourceURL_AFTER = try await SUT2.resourceContentURL
  XCTAssertNotNil(SUT2_resourceURL_AFTER)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT2_resourceURL_AFTER.path))
  
  // Executing this assetions closure have to have the same effect after MOVE & REDO MOVE!!!
  let afterMoveAssertions = { (SUT_FOLDER: NMPhotoFolder) async throws -> () in
   try await modelMainContext.perform {
    XCTAssertEqual(SUT.snippet, DEST_SNIPPET)
    XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.count, 1)
    XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.first, SUT2)
    XCTAssertEqual(DEST_SNIPPET.singleContentElements.count, 1)
    XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
    //XCTAssertTrue(SUT_FOLDER.isDeleted)         //before persistance!
    XCTAssertNil(SUT_FOLDER.managedObjectContext) //if context changes are persisted!
    XCTAssertNil(SUT_FOLDER.id)                   //if context changes are persisted!
    XCTAssertNil(SUT_FOLDER.url)                  //if context changes are persisted!
    XCTAssertNotNil (SUT.managedObjectContext)
    XCTAssertFalse(SUT.isDeleted)
    XCTAssertEqual (SUT.snippet, DEST_SNIPPET)
    XCTAssertNil (SUT.folder)
    XCTAssertNil (SUT2.folder) // both foldered after move!
    XCTAssertEqual(SUT.tag, "MOVED SUT")
   
    let URL = try XCTUnwrap(SUT.url?.path)
    XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
    XCTAssertEqual(SUT_resourceURL_AFTER.path, URL)
    XCTAssertEqual(SUT_resourceURL_AFTER.pathComponents.last, SUT.id?.uuidString)
    XCTAssertEqual(SUT_resourceURL_AFTER.pathComponents.dropLast().last, DEST_SNIPPET.id?.uuidString)
    
    let URL2 = try XCTUnwrap(SUT2.url?.path)
    XCTAssertTrue(FileManager.default.fileExists(atPath: URL2))
    XCTAssertEqual(SUT2_resourceURL_AFTER.path, URL2)
    XCTAssertEqual(SUT2_resourceURL_AFTER.pathComponents.last, SUT2.id?.uuidString)
    XCTAssertEqual(SUT2_resourceURL_AFTER.pathComponents.dropLast().last, SOURCE_SNIPPET.id?.uuidString)
    
    XCTAssertFalse(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  
   }
  }
  
  try await afterMoveAssertions(SUT_FOLDER)
  
  //ASSERT UNDO/REDO STATE AFTER MOVE...
 
  await XCTAssertNilAsync    (await NMUndoSession.current)
  await XCTAssertFalseAsync  (await SUT.undoManager.isEmpty)
  await XCTAssertNotNilAsync (await SUT.undoManager.topUndo)
  await XCTAssertNotNilAsync (await SUT.undoManager.bottomUndo)
  await XCTAssertNotNilAsync (await SUT.undoManager.currentUndo)
  
  await XCTAssertEqualAllAsync({ await SUT.undoManager.topUndo },
                               { await SUT.undoManager.bottomUndo },
                               { await SUT.undoManager.currentUndo })
  
  await XCTAssertTrueAsync  (await SUT.undoManager.canUndo)
  await XCTAssertFalseAsync (await SUT.undoManager.canRedo)

  await XCTAssertEqualAsync (await SUT.undoManager.sessionCount, 1)
  await XCTAssertEqualAsync (await NMUndoManager.registeredManagers.count, 1)
  await XCTAssertFalseAsync (await SUT.undoManager.currentUndo!.isEmpty)
  await XCTAssertFalseAsync (await SUT.undoManager.currentUndo!.isExecuted)
  await XCTAssertFalseAsync (await NMUndoSession.hasOpenSession)
  
 
  
  //UNDO ACTION...
  try await SUT.undo(persist: PERSISTED)
  
  //ASSERT AFTER UNDO...
  await XCTAssertNilAsync    (await NMUndoSession.current)
  await XCTAssertFalseAsync  (await SUT.undoManager.isEmpty)
  await XCTAssertNotNilAsync (await SUT.undoManager.topUndo)      //The same state always!
  await XCTAssertNotNilAsync (await SUT.undoManager.bottomUndo)   //The same state always!
  await XCTAssertNilAsync    (await SUT.undoManager.currentUndo)  //No more undo sessions to execute!
  await XCTAssertFalseAsync  (await NMUndoSession.hasOpenSession) //No open sessions per se!
  
  await XCTAssertEqualAsync  (await SUT.undoManager.topUndo,
                              await SUT.undoManager.bottomUndo )  //One session is in UM Stack still!
  
  await XCTAssertFalseAsync  (await SUT.undoManager.canUndo)      //No more undos to execute!
  await XCTAssertTrueAsync   (await SUT.undoManager.canRedo)      //Can only redo!
  
  await XCTAssertEqualAsync (await SUT.undoManager.sessionCount, 1)
  await XCTAssertEqualAsync (await NMUndoManager.registeredManagers.count, 1)
  
  await XCTAssertEqualAsync (try await SUT.undoManager.executedUndoCount, 1)
  await XCTAssertEqualAsync (try await SUT.undoManager.executedRedoCount, 0)
  
  await XCTAssertNilAsync   (try await SUT.undoManager.lastUnexecutedUndo)
  await XCTAssertNilAsync   (try await SUT.undoManager.firstUnexecutedUndo)
  
  await XCTAssertEqualAllAsync({ await SUT.undoManager.topUndo },
                               { await SUT.undoManager.bottomUndo },
                               { try await SUT.undoManager.lastExecutedUndo })
  
  await XCTAssertEqualAsync (try await SUT.undoManager.unexecutedRedoCount, 1)
  await XCTAssertEqualAsync (try await SUT.undoManager.unexecutedUndoCount, 0)
  
  
  let SUT_FOLDER_AFTER_UNDO = try await modelMainContext.perform { () -> NMPhotoFolder in
   XCTAssertFalse(SUT.isDeleted)
   XCTAssertEqual(SUT.snippet, SOURCE_SNIPPET)
   XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.count, 2)
   XCTAssertEqual(DEST_SNIPPET.singleContentElements.count, 0)
   let SUT_FOLDER = try XCTUnwrap(SOURCE_SNIPPET.folders.first) //new recovered folder!
   XCTAssertNotEqual(SUT_FOLDER_BEFORE, SUT_FOLDER) //the recovered is not the same as deleted emptified!
   XCTAssertEqual(SUT_FOLDER.folderedElements.count, 2)
   XCTAssertFalse(SUT_FOLDER.isDeleted)
   XCTAssertNotNil(SUT_FOLDER.url)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertEqual(SUT_FOLDER.url, SUT_FOLDER_URL)
   XCTAssertEqual (SUT.snippet, SOURCE_SNIPPET)
   XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
   XCTAssertEqual (SUT.folder, SUT_FOLDER)
   XCTAssertEqual (SUT2.folder, SUT_FOLDER) //both in the same recovered folder after undo move!
   XCTAssertEqual(SUT.tag, "MOVED SUT")
   
   //Folder recovery...
   let FOLDER_recoveryURL = try XCTUnwrap(SUT_FOLDER.recoveryURL?.path)
   XCTAssertFalse(FileManager.default.fileExists(atPath: FOLDER_recoveryURL)) //moved back after undo!
   
   //SUT main...
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL_BEFORE.path, URL)
   XCTAssertEqual(SUT_resourceURL_BEFORE.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL_BEFORE.pathComponents.dropLast(2).last, SOURCE_SNIPPET.id?.uuidString)
   
   //SUT2...
   let URL2 = try XCTUnwrap(SUT2.url?.path) //SUT main
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL2))
   XCTAssertEqual(SUT2_resourceURL_BEFORE.path, URL2)
   XCTAssertEqual(SUT2_resourceURL_BEFORE.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(SUT2_resourceURL_BEFORE.pathComponents.dropLast(2).last, SOURCE_SNIPPET.id?.uuidString)
   
   return SUT_FOLDER
  }
  
   //REDO ACTION...
  
  try await SUT.redo(persist: PERSISTED)
  
   //ASSERT AFTER REDO...

  await XCTAssertNilAsync    (await NMUndoSession.current)
  await XCTAssertFalseAsync  (await SUT.undoManager.isEmpty)
  await XCTAssertNotNilAsync (await SUT.undoManager.topUndo)      //The same state always!
  await XCTAssertNotNilAsync (await SUT.undoManager.bottomUndo)   //The same state always!
  await XCTAssertNotNilAsync (await SUT.undoManager.currentUndo)  //One session to execute!
  await XCTAssertFalseAsync  (await NMUndoSession.hasOpenSession) //No open sessions per se!
  
  await XCTAssertEqualAsync  (await SUT.undoManager.topUndo,
                              await SUT.undoManager.bottomUndo )  //One session is in UM Stack still!
  
  await XCTAssertTrueAsync   (await SUT.undoManager.canUndo)      //One undo to execute!
  await XCTAssertFalseAsync  (await SUT.undoManager.canRedo)      //No redo to execute !
  
  await XCTAssertEqualAsync  (await SUT.undoManager.sessionCount, 1)
  await XCTAssertEqualAsync  (await NMUndoManager.registeredManagers.count, 1)
  
  await XCTAssertEqualAsync  (try await SUT.undoManager.executedUndoCount, 0)
  await XCTAssertEqualAsync  (try await SUT.undoManager.executedRedoCount, 1)
  
  await XCTAssertNotNilAsync (try await SUT.undoManager.lastUnexecutedUndo)
  await XCTAssertNotNilAsync (try await SUT.undoManager.firstUnexecutedUndo)
  
  await XCTAssertEqualAllAsync({ await SUT.undoManager.topUndo },
                               { await SUT.undoManager.bottomUndo },
                               { try await SUT.undoManager.lastUnexecutedUndo })
  
  await XCTAssertEqualAsync (try await SUT.undoManager.unexecutedRedoCount, 0)
  await XCTAssertEqualAsync (try await SUT.undoManager.unexecutedUndoCount, 1)
  
  
  try await afterMoveAssertions(SUT_FOLDER_AFTER_UNDO)

  //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: [SOURCE_SNIPPET, DEST_SNIPPET])
  
 }//test...
 
 //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved async within its own Parent Snippet this object finishes in correct context and underlying file storage state. The source Folder (if Any) is auto deleted with empty file folder as empty folder or as an only contained element folder.
 
 final func test_when_SINGLE_content_element_MOVED_within_its_snippet() async throws {
  
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
   //CREATE SOURCE SNIPPET...
  let SNIPPET = try await model.create(persist: PERSISTED, objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT = try await SNIPPET.createSingle(persist: PERSISTED, in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SNIPPET.createSingle(persist: PERSISTED, in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
   // ASSERT BEFORE MOVE!
  
  let SUT_FOLDER_URL = await modelMainContext.perform { SUT_FOLDER.url }
  
  XCTAssertNotNil(SUT_FOLDER_URL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
  }
  
  
   //ACTION...
  try await SUT.move(to: SNIPPET, persist: PERSISTED) { $0.tag = "MOVED SUT" }
  
  
   //ASSERT...
  let SOURCE_resourceURL = try await SNIPPET.resourceSnippetURL
  XCTAssertTrue(FileManager.default.fileExists(atPath: SOURCE_resourceURL.path))
  
  
  XCTAssertFalse(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  await XCTAssertThrowsErrorAsync(try await SUT_FOLDER.resourceFolderURL)
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SNIPPET.singleContentElements.count, 2)
   XCTAssertEqual(SNIPPET.folderedContentElements.count, 0)
   XCTAssertEqual(SNIPPET.unfolderedContentElements.count, 2)
   XCTAssertEqual(SNIPPET.folders.count, 0)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertFalse(SUT_FOLDER.isDeleted)
   XCTAssertNil(SUT_FOLDER.url)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertFalse(SUT.isDeleted)
   XCTAssertEqual (SUT.snippet, SNIPPET)
   XCTAssertNil (SUT.folder)
   XCTAssertNil (SUT2.folder)
   XCTAssertEqual(SUT.tag, "MOVED SUT")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, SNIPPET.id?.uuidString)
   
  }
  
   //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: [SNIPPET])
  
 }//test...
 
 //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved async from source snippet to destination snippet FOLDER this object finishes in correct context and underlying file storage state. The source Folder (if Any) is auto deleted with empty file folder as empty folder or as an only contained element folder.
 
 final func test_when_SINGLE_content_element_MOVED_from_source_snippet_to_destination_FOLDER() async throws {
  
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
   //CREATE SOURCE SNIPPET...
  let SOURCE_SNIPPET = try await model.create(persist: PERSISTED,
                                              objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SOURCE_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                  in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                   in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let DEST_SNIPPET = try await model.create(persist: PERSISTED,
                                            objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Destination Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let DEST_FOLDER = try await DEST_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Destination Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
   // ASSERT BEFORE MOVE!
  
  let SUT_FOLDER_URL = await modelMainContext.perform { SUT_FOLDER.url }
  
  XCTAssertNotNil(SUT_FOLDER_URL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SOURCE_SNIPPET.id?.uuidString)
  }
  
  
   //ACTION...
  try await SUT.move(to: DEST_FOLDER, persist: PERSISTED) { $0.tag = "MOVED SUT" }
  
  
   //ASSERT...
  let SOURCE_resourceURL = try await SOURCE_SNIPPET.resourceSnippetURL
   //XCTAssertNotNil(SOURCE_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SOURCE_resourceURL.path))
  
  let DEST_resourceURL = try await DEST_SNIPPET.resourceSnippetURL
   //XCTAssertNotNil(DEST_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: DEST_resourceURL.path))
  
  XCTAssertFalse(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  await XCTAssertThrowsErrorAsync(try await SUT_FOLDER.resourceFolderURL)
  
   //  let FOLDER_resourceURL = try await SUT_FOLDER.resourceFolderURL
   //  XCTAssertNil(FOLDER_resourceURL)
   //  XCTAssertTrue(FileManager.default.fileExists(atPath: FOLDER_resourceURL.path))
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertNotNil(SUT_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.count, 1)
   XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.first, SUT2)
   XCTAssertEqual(DEST_SNIPPET.singleContentElements.count, 1)
   XCTAssertEqual(DEST_SNIPPET.folderedContentElements.count, 1)
   XCTAssertEqual(DEST_FOLDER.folderedElements.count, 1)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertTrue(SUT_FOLDER.isDeleted)
   XCTAssertNil(SUT_FOLDER.url)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertFalse(SUT.isDeleted)
   XCTAssertEqual (SUT.snippet, DEST_SNIPPET)
   XCTAssertEqual (SUT.folder, DEST_FOLDER)
   XCTAssertNil (SUT2.folder)
   XCTAssertEqual(SUT.tag, "MOVED SUT")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, DEST_FOLDER.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast(2).last, DEST_SNIPPET.id?.uuidString)
   
  }
  
   //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: [SOURCE_SNIPPET, DEST_SNIPPET])
  
 }//test...
 
 
  //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved async from source snippet to source snippet FOLDER this object finishes in correct context and underlying file storage state. The source Folder (if Any) is auto deleted with empty file folder as empty folder or as an only contained element folder.
 
 final func test_when_SINGLE_content_element_MOVED_from_source_snippet_to_the_same_SNIPPET_FOLDER() async throws {
  
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
   //CREATE SOURCE SNIPPET...
  let SNIPPET = try await model.create(persist: PERSISTED,
                                              objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT = try await SNIPPET.createSingle(persist: PERSISTED,
                                           in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SNIPPET.createSingle(persist: PERSISTED,
                                            in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let DEST_FOLDER = try await SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Destination Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
   // ASSERT BEFORE MOVE!
  
  let SUT_FOLDER_URL = await modelMainContext.perform { SUT_FOLDER.url }
  
  XCTAssertNotNil(SUT_FOLDER_URL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
  }
  
  
   //ACTION...
  try await SUT.move(to: DEST_FOLDER, persist: PERSISTED) { $0.tag = "MOVED SUT" }
  
  
   //ASSERT...
  let SOURCE_resourceURL = try await SNIPPET.resourceSnippetURL
  XCTAssertTrue(FileManager.default.fileExists(atPath: SOURCE_resourceURL.path))
  
  
  XCTAssertFalse(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  await XCTAssertThrowsErrorAsync(try await SUT_FOLDER.resourceFolderURL)
  
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SNIPPET.singleContentElements.count, 2)
   XCTAssertEqual(SNIPPET.unfolderedContentElements.count, 1)
   XCTAssertEqual(SNIPPET.folderedContentElements.count, 1)
   XCTAssertEqual(DEST_FOLDER.folderedElements.count, 1)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertTrue(SUT_FOLDER.isDeleted)
   XCTAssertNil(SUT_FOLDER.url)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertFalse(SUT.isDeleted)
   XCTAssertEqual (SUT.snippet, SNIPPET)
   XCTAssertEqual (SUT.folder, DEST_FOLDER)
   XCTAssertNil (SUT2.folder)
   XCTAssertEqual(SUT.tag, "MOVED SUT")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, DEST_FOLDER.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
   
  }
  
   //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: [SNIPPET])
  
 }//test...
 
 //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved  from source snippet to destination snippet multiple times async this object finishes in correct context and underlying file storage state.
 
 final func test_when_SINGLE_content_element_MOVED_MULTIPLE_times_among_Snippets() async throws {
  
  //ARRANGE...
 
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let N_SNIPPETS = Int.random(in: 20...100)
  
   //CREATE A SET OF HOMOGENOUS SNIPPETS...
  let SNIPPETS = try await model.create(persist: PERSISTED,
                                        objectType: NMPhotoSnippet.self,
                                        objectCount: N_SNIPPETS){ [ unowned self ] in
   $0.enumerated().forEach{ $0.element.nameTag = "Snippet - \($0.offset)"}
   SUTS.append(contentsOf: $0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SOURCE_SNIPPET = try XCTUnwrap(SNIPPETS.randomElement())
  
  let SUT_FOLDER = try await SOURCE_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                  in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
 // ASSERT BEFORE MOVE!
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT.folder?.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SUT.snippet?.id?.uuidString)
  }
  
  
  //ACTION...
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   SNIPPETS.filter{ $0 != SOURCE_SNIPPET }.shuffled().forEach { (DEST_SNIPPET) -> () in
    
    let nameTag =  modelMainContext.performAndWait { DEST_SNIPPET.nameTag ?? "" }
    
    group.addTask {
      try await SUT.move(to: DEST_SNIPPET, persist: PERSISTED) { $0.tag = "MOVED TO \(nameTag)" }
    }
   
   
   }
   
   try await group.waitForAll()
   
  }//group...
  
 
  //ASSERT AFTER...
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertNotNil(SUT_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   let DEST_SNIPPET = try XCTUnwrap(SUT.snippet)
   XCTAssertTrue(SOURCE_SNIPPET.singleContentElements.isEmpty)
   XCTAssertEqual(DEST_SNIPPET.singleContentElements.count, 1)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertNil (SUT.folder)
   XCTAssertEqual(SUT.tag, "MOVED TO \(DEST_SNIPPET.nameTag ?? "")")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, DEST_SNIPPET.id?.uuidString)
   
  }
  
  //try await storageRemoveHelperAsync(for: SNIPPETS)
  
 }//test...
 
  //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved within its Parent Snippet between folders multiple times async this object finishes in correct context and underlying file storage state.
 
 final func test_when_SINGLE_content_element_MOVED_MULTIPLE_times_among_its_Snippet_FOLDERS() async throws {
  
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let N_FOLDERS = Int.random(in: 20...100)
  
   //CREATE A SET OF HOMOGENOUS SNIPPETS...
  let SNIPPET = try await model.create(persist: PERSISTED,
                                       objectType: NMPhotoSnippet.self){ [ unowned self ] in
   
   $0.nameTag = "Parent Snippet"
   SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDERS = try await SNIPPET.createFolders(N_FOLDERS, persist: PERSISTED){ [ unowned self ] in
   $0.enumerated().forEach{ $0.element.tag = "Folder - \($0.offset)"}
   SUTS.append(contentsOf: $0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT_FOLDER = try XCTUnwrap(SUT_FOLDERS.randomElement())
  
  let SUT = try await SNIPPET.createSingle(persist: PERSISTED,
                                           in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
   // ASSERT BEFORE MOVE!
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
  }
  
  
   //ACTION...
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   SUT_FOLDERS.filter{ $0 != SUT_FOLDER }.shuffled().forEach { (DEST_FOLDER) -> () in
    
    let nameTag =  modelMainContext.performAndWait { DEST_FOLDER.tag ?? "" }
    
    group.addTask {
     try await SUT.move(to: DEST_FOLDER, persist: PERSISTED) { $0.tag = "MOVED TO \(nameTag)" }
    }
    
    
   }
   
   try await group.waitForAll()
   
  }//group...
  
  
   //ASSERT AFTER...
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertNotNil(SUT_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SNIPPET.singleContentElements.count, 1)
   XCTAssertEqual(SNIPPET.folderedContentElements.count, 1)
   XCTAssertEqual(SNIPPET.unfolderedContentElements.count, 0)
   XCTAssertEqual(SNIPPET.folders.count, 1)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertNotNil (SUT.folder)
   XCTAssertEqual(SUT.tag, "MOVED TO \(SUT.folder?.tag ?? "")")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, SUT.folder?.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
   
  }
  
   //try await storageRemoveHelperAsync(for: SNIPPETS)
  
 }//test...
 
 
 
}//final class NMSnippetsManipulationAsyncTests...
