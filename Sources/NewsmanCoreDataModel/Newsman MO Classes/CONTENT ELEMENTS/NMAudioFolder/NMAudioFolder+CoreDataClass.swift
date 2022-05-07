//
//  NMAudioFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMAudioFolder)
public class NMAudioFolder: NMBaseContent, NMSnippetContained {
 public var snippetID: UUID? { audioSnippet?.id }
 

}
