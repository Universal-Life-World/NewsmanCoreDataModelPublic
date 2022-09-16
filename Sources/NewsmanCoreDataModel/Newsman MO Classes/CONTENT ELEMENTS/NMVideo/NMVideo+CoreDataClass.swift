//
//  NMVideo+CoreDataClass.swift
//  NewsmanCoreDataModel
//

import Foundation
import CoreData
import Combine

@objc(NMVideo)
public class NMVideo: NMBaseContent {}

@available(iOS 15.0, macOS 12.0, *)
extension NMVideo: NMUndoManageable {
 public var undoTargetOwner: NMUndoManageable? {
  get async {
   await managedObjectContext?.perform { [ unowned self ] in
    videoFolder ?? mixedFolder ?? videoSnippet ?? mixedSnippet
   }
  }
 }
 
 public var undoTargetOwnerPublisher: AnyPublisher<NMUndoManageable, Never> {
  
  let p1 = publisher(for: \.videoSnippet,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p2 = publisher(for: \.videoFolder,   options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p3 = publisher(for: \.mixedFolder,   options: [.new]).compactMap{ $0 as NMUndoManageable? }
  let p4 = publisher(for: \.mixedSnippet,  options: [.new]).compactMap{ $0 as NMUndoManageable? }
  
  return Publishers.Merge4(p1, p2, p3, p4).eraseToAnyPublisher()
 }
}

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

