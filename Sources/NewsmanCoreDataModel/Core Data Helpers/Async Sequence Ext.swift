

@available(iOS 15.0, macOS 12.0, *)
public extension AsyncSequence {
 var first: Self.Element?  {
  get async throws { try await first{_ in true } }
 }
}

