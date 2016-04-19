//
//  StringExention.swift
//  JSONViewer
//
//  Created by Jacky Tay on 11/04/16.
//  Copyright © 2016 Jacky Tay. All rights reserved.
//

import Foundation

extension String {
   public func calculateTextSize(width: CGFloat?, height: CGFloat?, font: UIFont) -> CGSize {
      
      var sizeFound = false
      var _width: CGFloat = width ?? 0.0
      var _height: CGFloat = height ?? 0.0
      
      while !sizeFound {
         let size = CGSize(width: _width, height: _height)
         let rect = self.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
         sizeFound = abs((rect.size.height - _height) / rect.size.height) < 0.05
         _width = rect.size.width
         _height = rect.size.height
      }
      
      return CGSize(width: ceil(_width), height: ceil(_height))
   }
}
