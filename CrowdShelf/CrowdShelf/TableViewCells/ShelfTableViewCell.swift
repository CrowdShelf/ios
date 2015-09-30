//
//  ShelfTableViewCell.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 30/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

struct Shelf {
    let name: String
    var books: [Book]
    
    init(name: String, books: [Book] = []) {
        self.name = name
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
