import XCTest

@available(iOS 13.0.0, *)
func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure @escaping () async throws -> T,
                             _ message: @autoclosure () -> String = "",
                             file: StaticString = #filePath,
                             line: UInt = #line, _ errorHandler: (_ error: Error) -> Void = { _ in }) async throws
{
 let result = await Task {try await expression()}.result
 try XCTAssertThrowsError(result.get(), message(), file: file, line: line, errorHandler)
}

@available(iOS 13.0.0, *)
func XCTAssertThrowsErrorAsync<T, E: Error>(_ expression: @autoclosure @escaping () async throws -> T,
                                  _ message: @autoclosure () -> String = "",
                                  file: StaticString = #filePath,
                                  line: UInt = #line, errorType: E.Type) async throws
{
 let result = await Task { try await expression() }.result
 
 try XCTAssertThrowsError(result.get(), message(), file: file, line: line){ XCTAssertTrue($0 is E) }
}
