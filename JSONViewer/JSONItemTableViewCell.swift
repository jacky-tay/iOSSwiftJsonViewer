//
//  JSONItemTableViewCell.swift
//  JSONViewer
//
//  Created by Jacky Tay on 8/04/16.
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

import UIKit

let JSONItemNoResultTableViewCellIdentifier = "JSONItemNoResultTableViewCell"
let JSONItemTableViewCellIdentifier = "JSONItemTableViewCell"

public class JSONItemTableViewCell: UITableViewCell {
   
   @IBOutlet weak var keyLabel: UILabel!
   @IBOutlet weak var valueLabel: UILabel!
   @IBOutlet weak var keyWidthConstraints: NSLayoutConstraint!
   
   func updateContent(key: Searchable, value: Searchable?, keyWidth: CGFloat, width: CGFloat) -> CGFloat {
      if !key.searchRanges.isEmpty {
         displayValue(keyLabel, defaultTextColor: UIColor.darkGrayColor(), displayText: key.description + " :", ranges: key.searchRanges)
      } else {
         keyLabel.text = key.description + " :"
      }
      keyWidthConstraints.constant = keyWidth
      
      selectionStyle = .None
      accessoryType = .None
      
      let tap = "Tap to view more"
      if value?.value is NSNull {
         valueLabel.text = "<NULL>"
      } else if value?.value is JSONArray || value?.value is JSONObject || value?.value is Array<AnyObject> || value?.value is Dictionary<String, AnyObject> {
         valueLabel.text = tap
         selectionStyle = .Default
         accessoryType = .DisclosureIndicator
      } else if let displayText = value?.description, ranges = value?.searchRanges where !ranges.isEmpty {
         displayValue(valueLabel, defaultTextColor: UIColor.darkTextColor(), displayText: displayText, ranges: ranges)
      } else {
         valueLabel.text = value?.value?.description ?? "<NULL>"
      }
      
      var recommandedHeight: CGFloat = 44.0
      if let text = valueLabel.text where text != tap {
         recommandedHeight = text.calculateTextSize(width - keyWidth - 24.0, height: nil, font: valueLabel.font).height + 27.0
      }
      return recommandedHeight
   }
   
   private func displayValue(label: UILabel, defaultTextColor: UIColor, displayText: String, ranges: [NSRange]) {
      let attributedString = NSMutableAttributedString(string: displayText, attributes: [NSForegroundColorAttributeName : defaultTextColor])
      ranges.forEach {
         attributedString.addAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSBackgroundColorAttributeName: tintColor.colorWithAlphaComponent(0.5)], range: $0)
      } // forEach
      label.attributedText = attributedString
   }
}
