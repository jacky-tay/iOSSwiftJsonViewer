//
//  StringExention.swift
//  JSONViewer
//
//  Created by Jacky Tay on 11/04/16.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Jacky Tay
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

extension String {
   public func calculateTextSize(width: CGFloat?, height: CGFloat?, font: UIFont) -> CGSize {
      
      var sizeFound = false
      var _width: CGFloat = width ?? 0.0
      var _height: CGFloat = height ?? 0.0
      
      while !sizeFound {
         let size = CGSize(width: _width, height: _height)
        let rect = self.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil)
         sizeFound = abs((rect.size.height - _height) / rect.size.height) < 0.05
         _width = rect.size.width
         _height = rect.size.height
      }
      
      return CGSize(width: ceil(_width), height: ceil(_height))
   }
}
