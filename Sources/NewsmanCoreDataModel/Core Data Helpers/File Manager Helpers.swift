import Foundation

public enum FileError: Error, LoggableError
{
 public var errorLogHeader: String
 {
  switch self
  {
   case .batchMoveFailures  (_): return "BATCH MOVE OPERATION MULTIPLE ERRORS OCCURED:"
   case .batchDeleteFailures(_): return "BATCH DELETE OPERATION MULTIPLE ERRORS OCCURED:"
   case .moveFailure(_ , _, _) : return "FILE MOVE FAILURE"
   case .deleteFailure(_, _)   : return "FILE DELETE FAILURE"
  }
 }//var errorLogHeader...
 
 public var errorLogMessage: String
 {
  let jointErrorMaker: ([URL: Error], String) -> String =
  {errorDict, message in
   return errorDict.enumerated().map
   {
    "[\($0.0 + 1)] \(message): \($0.1.key) WITH FILE SYSTEM MESSAGE <\($0.1.value.localizedDescription)>"
   }.joined(separator: "\n")
  }
  
  switch self
  {
   case .batchMoveFailures   (let errorDict):
    return jointErrorMaker(errorDict, "FILE MOVE FAILURE FROM URL")
   case .batchDeleteFailures (let errorDict):
    return jointErrorMaker(errorDict, "FILE DELETE FAILURE AT URL")
   case .moveFailure(let fromURL, let toURL, let message):
    return "FROM URL: [\(fromURL)] TO: [\(toURL)] WITH FILE SYSTEM MESSAGE <\(message)>"
   case .deleteFailure(let atURL, let message):
    return "AT URL: [\(atURL)] WITH FILE SYSTEM MESSAGE <\(message)>"
  }
 } // var errorLogMessage:...
 
 
 public var debugDescription: String { return errorLogHeader + "\n" + errorLogMessage}

 public var description: String { return debugDescription}
 
 case batchMoveFailures([URL: Error])
 case batchDeleteFailures([URL: Error])
 case moveFailure(from: URL, to: URL, message: String)
 case deleteFailure(at: URL, message: String)
 
}

public extension FileManager
{
 static func moveItemOnDisk (from sourceURL: URL,
                             to destinationURL: URL,
                             completion: @escaping (Result<Void, Error>) -> ())
 {
  DispatchQueue.global(qos: .userInitiated).async
  {
   completion(Result{try FileManager.default.moveItem(at: sourceURL, to: destinationURL)})
  }
 }
 
 static func batchMoveItemsOnDisk(using urlPairs: [(from: URL, to: URL)],
                                  completionQueue: DispatchQueue = .main,
                                  completion: @escaping (Result<Void, FileError>) -> ())
 {
  let group = DispatchGroup()
  var errorURLs: [URL : Error] = [ : ]
  urlPairs.forEach
  {(sourceURL, destURL) -> () in
   group.enter()
   moveItemOnDisk(from: sourceURL, to: destURL)
   {result in
    defer { group.leave() }
    DispatchQueue.main.async
    {
     if case .failure(let error) = result { errorURLs[sourceURL] = error }
    }
   }
  }
  
  group.notify(queue: completionQueue)
  {
   completion(errorURLs.isEmpty ? .success(()): .failure(.batchMoveFailures(errorURLs)))
  }
  
 }//static func batchMoveItemsOnDisk..
 
 

 
 static func batchRemoveItemsFromDisk(using urls: [URL],
                                      completionQueue: DispatchQueue = .main,
                                      completion: @escaping (Result<Void, FileError>) -> ())
  
 {
  
  let group = DispatchGroup()
  var errorURLs: [URL : Error] = [ : ]
  
  urls.forEach{ deleteURL in
   group.enter()
   removeItemFromDisk(at: deleteURL)
   {result in
    defer { group.leave() }
    DispatchQueue.main.async
    {
     if case .failure(let error) = result { errorURLs[deleteURL] = error }
    }
   }
  }
  
  group.notify(queue: completionQueue)
  {
   completion(errorURLs.isEmpty ? .success(()): .failure(.batchDeleteFailures(errorURLs)))
  }
  
 }//static func batchRemoveItemsOnDisk..
 
 
 static func moveItemOnDisk (from sourceURL: URL, to destinationURL: URL) -> Result<Void, Error>
 {
  Result{try FileManager.default.moveItem(at: sourceURL, to: destinationURL)}
 }
 
 @available(iOS 15.0, macOS 12.0, *)
 static func moveItemOnDisk(from sourceURL: URL, to destinationURL: URL) async throws {
  try Task.checkCancellation()
  try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
 }
 
 @available(iOS 15.0, macOS 12.0, *)
 static func moveItemOnDisk(undoTargetURL: URL, to destinURL: URL) async throws {
  try Task.checkCancellation()
  
  try await FileManager.moveItemOnDisk(from: undoTargetURL, to: destinURL)
  
  await NMUndoSession.register {
   
   guard FileManager.default.fileExists(atPath: destinURL.path) else { return }
   guard FileManager.default.fileExists(atPath: undoTargetURL.deletingLastPathComponent().path) else { return }
   try await FileManager.moveItemOnDisk(from: destinURL, to: undoTargetURL)
   
  } with: {
   
   guard FileManager.default.fileExists(atPath: destinURL.deletingLastPathComponent().path) else { return }
   guard FileManager.default.fileExists(atPath: undoTargetURL.path) else { return }
   try await FileManager.moveItemOnDisk(from: undoTargetURL, to: destinURL)
   
  }
  
 }

 static func removeItemFromDisk (at url: URL, completion: @escaping (Result<Void, Error>) -> ()) {
  DispatchQueue.global(qos: .userInitiated).async {
   completion(Result{ try FileManager.default.removeItem(at: url) })
  }
 }
 
 

 static func removeItemFromDisk (at url: URL) -> Result<Void, Error> {
  Result{ try FileManager.default.removeItem(at: url) }
 }
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 static func removeItemFromDisk (at url: URL) async throws
 {
  try FileManager.default.removeItem(at: url) 
 }
 
 static func createDirectoryOnDisk(at url: URL, completion: @escaping (Result<Void, Error>) -> ())
 {
  DispatchQueue.global(qos: .userInitiated).async
  {
   completion(Result{ try FileManager.default.createDirectory(at: url,
                                                              withIntermediateDirectories: false,
                                                              attributes: nil) })
  }
 }
 
 static func createDirectoryOnDisk(at url: URL) -> Result<Void, Error>
 {
 
  Result{ try FileManager.default.createDirectory(at: url,
                                                  withIntermediateDirectories: false,
                                                  attributes: nil) }
 }
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 static func createDirectoryOnDisk(at url: URL) async throws {
  try Task.checkCancellation()
  try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
 }
 
 
 
 
}
