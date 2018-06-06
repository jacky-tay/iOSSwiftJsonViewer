//
//  Searchable.swift
//  JSONViewer
//
//  Created by Jacky Tay on 5/06/18.
//  Copyright © 2018 Jacky Tay. All rights reserved.
//

import Foundation

class Searchable: CustomStringConvertible {
    
    var value: Any?
    var searchRanges = [Int]()
    var index: Int?
    var len = 0
    
    init(value: AnyObject?, index: Int? = nil) {
        self.value = value
        self.index = index
    }
    
    var description: String {
        return (value as? AnyObject)?.description ?? "null"
    }
    
    func isSearchable(query: String?) -> Bool {
        searchRanges.removeAll()
        len = query?.count ?? 0
        guard let query = query else {
            return false
        }
        
        searchRanges = description.indicesOf(query)
        
        return searchRanges.count > 0
    }
}

