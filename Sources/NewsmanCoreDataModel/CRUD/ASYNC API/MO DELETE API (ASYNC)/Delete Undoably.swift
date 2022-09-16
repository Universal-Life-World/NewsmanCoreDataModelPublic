import CoreData

//MARK: Deletes codable & file storage manageable MO recoverably (with UNDO/REDO tasks) with children from its MO context & removes its underlying file storage directory from disk recoverably by moving it into temporary recovery directory. This method fully deserialises the the MO tree from JSON encoded data buffer. Results are not persisted in MOC by default.

@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable where Self: Codable & NMUndoManageable  {
 
 typealias TDeleteObjectRedoTask<Target> = @Sendable ( _ target: Target,
                                                       _ persist: Bool) async throws -> ()
 
 typealias TDeleteObjectUndoTask<Target> = @Sendable ( _ targetType: Target.Type,             //$0
                                                       _ data: Data,                           //$1
                                                       _ context: NSManagedObjectContext,      //$2
                                                       _ persist: Bool) async throws -> Target //$3
                                                                    
 
 
 static var deleteUndoTask: TDeleteObjectUndoTask<Self> {
  { try await $0.jsonDecoded(from: $1, persist: $3, using: $2)/*.withRecoveredUndoManager()*/ }
 }
 
 static var deleteRedoTask: TDeleteObjectRedoTask<Self> {
  { try await $0.delete(withFileStorageRecovery: true, persisted: $1) }
 }
 
 var managedObjectID: UUID {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .object, operation: .gettingObjectID)
   }
   
   return try await context.perform {
    guard let ID = self.id else {
     throw ContextError.noID(object: self, entity: .object, operation: .gettingObjectID)
    }
    return ID
   } //try await context.perform...
  } //get async throws...
 } //MO ID...
 
 
 static func registeredManagedObject(with id: UUID, with context: NSManagedObjectContext) -> Self? {
  context
   .registeredObjects
   .compactMap{ $0 as? Self }
   .first{ $0.id == id && $0.managedObjectContext != nil && $0.isDeleted == false }
 }
 
 static func existingManagedObject(with id: UUID, in context: NSManagedObjectContext) async throws -> Self? {
  try await context.perform {
   if let object = registeredManagedObject(with: id, with: context) { return object }
   let pred = NSPredicate(format: "SELF.id == %@", id as CVarArg )
   let fr = NSFetchRequest<Self>()
   fr.predicate = pred
   return try context.fetch(fr).first
  }
 }//public static func Existing MO...async from current MOC
 

 func deleteRecoverably(undo: @escaping TDeleteObjectUndoTask<Self> = Self.deleteUndoTask ,
                        redo: @escaping TDeleteObjectRedoTask<Self> = Self.deleteRedoTask,
                        persist: Bool = false ) async throws {
  
  try await withOpenUndoSession(of: self) {
   try await self._deleteRecoverably(undo: undo, redo: redo, persist: persist)
  }
 }
 
 
 fileprivate func _deleteRecoverably(undo: @escaping TDeleteObjectUndoTask<Self> = Self.deleteUndoTask ,
                                     redo: @escaping TDeleteObjectRedoTask<Self> = Self.deleteRedoTask,
                                     persist: Bool = false ) async throws {
  
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .deleteWithRecovery)
  }
  
  let objectID = try await self.managedObjectID       //fix MO ID  before delete!
  let objectData = try await self.jsonEncodedData     //fix MO JSON data before delete!
  let CDM = (self as? NMBaseSnippet)?.coreDataModel   //fix injected CDM from deleted Snippet!
  
  try await self.delete(withFileStorageRecovery: true, persisted: persist) //deletes from context with recovery!
  
  await NMUndoSession.register { [ weak CDM ] in
   let target = try await undo(Self.self, objectData, context, persist)
   (target as? NMBaseSnippet)?.coreDataModel = CDM //if recover snippet inject CDM into recovered one!
   
  } with: {
   
   guard let undeleted = try? await Self.existingManagedObject(with: objectID, in: context) else { return }
   try await redo(undeleted, persist)
  }
  
  
  
 }
 
}
