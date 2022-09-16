
import NewsmanCoreDataModel
import XCTest

@available(iOS 15.0, macOS 12.0, *)
extension NMSnippetsManipulationAsyncTests {
 internal final func beforeUndoStatesAssertions(undoManager: NMUndoManager,
                                                sessionCount: Int) async throws {
  
   //ASSERT BEFORE UNDO...
  await XCTAssertFalseAsync  (await NMUndoManager.registeredManagers.isEmpty)
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
  
  await XCTAssertEqualAsync (await undoManager.sessionCount, sessionCount)
  await XCTAssertFalseAsync (await undoManager.currentUndo!.isEmpty)
  await XCTAssertFalseAsync (await undoManager.currentUndo!.isExecuted)
  await XCTAssertFalseAsync (await NMUndoSession.hasOpenSession)
  
 }
 
 internal final func undoRedoStatesAssertions(undoManager: NMUndoManager,
                                              sessionCount: Int,
                                              executedUndoCount: Int,
                                              executedRedoCount: Int) async throws {
  
  let undoRedoDiff = executedUndoCount - executedRedoCount
  
  XCTAssertTrue(undoRedoDiff >= 0 )
  XCTAssertGreaterThanOrEqual(sessionCount,  executedUndoCount)
  
  await XCTAssertFalseAsync  (await NMUndoManager.registeredManagers.isEmpty)
  await XCTAssertNilAsync    (await NMUndoSession.current)
  await XCTAssertFalseAsync  (await undoManager.isEmpty)
  await XCTAssertNotNilAsync (await undoManager.topUndo)      //The same state always!
  await XCTAssertNotNilAsync (await undoManager.bottomUndo)   //The same state always!
  await XCTAssertFalseAsync  (await NMUndoSession.hasOpenSession) //No open sessions per se!
  await XCTAssertEqualAsync  (await undoManager.sessionCount, sessionCount)
  
  await XCTAssertTrueIfAsync  (await undoManager.canUndo, if:  undoRedoDiff < sessionCount)
  await XCTAssertFalseIfAsync (await undoManager.canUndo, if:  undoRedoDiff == sessionCount)
  
  await XCTAssertTrueIfAsync  (await undoManager.canRedo, if:  undoRedoDiff > 0  )
  await XCTAssertFalseIfAsync (await undoManager.canRedo, if:  undoRedoDiff == 0 )
  
  await XCTAssertEqualAsync (try await undoManager.executedUndoCount, undoRedoDiff)
  await XCTAssertEqualAsync (try await undoManager.executedRedoCount, executedRedoCount)
  
  await XCTAssertEqualAsync (try await undoManager.unexecutedRedoCount, undoRedoDiff)
  await XCTAssertEqualAsync (try await undoManager.unexecutedUndoCount, sessionCount - undoRedoDiff)
  
  await XCTAssertNilIfAsync    (await undoManager.currentUndo, if: sessionCount == undoRedoDiff)
  await XCTAssertNotNilIfAsync (await undoManager.currentUndo, if: sessionCount >  undoRedoDiff)
  
  await XCTAssertEqualIfAsync (await undoManager.topUndo,
                               await undoManager.bottomUndo,  if: sessionCount == 1)
  
  await XCTAssertNotEqualIfAsync (await undoManager.topUndo,
                                  await undoManager.bottomUndo,  if: sessionCount > 1)
  
  
  try await XCTAssertNilIfAsync (try await undoManager.lastUnexecutedUndo,   if: undoRedoDiff == sessionCount)
  try await XCTAssertNilIfAsync (try await undoManager.firstUnexecutedUndo,  if: undoRedoDiff == sessionCount)
  
  try await XCTAssertEqualIfAsync (try await undoManager.lastExecutedUndo,
                                   await undoManager.bottomUndo, if: undoRedoDiff == sessionCount )
  
  try await XCTAssertEqualIfAsync (try await undoManager.firstExecutedUndo,
                                   await undoManager.topUndo, if: undoRedoDiff == sessionCount )
  
  try await XCTAssertNotNilIfAsync (try await undoManager.lastUnexecutedUndo, if: undoRedoDiff < sessionCount)
  try await XCTAssertNotNilIfAsync (try await undoManager.firstUnexecutedUndo, if: undoRedoDiff < sessionCount)
  
  try await XCTAssertNotNilIfAsync (try await undoManager.lastExecutedUndo,  if: undoRedoDiff == sessionCount)
  try await XCTAssertNotNilIfAsync (try await undoManager.firstExecutedUndo, if: undoRedoDiff == sessionCount)
  
  try await XCTAssertNotNilIfAsync (try await undoManager.lastExecutedUndo,
                                    if:  undoRedoDiff > 1 && undoRedoDiff < sessionCount)
  
  try await XCTAssertNotNilIfAsync (try await undoManager.firstExecutedUndo,
                                    if:  undoRedoDiff > 1 && undoRedoDiff < sessionCount)
  
  
  await XCTAssertNilIfAsync    (await undoManager.currentUndo, if: undoRedoDiff == sessionCount)
  await XCTAssertNotNilIfAsync (await undoManager.currentUndo, if: undoRedoDiff < sessionCount)
  
  await XCTAssertNotEqualIfAsync (await undoManager.topUndo, await undoManager.bottomUndo, if: sessionCount > 1 )
  
  await XCTAssertEqualAllIfAsync({ await undoManager.topUndo },
                                 { await undoManager.bottomUndo },
                                 { try await undoManager.lastExecutedUndo },
                                 if: sessionCount == 1 && undoRedoDiff == 1)
  
  await XCTAssertEqualAllIfAsync({ await undoManager.topUndo },
                                 { await undoManager.bottomUndo },
                                 { try await undoManager.lastUnexecutedUndo },
                                 if: sessionCount == 1 && undoRedoDiff == 0)
  
  try await XCTAssertEqualIfAsync (try await undoManager.lastUnexecutedUndo,
                                   try await undoManager.firstUnexecutedUndo,
                                   if: sessionCount == 2 && undoRedoDiff == 1 )
  
  try await XCTAssertEqualIfAsync (try await undoManager.lastExecutedUndo,
                                   try await undoManager.firstExecutedUndo,
                                   if: sessionCount == 2 && undoRedoDiff == 1  )
  
  try await XCTAssertEqualIfAsync  (await undoManager.topUndo,
                                    try await undoManager.lastUnexecutedUndo,
                                    if: undoRedoDiff < sessionCount )
  
  try await XCTAssertEqualIfAsync  (await undoManager.bottomUndo,
                                    try await undoManager.lastExecutedUndo,
                                    if: undoRedoDiff < sessionCount && sessionCount > 1)
  
  
 }
}
