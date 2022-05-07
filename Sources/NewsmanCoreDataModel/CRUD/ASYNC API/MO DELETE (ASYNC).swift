import CoreData


@available(iOS 13.0,  *)
public extension NMFileStorageManageable {
 func delete()  {
  guard let context = managedObjectContext else { return }
  context.persist { [ unowned self ] () in
   context.delete(self)
  } handler: { result  in
    
  }
 }
}


@available(iOS 15.0, macOS 12.0, *)
public extension NMFileStorageManageable {
 func delete() async throws {
  guard let context = managedObjectContext else { return }
  try await context.perform { [ unowned self ] in
   context.delete(self)
   try context.save()
  }
 }
}
