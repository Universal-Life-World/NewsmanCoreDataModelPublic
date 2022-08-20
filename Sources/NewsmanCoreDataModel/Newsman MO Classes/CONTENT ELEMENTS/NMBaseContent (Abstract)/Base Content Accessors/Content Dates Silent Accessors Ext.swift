
import Foundation

extension NMBaseContent {
 
 @NSManaged fileprivate var primitiveLastRatedTimeStamp: Date?
 public var silentLastRatedTimeStamp: Date? {
  get { primitiveLastRatedTimeStamp }
  set { primitiveLastRatedTimeStamp = newValue }
 }
 
 @NSManaged fileprivate var primitivePublishedTimeStamp: Date?
 public var silentPublishedTimeStamp: Date? {
  get { primitivePublishedTimeStamp }
  set { primitivePublishedTimeStamp = newValue }
 }
 
 @NSManaged fileprivate var primitiveTrashedTimeStamp: Date?
 public var silentTrashedTimeStamp: Date? {
  get { primitiveTrashedTimeStamp }
  set { primitiveTrashedTimeStamp = newValue }
 }
 
 @NSManaged fileprivate var primitiveArchivedTimeStamp: Date?
 public var silentArchivedTimeStamp: Date? {
  get { primitiveArchivedTimeStamp }
  set { primitiveArchivedTimeStamp = newValue }
 }

}
