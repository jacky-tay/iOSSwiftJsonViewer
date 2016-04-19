//
//  JSONViewerViewController.swift
//  JSONViewer
//
//  Created by Jacky Tay on 8/04/16.
//  Copyright © 2016 Jacky Tay. All rights reserved.
//

import UIKit

let JSONViewerViewControllerIdentifier = "JSONViewerViewController"

public class JSONViewerViewController: UIViewController {
   
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet weak var tableView: UITableView!
   
   var jsonArray: JSONArray?
   var jsonObject: JSONObject?
   var searchText: String?
   private var cellHeightDict = [NSIndexPath : CGFloat]()
   private var keyWidth:CGFloat = 120
   
   public class func getViewController() -> JSONViewerViewController? {
      let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: JSONViewerViewController.self))
      let viewController = storyboard.instantiateViewControllerWithIdentifier(JSONViewerViewControllerIdentifier) as? JSONViewerViewController
      
      return viewController
   }
   
   public class func getViewController(jsonString: String) -> JSONViewerViewController? {
      let viewController = getViewController()
      if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
         let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
         if let array = json as? Array<AnyObject> {
            viewController?.jsonArray = JSONArray(content: array, section: nil)
         }
         else if let dictionary = json as? Dictionary<String, AnyObject> {
            let object = JSONObject(content: dictionary, section: nil)
            viewController?.jsonObject = object
         }
      }
      return viewController
   }
   
   override public func viewDidLoad() {
      super.viewDidLoad()
      if let searchText = searchText where !searchText.isEmpty {
         searchBar.text = searchText
         searchBar(searchBar, textDidChange: searchText)
      } else {
         filterBySearch(nil)
      }
   }
   
   public override func viewDidAppear(animated: Bool) {
      super.viewDidAppear(animated)
      if let seletedIndex = tableView.indexPathForSelectedRow {
         tableView.deselectRowAtIndexPath(seletedIndex, animated: true)
      }
   }
   
   func filterBySearch(searchText: String?) {
      jsonArray?.filterBySearch(searchText)
      jsonObject?.filterBySearch(searchText)
      
      let font = UIFont.systemFontOfSize(14)
      let allUniqueKeys = Set(jsonObject?.getAllKeys(false) ?? jsonArray?.getAllKeys(false) ?? [])
      let allKeyWidth = allUniqueKeys.map { ($0 + " :").calculateTextSize(nil, height: nil, font: font).width }
      keyWidth = allKeyWidth.maxElement() ?? 120.0
      tableView.reloadData()
   }
}

extension JSONViewerViewController: UITableViewDataSource {
   
   public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      var section = 1
      if let array = jsonArray where (array.display.first is JSONArray || array.display.first is JSONObject) {
         section = array.display.count
      }
      return section
   }
   
   public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      var count = jsonObject?.display.count ?? 0
      if let array = jsonArray where array.display.count > section {
         // if item at section is a JSON object, then display it as seperated section
         if let object = array.display[section] as? JSONObject {
            count = object.display.count
         } else if let subArray = array.display[section] as? JSONArray {
            count = subArray.display.count
         } else {
            count = array.display[section] is NSNull ? 1 : array.display.count
         }
      }
      return count == 0 ? 1 : count
   }
   
   public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      var key = Searchable(value: "")
      var value: Searchable? = nil
      
      if let dictionary = jsonObject where dictionary.display.count > indexPath.row {
         key = dictionary.display[indexPath.row].searchableKey
         value = dictionary.display[indexPath.row].searchableValue
      } else if let array = jsonArray where array.display.count > indexPath.section {
         if let dictionary = array.display[indexPath.section] as? JSONObject where dictionary.display.count > indexPath.row {
            key = dictionary.display[indexPath.row].searchableKey
            value = dictionary.display[indexPath.row].searchableValue
         } else if let jsonValue = array.display[indexPath.row] as? Searchable {
            key = Searchable(value: String(format: "Item %i", jsonValue.index ?? 0))
            value = jsonValue
         } else if let subArray = array.display[indexPath.section] as? JSONArray where subArray.display.count > indexPath.row {
            if let jsonValue = subArray.display[indexPath.row] as? Searchable {
               key = Searchable(value: String(format: "Item %i", jsonValue.index ?? 0))
               value = jsonValue
            }
         }
      }
      if value != nil {
         let cell = tableView.dequeueReusableCellWithIdentifier(JSONItemTableViewCellIdentifier, forIndexPath: indexPath)
         cellHeightDict[indexPath] = (cell as? JSONItemTableViewCell)?.updateContent(key, value: value, keyWidth: keyWidth, width: UIScreen.mainScreen().bounds.width) ?? 44.0
         return cell
      } else {
         cellHeightDict[indexPath] = 44.0
         return tableView.dequeueReusableCellWithIdentifier(JSONItemNoResultTableViewCellIdentifier, forIndexPath: indexPath)
      }
   }
   
   public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      var title = navigationItem.title ?? "Section"
      if let array = jsonArray where array.display.count > section {
         if let object = array.display[section] as? JSONObject {
            title = String(format: "%@ %i", title, object.section ?? 0)
         } else if let subArray = array.display[section] as? JSONArray {
            title = String(format: "%@ %i", title, subArray.section ?? 0)
         }
      } else {
         return nil
      }
      return title
   }
   
   public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return cellHeightDict[indexPath] ?? 44.0
   }
}

extension JSONViewerViewController: UITableViewDelegate {
   
   public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      if let viewController = JSONViewerViewController.getViewController() {
         var key = ""
         var value: AnyObject? // JSON child
         
         if let dictionary = jsonObject where dictionary.display.count > indexPath.row {
            key = dictionary.display[indexPath.row].key
            value = dictionary.display[indexPath.row].value
         } else if let array = jsonArray where array.display.count > indexPath.section {
            if let object = array.display[indexPath.section] as? JSONObject where object.display.count > indexPath.row {
               key = object.display[indexPath.row].key
               value = object.display[indexPath.row].value
            }
         }
         
         if let array = value as? JSONArray {
            viewController.jsonArray = array
         } else if let dictionary = value as? JSONObject {
            viewController.jsonObject = dictionary
         } else {
            value = nil
         }
         
         if value != nil {
            viewController.title = key
            viewController.searchText = searchBar.text
            navigationController?.pushViewController(viewController, animated: true)
         } // if value != nil
      } // if let viewController, cell
   }
}

extension JSONViewerViewController: UISearchBarDelegate {
   public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
      filterBySearch(nil)
      searchBar.text = nil
      searchBar.resignFirstResponder()
   }
   
   public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
      searchBar.resignFirstResponder()
   }
   
   public func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
      searchBar.showsCancelButton = true
   }
   
   public func searchBarTextDidEndEditing(searchBar: UISearchBar) {
      searchBar.showsCancelButton = false
   }
   
   public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
      filterBySearch(searchText)
   }
}

extension JSONViewerViewController: JSONFilterViewControllerDelegate {
   func userFilterResult(keys: [String]) {
      
   }
}
