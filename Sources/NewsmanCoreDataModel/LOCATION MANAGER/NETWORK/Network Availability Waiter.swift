import CoreLocation
import Foundation
import Combine
import RxSwift
import Network


@available(iOS 13.0.0, *)
public protocol NMNetworkMonitorProtocol {
 init()
 var monitorPublisher: AnyPublisher<Void, Never> { get }
 func waitForNetwork() async
}

@available(iOS 13.0, *)
public final class NMNetworkWaiter: NSObject, NMNetworkMonitorProtocol {
 public func waitForNetwork() async   {
  await withCheckedContinuation{ (c: CheckedContinuation<Void, Never>) -> () in
   if pathMonitor.currentPath.status == .satisfied {
    c.resume()
    return
   }
   
   pathMonitor.pathUpdateHandler = { [ unowned self ] path in
    if path.status == .satisfied {
     c.resume()
     pathMonitor.cancel()
    }
   }
   
   pathMonitor.start(queue: monitorQueue)
  }
 }
 
 private let pathMonitor = NWPathMonitor()
 private let monitorQueue = DispatchQueue(label: "NMNetworkMonitor.local.queue")
 
 public var monitorPublisher: AnyPublisher<Void, Never>
 {
  Future {[ unowned self ] promise in
   if pathMonitor.currentPath.status == .satisfied {
    promise(.success(()))
    return
   }
   
   pathMonitor.pathUpdateHandler = { [ unowned self ] path in
    if path.status == .satisfied {
     promise(.success(()))
     pathMonitor.cancel()
    }
   }
   
   pathMonitor.start(queue: monitorQueue)
   
  }.eraseToAnyPublisher()
 }
 
 public override init ()
 {
  super.init()
 }
}
