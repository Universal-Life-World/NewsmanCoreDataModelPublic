
import Combine
import Foundation


fileprivate final class ZipLatestWithSubscription<S: Subscriber, P1: Publisher, P2: Publisher>: Subscription
where S.Input == (P1.Output, P2.Output), P1.Failure == P2.Failure, S.Failure == P1.Failure {
 
 private var subscriber: S?
 
 private var sub1: AnyCancellable?
 
 private var last: P1.Output?
 
 private var sub2: AnyCancellable?
 
 private var buffer = [P2.Output]()
 
 
 let p1: P1
 let p2: P2
 
 private let bs = DispatchSemaphore(value: 1)
 
 init (subscriber: S, p1: P1, p2: P2){
  Swift.print(#function)
  self.subscriber = subscriber
  self.p1 = p1
  self.p2 = p2
   //subscribeAll()
 }
 
 private var finishedCount = 0
 private var allFinished = false
 
 private func complete(with result: Subscribers.Completion<S.Failure>){
  bs.wait()
  defer { bs.signal() }
  finishedCount += 1
  
  switch result {
   case .finished where finishedCount == 2: fallthrough
   case .failure(_):
    allFinished = true
    subscriber?.receive(completion: result)
    buffer.removeAll()
    
   default: break
    
  }
  
  
 }
 
 
 private func subscribeAll(){
  //Swift.print(#function)
  sub1 = p1.sink(receiveCompletion: complete){ [ unowned self ] in
   bs.wait()
   defer { bs.signal() }
   if allFinished { return }
   if buffer.isEmpty { last = $0 } else { _ = subscriber?.receive(($0, buffer.remove(at: 0))) }
   
   
  }
  
  sub2 = p2.sink(receiveCompletion: complete) { [ unowned self] in
   bs.wait()
   defer { bs.signal() }
   if allFinished { return }
   if last == nil { buffer.append($0) } else { _ = subscriber?.receive((last!, $0)) }
   
   
  }
 }
 
 func request(_ demand: Subscribers.Demand) {
//  Swift.print(#function)
  subscribeAll()
 }
 
 func cancel() {
  bs.wait()
  defer { bs.signal() }
  
  subscriber = nil
  sub1?.cancel()
  buffer.removeAll()
  sub2?.cancel()
  
 }
 
 
}


class ZipLatestFromWithPublisher<P1: Publisher, P2: Publisher>: Publisher where P1.Failure == P2.Failure
{
 
 typealias Output = (P1.Output, P2.Output)
 
 typealias Failure = P1.Failure
 
 var p1: P1
 var p2: P2
 
 init(latestFrom p1: P1, with p2: P2) {
  self.p1 = p1
  self.p2 = p2
 }
 
 func receive<S>(subscriber: S) where S : Subscriber, P1.Failure == S.Failure, (P1.Output, P2.Output) == S.Input {
  
  let sub = ZipLatestWithSubscription(subscriber: subscriber, p1: p1, p2: p2)
  subscriber.receive(subscription: sub)
 }
}

extension Publisher {
 
 func zip2Latest<P2: Publisher>(with second: P2) -> ZipLatestFromWithPublisher<Self, P2>
 where Self.Failure == P2.Failure{
  ZipLatestFromWithPublisher(latestFrom: self, with: second)
 }
 
}

