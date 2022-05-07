//
//  NMVideo+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMVideo)
public class NMVideo: NMBaseContent, NMContainerContained {
 public var snippetID: UUID? { videoSnippet?.id }
 public var folderID: UUID?  { videoFolder?.id  }

}
