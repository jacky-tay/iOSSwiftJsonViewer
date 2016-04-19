//
//  JSONItemTableViewCell.swift
//  JSONViewer
//
//  Created by Jacky Tay on 8/04/16.
//  Copyright © 2016 Jacky Tay. All rights reserved.
//

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
