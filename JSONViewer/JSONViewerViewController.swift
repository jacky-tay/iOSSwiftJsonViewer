//
//  JSONViewerViewController.swift
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

let JSONViewerViewControllerIdentifier = "JSONViewerViewController"

public class JSONViewerViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var jsonArray: JSONArray?
    var jsonObject: JSONObject?
    var searchText: String?
    private var keyWidth:CGFloat = 120

    public class func getViewController() -> JSONViewerViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: JSONViewerViewController.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: JSONViewerViewControllerIdentifier) as? JSONViewerViewController

        return viewController
    }

    public class func getViewController(jsonString: String) -> JSONViewerViewController? {
        let viewController = getViewController()
        if let data = jsonString.data(using: .utf8) {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
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
        if let searchText = searchText, !searchText.isEmpty {
            searchBar.text = searchText
            searchBar(searchBar, textDidChange: searchText)
        } else {
            filterBySearch(searchText: nil)
        }
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let seletedIndex = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: seletedIndex, animated: true)
        }
    }

    func filterBySearch(searchText: String?) {
        _ = jsonArray?.filterBySearch(query: searchText)
        _ = jsonObject?.filterBySearch(query: searchText)

        let font = UIFont.systemFont(ofSize: 14)
        let allUniqueKeys = Set(jsonObject?.getAllKeys(includeSubLevel: false) ?? jsonArray?.getAllKeys(includeSubLevel: false) ?? [])
        let allKeyWidth = allUniqueKeys.map { ($0 + " :").calculateTextSize(width: nil, height: nil, font: font).width }
        keyWidth = allKeyWidth.max() ?? 120.0
        tableView.reloadData()
    }
}

extension JSONViewerViewController: UITableViewDataSource {

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var section = 1
        if let array = jsonArray, (array.display.first is JSONArray || array.display.first is JSONObject) {
            section = array.display.count
        }
        return section
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = jsonObject?.display.count ?? 0
        if let array = jsonArray, array.display.count > section {
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

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var key = Searchable(value: "" as AnyObject)
        var value: Searchable? = nil

        if let dictionary = jsonObject, dictionary.display.count > indexPath.row {
            key = dictionary.display[indexPath.row].searchableKey
            value = dictionary.display[indexPath.row].searchableValue
        }
        else if let array = jsonArray, array.display.count > indexPath.section {
            if let dictionary = array.display[indexPath.section] as? JSONObject, dictionary.display.count > indexPath.row {
                key = dictionary.display[indexPath.row].searchableKey
                value = dictionary.display[indexPath.row].searchableValue
            }
            else if let jsonValue = array.display[indexPath.row] as? Searchable {
                key = Searchable(value: String(format: "Item %i", jsonValue.index ?? 0) as AnyObject)
                value = jsonValue
            }
            else if let subArray = array.display[indexPath.section] as? JSONArray, subArray.display.count > indexPath.row {
                if let jsonValue = subArray.display[indexPath.row] as? Searchable {
                    key = Searchable(value: String(format: "Item %i", jsonValue.index ?? 0) as AnyObject)
                    value = jsonValue
                }
            }
        }
        if value != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: JSONItemTableViewCellIdentifier, for: indexPath)
            (cell as? JSONItemTableViewCell)?.updateContent(key: key, value: value, keyWidth: keyWidth, width: UIScreen.main.bounds.width)
            return cell
        }
        else {
            return tableView.dequeueReusableCell(withIdentifier: JSONItemNoResultTableViewCellIdentifier, for: indexPath)
        }
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = navigationItem.title ?? "Section"
        if let array = jsonArray, array.display.count > section {
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
}

extension JSONViewerViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = JSONViewerViewController.getViewController() {
            var key = ""
            var value: AnyObject? // JSON child

            if let dictionary = jsonObject, dictionary.display.count > indexPath.row {
                key = dictionary.display[indexPath.row].key
                value = dictionary.display[indexPath.row].value
            }
            else if let array = jsonArray, array.display.count > indexPath.section {
                if let object = array.display[indexPath.section] as? JSONObject, object.display.count > indexPath.row {
                    key = object.display[indexPath.row].key
                    value = object.display[indexPath.row].value
                }
            }

            if let array = value as? JSONArray {
                viewController.jsonArray = array
            }
            else if let dictionary = value as? JSONObject {
                viewController.jsonObject = dictionary
            }
            else {
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
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterBySearch(searchText: nil)
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterBySearch(searchText: searchText)
    }
}

extension JSONViewerViewController: JSONFilterViewControllerDelegate {
    func userFilterResult(keys: [String]) {
        
    }
}
