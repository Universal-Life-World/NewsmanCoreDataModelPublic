
import CoreData

public final class JSONManagedObjectContextDecoder: JSONDecoder {
 public init(context: NSManagedObjectContext) {
  super.init()
  userInfo[.managedObjectContext] = context
 }
}

extension CodingUserInfoKey {
 public static let managedObjectContext = Self.init(rawValue: "managedObjectContext")!
 public static let modelBackgroundContextKey = Self.init(rawValue: "modelBackgroundContext")!
}
