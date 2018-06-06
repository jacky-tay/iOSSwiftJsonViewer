//
//  JSONObject.swift
//  JSONViewer
//
//  Created by Jacky Tay on 9/04/16.
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



class JSONItem {
    var key: String
    var value: AnyObject
    
    var searchableKey: Searchable
    var searchableValue: Searchable
    
    init(key: String, value: AnyObject) {
        self.key = key
        if let jsonArray = value as? Array<AnyObject> {
            self.value = JSONArray(content: jsonArray, section: nil)
        } else if let jsonObject = value as? Dictionary<String, AnyObject> {
            self.value = JSONObject(content: jsonObject, section: nil)
        } else {
            self.value = value
        }
        self.searchableKey = Searchable(value: key as AnyObject)
        self.searchableValue = Searchable(value: value)
    }
    
    func searchConditionMeet(query: String?) -> Bool {
        let keyMeet = searchableKey.isSearchable(query: query)
        let valueMeet = searchableValue.isSearchable(query: query)
        return keyMeet || valueMeet
    }
}

class JSONObject {
    private var list = [JSONItem]()
    var display = [JSONItem]()
    var section: Int?
    
    init(content: Dictionary<String, AnyObject>, section: Int?) {
        list = content.map { JSONItem(key: $0, value: $1) }
        list.sort { $0.key < $1.key }
        display = list
        self.section = section
    }
    
    func filterBySearch(query: String?) -> Bool {
        if let query = query, !query.isEmpty {
            display = list.filter { $0.searchConditionMeet(query: query) }
        } else {
            list.forEach { $0.searchConditionMeet(query: nil) }
            display = list
        }
        return display.count > 0
    }
    
    func getAllKeys(includeSubLevel: Bool = true) -> [String] {
        var keys = [String]()
        if includeSubLevel {
            for item in list {
                if let object = item.value as? JSONObject {
                    keys += object.getAllKeys(includeSubLevel: includeSubLevel)
                } else if let array = item.value as? JSONArray {
                    keys += array.getAllKeys(includeSubLevel: includeSubLevel)
                }
            } // for item
        } // includeSubLevel
        keys += list.map { $0.key }
        return keys
    }
}

class JSONArray {
    private var list = [AnyObject]()
    var display = [AnyObject]()
    var section: Int?
    
    init(content: Array<AnyObject>, section: Int?) {
        for item in content {
            if let dictionary = item as? Dictionary<String, AnyObject> {
                list.append(JSONObject(content: dictionary, section: list.count + 1))
            } else if item is NSNumber || item is Bool || item is String {
                list.append(Searchable(value: item, index: list.count + 1))
            } else if let array = item as? Array<AnyObject> {
                list.append(JSONArray(content: array, section: list.count + 1))
            }
        } // forEach
        display = list
        self.section = section
    }
    
    func filterBySearch(query: String?) -> Bool {
        display.removeAll()
        if let query = query, !query.isEmpty {
            for item in list {
                if let jsonObject = item as? JSONObject, jsonObject.filterBySearch(query: query) {
                    display.append(jsonObject)
                }
                else if let array = item as? JSONArray, array.filterBySearch(query: query) {
                    display.append(array)
                }
                else if let jsonValue = item as? Searchable, jsonValue.isSearchable(query: query){
                    display.append(jsonValue)
                }
            }
        }
        else {
            list.forEach { (item) in
                if let jsonObject = item as? JSONObject {
                    jsonObject.filterBySearch(query: nil)
                }
                else if let array = item as? JSONArray {
                    array.filterBySearch(query: nil)
                }
                else if let jsonValue = item as? Searchable {
                    jsonValue.isSearchable(query: nil)
                }
            } // forEach
            display = list
        }
        return display.count > 0
    }
    
    func getAllKeys(includeSubLevel: Bool = true) -> [String] {
        var allKeys = [String]()
        list.forEach {
            if let jsonObject = $0 as? JSONObject {
                allKeys += jsonObject.getAllKeys(includeSubLevel: includeSubLevel)
            }
            else if let jsonValue = $0 as? Searchable {
                allKeys.append("Item \(jsonValue.index ?? 0)")
            }
            else if let jsonArray = $0 as? JSONArray {
                allKeys += jsonArray.getAllKeys(includeSubLevel: includeSubLevel)
            }
        } // forEach
        return allKeys
    }
}

