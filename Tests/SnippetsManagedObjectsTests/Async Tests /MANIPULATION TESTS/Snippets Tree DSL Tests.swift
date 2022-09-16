 
 
//MARK: TEST DSL SNIPPET & CONTENT

import NewsmanCoreDataModel
import XCTest

@available(iOS 15.0, macOS 12.0, *)
extension NMSnippetsManipulationAsyncTests {
 
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
  
 }//test case...
 

}//extension NMSnippetsManipulationAsyncTests{...}
