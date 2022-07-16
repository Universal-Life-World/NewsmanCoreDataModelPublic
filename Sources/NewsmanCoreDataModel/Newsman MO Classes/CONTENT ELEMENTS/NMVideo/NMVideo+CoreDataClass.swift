//
//  NMVideo+CoreDataClass.swift
//  NewsmanCoreDataModel
//


import Foundation
import CoreData

@objc(NMVideo) public class NMVideo: NMBaseContent {}

extension NMVideo: NMUndoManageable {}

@available(iOS 15.0, macOS 12.0, *)
extension NMVideo: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
}

extension NMVideo: NMContentElement{
 
 public typealias Snippet = NMVideoSnippet
 public typealias Folder = NMVideoFolder
 
 @objc(container) public var snippet: NMVideoSnippet? { videoSnippet }
 @objc public var folder: NMVideoFolder? { videoFolder }
 

}

