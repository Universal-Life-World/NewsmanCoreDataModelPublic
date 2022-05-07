//
//  NMVideoFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMVideoFolder)
public class NMVideoFolder: NMBaseContent, NMSnippetContained {
 public var snippetID: UUID? { videoSnippet?.id }
 
 
}
