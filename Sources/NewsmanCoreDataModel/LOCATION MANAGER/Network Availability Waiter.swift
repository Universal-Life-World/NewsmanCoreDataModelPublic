import CoreLocation
import Foundation
import Combine
import RxSwift
import Network


public protocol NMNetworkMonitorProtocol
{
 init()
 var monitorPublisher: AnyPublisher<Void, Never> { get }
}

public final class NMNetworkWaiter: NSObject, NMNetworkMonitorProtocol
{
 private let pathMonitor = NWPathMonitor()
 private let monitorQueue = DispatchQueue(label: "NMNetworkMonitor.local.queue")
 
 public var monitorPublisher: AnyPublisher<Void, Never>
 {
  Future {[ unowned self ] promise in
   if self.pathMonitor.currentPath.status == .satisfied {
    promise(.success(()))
    return
   }
   
   self.pathMonitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
     promise(.success(()))
     self.pathMonitor.cancel()
    }
   }
   
   self.pathMonitor.start(queue: self.monitorQueue)
   
  }.eraseToAnyPublisher()
 }
 
 public override init ()
 {
  super.init()
 }
}
