
import Foundation
#if !os(macOS)
import UIKit
#else
import AppKit
#endif

extension NMBaseContent {
#if !os(macOS)
 @NSManaged fileprivate var primitiveColorFlag: UIColor?
 public var silentColorFlag: UIColor? {
  get { primitiveColorFlag }
  set { primitiveColorFlag = newValue }
 }
 
 func decodeColorFlagSilenty(from container: KeyedDecodingContainer<CodingKeys>){
  if let colorComponents = try? container.decode([CGFloat]?.self, forKey: .colorFlag) {
   silentColorFlag = UIColor(red:   colorComponents.first ?? 0.0,
                             green: colorComponents.dropFirst().first ?? 0.0,
                             blue:  colorComponents.dropFirst(2).first ?? 0.0,
                             alpha: colorComponents.last ?? 0.0)
  }
 }
 
#else
 @NSManaged fileprivate var primitiveColorFlag: NSColor?
 public var silentColorFlag: NSColor? {
  get { primitiveColorFlag }
  set { primitiveColorFlag = newValue }
 }
 
 func decodeColorFlagSilenty(from container: KeyedDecodingContainer<CodingKeys>){
  if let colorComponents = try? container.decode([CGFloat]?.self, forKey: .colorFlag) {
   silentColorFlag = NSColor(red:   colorComponents.first ?? 0.0,
                             green: colorComponents.dropFirst().first ?? 0.0,
                             blue:  colorComponents.dropFirst(2).first ?? 0.0,
                             alpha: colorComponents.last ?? 0.0)
   
  }
 }
 
#endif
}
