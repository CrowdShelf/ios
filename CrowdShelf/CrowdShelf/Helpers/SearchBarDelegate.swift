//
//  ReturnTextFieldDelegate.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class SearchBarDelegate: NSObject, UISearchBarDelegate {
    typealias SearchBarDelegateClosure = ((UISearchBar) -> Void)
    
    
    var onSearch: SearchBarDelegateClosure
    var onCancel: SearchBarDelegateClosure?
    var onClear: SearchBarDelegateClosure?
    var onChange: SearchBarDelegateClosure?
    var onBookmarksTapped: SearchBarDelegateClosure?
    var onResultsListTapped: SearchBarDelegateClosure?
    
    init(onSearch: SearchBarDelegateClosure) {
        self.onSearch = onSearch
        super.init()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        onSearch(searchBar)
    }
    
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        onBookmarksTapped?(searchBar)
    }
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        onResultsListTapped?(searchBar)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        onChange?(searchBar)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        onCancel?(searchBar)
    }
}
