
import Foundation
import Combine

public final class NMNetworkWaiterMock: NSObject, NMNetworkMonitorProtocol
{
 override public init() { super.init() }
 
 public var monitorPublisher: AnyPublisher<Void, Never>
 {
  NotificationCenter.default.publisher(for: .networkDidBecomeAvailableMock, object: nil)
   .first()
   .map{_ in }
   .eraseToAnyPublisher()
 }
 
}
