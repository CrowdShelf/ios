//
//  ShelfTableViewCell.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 30/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

struct Shelf {
    let type: ShelfType
    
    /// All books in the shelf. Could contain invalidated objects
    private var allBooks: [Book] = []
    
    /// All valid books in the shelf
    var books: [Book] {
        get {
            /* Not sure if this should filter the content using the type filter, but it does force the returned books to match the shelf type. Which is probably a good thing? */
            return self.allBooks.filter(self.type.filter())
                                .filter {!$0.invalidated}
                                .sort {$0.0.isbn > $0.1.isbn}
        }
        set { self.allBooks = newValue }
    }
    
    var name: String {
        return type.rawValue
    }
    
    init(type: ShelfType, books: [Book] = []) {
        self.type = type
        self.books = books
    }
    
    
}

protocol ShelfTableViewCellDelegate {
    func showAllBooksForShelfTableViewCell(shelfTableViewCell: ShelfTableViewCell)
    func shelfTableViewCell(shelfTableViewCell: ShelfTableViewCell, didSelectBook book: Book)
}

class ShelfTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    var shelf: Shelf? {
        didSet {
            self.updateView()
        }
    }
    
    var delegate: ShelfTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var showAllButton: UIButton?
    
    override func awakeFromNib() {
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        self.updateView()
    }
    
    private func updateView() {
        self.collectionView?.reloadData()
        self.titleLabel?.text = self.shelf?.name

        self.showAllButton?.hidden = self.shelf?.books.isEmpty ?? true
    }
    
//    MARK: Collection View Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shelf != nil ? self.shelf!.books.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BookCell", forIndexPath: indexPath) as! CollectableCell
        cell.collectable = self.shelf!.books[indexPath.row]
        return cell
    }
    
//    MARK: Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.shelfTableViewCell(self, didSelectBook: self.shelf!.books[indexPath.row])
    }
    
//    MARK: Actions
    
    @IBAction func showAll(sender: UIButton) {
        self.delegate?.showAllBooksForShelfTableViewCell(self)
    }
}
