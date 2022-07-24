import XCTest

@available(iOS 13.0.0, *)
func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure @escaping () async throws -> T,
                             _ message: @autoclosure () -> String = "",
                             file: StaticString = #filePath,
                             line: UInt = #line, _ errorHandler: (_ error: Error) -> Void = { _ in }) async {
 let result = await Task { try await expression() }.result
 XCTAssertThrowsError(try result.get(), message(), file: file, line: line, errorHandler)
}



@available(iOS 13.0.0, *)
func XCTAssertThrowsErrorAsync<T, E: Error>(_ expression: @autoclosure @escaping () async throws -> T,
                                  _ message: @autoclosure () -> String = "",
                                  file: StaticString = #filePath,
                                  line: UInt = #line, errorType: E.Type) async {
 let result = await Task { try await expression() }.result
 XCTAssertThrowsError(try result.get(), message(), file: file, line: line){ XCTAssertTrue($0 is E) }
}


@available(iOS 13.0.0, *)
func XCTAssertNilAsync(_ expression: @autoclosure @escaping () async throws -> Any?,
                  _ message: @autoclosure () -> String = "",
                  file: StaticString = #filePath,
                  line: UInt = #line) async {
 let result = await Task { try await expression() }.result

 XCTAssertNil(try result.get(), message(), file: file, line: line)
}

@available(iOS 13.0.0, *)
func XCTAssertNotNilAsync(_ expression: @autoclosure @escaping () async throws -> Any?,
                          _ message: @autoclosure () -> String = "",
                         file: StaticString = #filePath,
                         line: UInt = #line) async {
 let result = await Task { try await expression() }.result
 
 XCTAssertNotNil(try result.get(), message(), file: file, line: line)
}

@available(iOS 13.0.0, *)
func XCTAssertTrueAsync(_ expression: @autoclosure @escaping () async throws -> Bool,
                          _ message: @autoclosure () -> String = "",
                          file: StaticString = #filePath,
                          line: UInt = #line) async {
 let result = await Task { try await expression() }.result
 
 XCTAssertTrue(try result.get(), message(), file: file, line: line)
}

@available(iOS 13.0.0, *)
func XCTAssertFalseAsync(_ expression: @autoclosure @escaping () async throws -> Bool,
                        _ message: @autoclosure () -> String = "",
                        file: StaticString = #filePath,
                        line: UInt = #line) async {
 
 let result = await Task { try await expression() }.result
 XCTAssertFalse(try result.get(), message(), file: file, line: line)
}

@available(iOS 13.0.0, *)
func XCTAssertEqualAsync<T>(_ expression1: @autoclosure @escaping () async throws -> T,
                            _ expression2: @autoclosure @escaping () async throws -> T,
                            _ message: @autoclosure () -> String = "",
                            file: StaticString = #filePath,
                            line: UInt = #line) async where T : Equatable {
 
 let result1 = await Task { try await expression1() }.result
 let result2 = await Task { try await expression2() }.result
  
 XCTAssertEqual(try result1.get(), try result2.get(), message(), file: file, line: line)
 
}

typealias TAsyncExpression<T> = () async throws -> T

@available(iOS 13.0.0, *)
func XCTAssertEqualAllAsync<T>(_ expressions: TAsyncExpression<T>...,
                            message: @autoclosure () -> String = "",
                            file: StaticString = #filePath,
                            line: UInt = #line) async where T : Equatable {
 
 let result = await Task {
  try await withThrowingTaskGroup(of: T.self, returning: Bool.self){ group in
   
   for expression in expressions { group.addTask{ try await expression() } }
  
   let results: [T] = try await group.reduce(into: []){$0.append($1)}
   
   return zip(results, results.dropFirst()).allSatisfy{ $0.0 == $0.1 }
  }
 }.result
 
 XCTAssertTrue(try result.get(), message(), file: file, line: line)
 
}


@available(iOS 13.0.0, *)
func XCTAssertEqualAllAsync<T>(_ expressions: TAsyncExpression<T>...,
                               to expression: @autoclosure @escaping TAsyncExpression<T>,
                               message: @autoclosure () -> String = "",
                               file: StaticString = #filePath,
                               line: UInt = #line) async where T : Equatable {
 
 let result = await Task {
  try await withThrowingTaskGroup(of: T.self, returning: Bool.self){ group in
   
   let toResult = try await expression()
   
   for expression in expressions { group.addTask{ try await expression() } }
   
   let results: [T] = try await group.reduce(into: []){ $0.append($1) }
   
   return results.allSatisfy{ $0 == toResult }
  }
 }.result
 
 XCTAssertTrue(try result.get(), message(), file: file, line: line)
 
}

@available(iOS 13.0.0, *)
func XCTAssertEqualAllAsync<T>(_ expressions: TAsyncExpression<T>..., toConst: T,
                               message: @autoclosure () -> String = "",
                               file: StaticString = #filePath,
                               line: UInt = #line) async where T : Equatable {
 
 let result = await Task {
  try await withThrowingTaskGroup(of: T.self, returning: Bool.self){ group in
   
   for expression in expressions { group.addTask{ try await expression() } }
   
   let results: [T] = try await group.reduce(into: []){$0.append($1)}
   
   return results.allSatisfy{ $0 == toConst }
  }
 }.result
 
 XCTAssertTrue(try result.get(), message(), file: file, line: line)
 
}
