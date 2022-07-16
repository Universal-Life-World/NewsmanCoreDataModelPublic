//
//  NMAudio+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMAudio)
public class NMAudio: NMBaseContent{}

extension NMAudio: NMUndoManageable{}

@available(iOS 15.0, macOS 12.0, *)
extension NMAudio: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
}

extension NMAudio: NMContentElement{
 
 public typealias Snippet = NMAudioSnippet
 public typealias Folder = NMAudioFolder
 
 @objc(container) public var snippet: NMAudioSnippet? { audioSnippet }
 @objc(subcontainer) public var folder:  NMAudioFolder?  { audioFolder  }


 
}

