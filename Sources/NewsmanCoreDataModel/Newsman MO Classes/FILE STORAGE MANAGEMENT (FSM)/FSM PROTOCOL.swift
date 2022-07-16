
import Foundation
import CoreData

public protocol NMFileStorageManageable where Self: NSManagedObject {
 var id: UUID? { get }
 var url: URL? { get }
 var recoveryURL: URL? { get }
 var fileManagerTask: Task<Void, Error>? { get set }
 func fileManagerTaskGroup() async throws
 
}






