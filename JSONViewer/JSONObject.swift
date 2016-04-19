//
//  JSONObject.swift
//  JSONViewer
//
//  Created by Jacky Tay on 9/04/16.
//  Copyright © 2016 Jacky Tay. All rights reserved.
//

import Foundation

class Searchable: CustomStringConvertible {
   
   var value: AnyObject?
   var searchRanges = [NSRange]()
   var index: Int?
   
   init(value: AnyObject?, index: Int? = nil) {
      self.value = value
      self.index = index
   }
   
   var description: String {
      return value?.description ?? "null"
   }
   
   func isSearchable(query: String?) -> Bool {
      searchRanges.removeAll()
      guard let queryString = query else {
         return false
      }
      
      let text = description
      let len = text.characters.count
      var range = NSMakeRange(0, len)
      while range.location != NSNotFound {
         range = NSString(string: text).rangeOfString(queryString, options: .CaseInsensitiveSearch, range: range)
         if range.location != NSNotFound {
            searchRanges.append(range)
            let location = range.length + range.location
            range = NSMakeRange(location, len - location)
         }
      } // while

      return searchRanges.count > 0
   }
}

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
      self.searchableKey = Searchable(value: key)
      self.searchableValue = Searchable(value: value)
   }
   
   func searchConditionMeet(query: String?) -> Bool {
      let keyMeet = searchableKey.isSearchable(query)
      let valueMeet = searchableValue.isSearchable(query)
      return keyMeet || valueMeet
   }
}

class JSONObject {
   private var list = [JSONItem]()
   var display = [JSONItem]()
   var section: Int?
   
   init(content: Dictionary<String, AnyObject>, section: Int?) {
      list = content.map { JSONItem(key: $0, value: $1) }
      list.sortInPlace { $0.key < $1.key }
      display = list
      self.section = section
   }
   
   func filterBySearch(query: String?) -> Bool {
      if let query = query where !query.isEmpty {
         display = list.filter { $0.searchConditionMeet(query) }
      } else {
         list.forEach { $0.searchConditionMeet(nil) }
         display = list
      }
      return display.count > 0
   }
   
   func getAllKeys(includeSubLevel: Bool = true) -> [String] {
      var keys = [String]()
      if includeSubLevel {
         for item in list {
            if let object = item.value as? JSONObject {
               keys += object.getAllKeys(includeSubLevel)
            } else if let array = item.value as? JSONArray {
               keys += array.getAllKeys(includeSubLevel)
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
      if let query = query where !query.isEmpty {
         for item in list {
            if let jsonObject = item as? JSONObject where jsonObject.filterBySearch(query) {
               display.append(jsonObject)
            } else if let array = item as? JSONArray where array.filterBySearch(query) {
               display.append(array)
            } else if let jsonValue = item as? Searchable where jsonValue.isSearchable(query){
               display.append(jsonValue)
            }
         }
      }
      else {
         list.forEach { (item) in
            if let jsonObject = item as? JSONObject {
               jsonObject.filterBySearch(nil)
            } else if let array = item as? JSONArray {
               array.filterBySearch(nil)
            } else if let jsonValue = item as? Searchable {
               jsonValue.isSearchable(nil)
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
            allKeys += jsonObject.getAllKeys(includeSubLevel)
         } else if let jsonValue = $0 as? Searchable {
            allKeys.append(String("Item %i", jsonValue.index ?? 0))
         } else if let jsonArray = $0 as? JSONArray {
            allKeys += jsonArray.getAllKeys(includeSubLevel)
         }
      } // forEach
      return allKeys
   }
}

