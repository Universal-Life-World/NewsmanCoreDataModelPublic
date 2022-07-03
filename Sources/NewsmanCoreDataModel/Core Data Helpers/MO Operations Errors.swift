import Foundation
import CoreData

public protocol LoggableError: Error, CustomDebugStringConvertible, CustomStringConvertible
{
 var errorLogHeader: String  { get }
 var errorLogMessage: String { get }
}

public extension LoggableError
{
 func log() { print(debugDescription) }
}


public enum ContextError {
 
 
 
 case performCnangesError(context: NSManagedObjectContext,
                          object: NSManagedObject,
                          entity: ContextEntityTypes,
                          operation: ContextOperationTypes,
                          blockError: Error)
 
 case contextSaveError (context: NSManagedObjectContext,
                        object: NSManagedObject,
                        entity: ContextEntityTypes,
                        operation: ContextOperationTypes)
 
 case noContext(object: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case isInvalid(object: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case cannotBeMoved(object: NSManagedObject,
                    entity: ContextEntityTypes,
                    destination: NSManagedObject,
                    operation: ContextOperationTypes)
 
 case noURL(object: NSManagedObject,
            entity: ContextEntityTypes,
            operation: ContextOperationTypes)
 
 case noID(object: NSManagedObject,
            entity: ContextEntityTypes,
            operation: ContextOperationTypes)
 
 case isDeleted(object: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case noContexts(objects: [NSManagedObject],
                 entity: ContextEntityTypes,
                 operation: ContextOperationTypes)
 
 case noSnippet(object: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case noFolder (object: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case inFolder (object: NSManagedObject,
                folder: NSManagedObject,
                entity: ContextEntityTypes,
                operation: ContextOperationTypes)
 
 case dataFileMoveFailure (to: URL,
                           object: NSManagedObject,
                           entity: ContextEntityTypes,
                           operation: ContextOperationTypes,
                           description: String)
 
 case dataDeleteFailure (at: URL,
                         object: NSManagedObject,
                         entity: ContextEntityTypes,
                         operation: ContextOperationTypes,
                         description: String)
 
 
 case emptyFolder (object: NSManagedObject,
                   entity: ContextEntityTypes,
                   operation: ContextOperationTypes)
 
 case dataFolderCreateFailure (at: URL,
                               object: NSManagedObject,
                               entity: ContextEntityTypes,
                               operation: ContextOperationTypes,
                               description: String)
 
 case multipleContextsInCollection(collection: [NSManagedObject])
 
}

extension ContextError: LoggableError {
 
 public var errorLogHeader: String { return "ERROR OCCURED WHEN" }
 
 public var errorLogMessage: String {
  switch self {
   case let .contextSaveError(context: moc, object: o, entity: e, operation: op):
    return "\(op + e): <\(o.objectID)> SAVE CONTEXT FAILED FOR: <\(moc)>."
   
   case let .noContext(object: o, entity: e, operation: op):
    return "\(op + e): <\(o.objectID)> \(e.rawValue) HAS NO ASSOCIATED CONTEXT!"
   
   case let .noURL(object: o, entity: e, operation: op):
    return "\(op + e): <\(o.objectID)> \(e.rawValue) HAS NO DATA URL!"
   
   case let .isDeleted(object: o, entity: e, operation: op):
    return "\(op + e): <\(o.objectID)> \(e.rawValue) IS MARKED DELETED FROM CONTEXT!"
   
   case let .noID(object: o, entity: e, operation: op):
    return "\(op + e): <\(o.objectID)> \(e.rawValue) HAS NO ID!"
   
   case let .noContexts(objects: os, entity: e, operation: op):
    return "\(op + e): <\(os.map{$0.objectID})> \(e.rawValue) HAVE NO ASSOCIATED CONTEXT!"
    
   case let .noSnippet(object: o, entity: e, operation: op):
    return "\(op + e): <\(o.objectID)> \(e.rawValue) HAS NO ASSOCIATED SNIPPET!"
   
   case let .noFolder(object: o, entity: e, operation: op):
    return "\(op + e): <\(o.objectID)> \(e.rawValue) IS NOT FOLDERED YET!"
   
   case let .inFolder(object: o, folder: f, entity: e, operation: op):
    return "\(op + e): <\(o.objectID)> \(e.rawValue) IS ALREADY FOLDERED INTO THIS FOLDER <\(f.objectID)>!"
   
   case let .dataFileMoveFailure(to: url, object: o, entity: e, operation: op, description: d):
    return "\(op + e): <\(o.objectID)> MOVING \(e.rawValue) DATA TO NEW <\(url)> FAILED WITH MESSAGE <<\(d)>>."
   
   case let .dataDeleteFailure(at: url, object: o, entity: e, operation: op, description: d):
    return "\(op + e): <\(o.objectID)> DELETING \(e.rawValue) DATA AT <\(url)> FAILED WITH MESSAGE <<\(d)>>."
  
   case let .emptyFolder(object: o, entity: e, operation: op):
    return "\(op + e): <\(o.objectID)> UNEXPECTED EMPTY FOLDER ENCOUNTERED!"
   
   case let .dataFolderCreateFailure(at: url, object: o, entity: e, operation: op, description: d):
    return "\(op + e): <\(o.objectID)> CREATING DATA FOLDER AT <\(url)> FAILED WITH MESSAGE <<\(d)>>."
   
   case let .performCnangesError(context: moc, object: o, entity: e, operation: op, blockError: err):
    return "\(op + e): <\(o.objectID)> PERFORM BLOCK CHANGES FAILED FOR: <\(moc)> WITH BLOCK ERROR <\(err.localizedDescription)>."
    
   case let .multipleContextsInCollection(collection: collection):
    return "MULTIPLE CONTEXTS ENCOUNTERED IN MODIFIED OBJECTS COLLECTION \(collection)"
    
   case let .isInvalid(object: o, entity: e, operation: op):
    return "\(e): <\(o.objectID)> IS INVALID FOR THIS CONTEXT OPERATION [\(op)])"
    
   case let .cannotBeMoved(object: o, entity: e, destination: d, operation: op):
    return "\(e): <\(o.objectID)> CANNOT BE MOVED INTO DESTINATION OBJECT \(d.objectID) \(op)"
  }
 }
 
 public var debugDescription: String { return errorLogHeader + " " + errorLogMessage }
 public var description:      String { return errorLogHeader + " " + errorLogMessage }
 
 
}
