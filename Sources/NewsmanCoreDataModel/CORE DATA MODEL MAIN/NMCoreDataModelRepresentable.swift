import CoreData

@available(iOS 14.0, *)
public protocol NMCoreDataModelRepresentable where Self: NSManagedObject
{
 var coreDataModel: NMCoreDataModel? { get set }
}

