//
//  NMText+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMText) public class NMText: NMBaseContent{ }

extension NMText: NMUndoManageable{}

@available(iOS 15.0, macOS 12.0, *)
extension NMText: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
}

extension NMText: NMContentElement {
 
 public typealias Folder = NMTextFolder
 public typealias Snippet = NMTextSnippet
 
 @objc(container) public var snippet: NMTextSnippet? { textSnippet }
 @objc public var folder: NMTextFolder?   { textFolder }
 
}

//extension NMText {
// public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
//}
