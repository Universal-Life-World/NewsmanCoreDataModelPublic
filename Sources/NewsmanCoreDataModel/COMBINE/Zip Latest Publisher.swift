
import Combine
import Foundation

extension Publisher {
 typealias BufferStrategy<Context> = Publishers.TimeGroupingStrategy<Context> where Context: Scheduler
 
 func zipLatest<Second: Publisher, Context: Scheduler>(with other: Second,
                                                       strategyFirst: BufferStrategy<Context>,
                                                       strategySecond: BufferStrategy<Context>) -> AnyPublisher<(Self.Output, Second.Output), Self.Failure>
 where Self.Failure == Second.Failure
 {
  collect(strategyFirst)
   .compactMap{$0.last}
   .zip(other.collect(strategySecond).compactMap{$0.last})
   .eraseToAnyPublisher()
 }
 
 func zipLatest<Second: Publisher, Context: Scheduler>(with other: Second,
                                                       strategyFirst: BufferStrategy<Context>) -> AnyPublisher<(Self.Output, Second.Output), Self.Failure>
 where Self.Failure == Second.Failure
 {
  collect(strategyFirst)
   .compactMap{$0.last}
   .zip(other)
   .eraseToAnyPublisher()
 }
 
 
 
 
 func zipLatest<Second: Publisher>(with other: Second,
                                   timeStride: RunLoop.SchedulerTimeType.Stride) -> AnyPublisher<(Self.Output, Second.Output), Self.Failure>
 where Self.Failure == Second.Failure
 {
  collect(.byTime(RunLoop.main, timeStride))
   .compactMap{$0.last}
   .zip(other)
   .eraseToAnyPublisher()
 }
 
 func zipLatest<Second: Publisher>(with other: Second) -> AnyPublisher<(Self.Output, Second.Output), Self.Failure>
 where Self.Failure == Second.Failure {
  let lastSub = PassthroughSubject<Output, Failure>()
  let sub = subscribe(lastSub)
  
  return lastSub.last()
   .zip(other.handleEvents(receiveOutput:{_ in
    lastSub.send(completion: .finished)
    sub.cancel()
   })).flatMap {
    zipLatest(with: other).prepend($0)
   }
   .eraseToAnyPublisher()
  
 }
}
