
import Foundation
import Combine

@available(iOS 13.0, *)
public final class NMNetworkWaiterMock: NSObject, NMNetworkMonitorProtocol
{
 private var networkSubscription: AnyCancellable?

 public func waitForNetwork() async {
  await withCheckedContinuation{ (c: CheckedContinuation<Void, Never>) -> () in
   networkSubscription = monitorPublisher.sink { [ unowned self ] in
    c.resume()
    networkSubscription?.cancel()
   }
  }
 }
 
 override public init() { super.init() }
 
 public var monitorPublisher: AnyPublisher<Void, Never>
 {
  NotificationCenter.default.publisher(for: .networkDidBecomeAvailableMock, object: nil)
   .first()
   .map{_ in }
   .eraseToAnyPublisher()
 }
 
}
