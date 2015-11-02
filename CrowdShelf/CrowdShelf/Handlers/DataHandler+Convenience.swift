//
//  DataHandler+Convenience.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 02/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

extension DataHandler {
    
    public class func getBooksInCrowdsForUser(userID: String, withCompletionHandler completionHandler: (([Book]) -> Void)) {
        
        /* Retrieve all the users crowds */
        DataHandler.getCrowdsWithParameters(["member": userID]) { (crowds) -> Void in
            
            var allBooks: [Book] = []
            
            var membersRetrieved = 0
            let memberIDs = Set(crowds.flatMap { $0.members })

            for memberID in memberIDs {
                
                DataHandler.getBooksWithParameters(["owner":memberID], andCompletionHandler: { (userBooks) -> Void in
                    allBooks = allBooks + userBooks
                    
                    membersRetrieved++
                    if membersRetrieved == memberIDs.count {
                        completionHandler(allBooks)
                    }
                })
            }
            
        }
    }
    
    public class func removeBookForUser(userID: String, withISBN ISBN: String, completionHandler: ((Bool)->Void)?) {
        DataHandler.getBooksWithParameters(["owner": userID, "isbn":ISBN]) { (books) -> Void in
            if let book = books.first {
                DataHandler.removeBook(book._id!, withCompletionHandler: { (isSuccess) -> Void in
                    completionHandler?(isSuccess)
                })
            }
        }
    }
    
    public class func getUserWithImage(userID: String, withCompletionHandler completionHandler: ((User?)->Void)) {
        self.getUser(userID) { (user) -> Void in
            if user == nil {
                return completionHandler(nil)
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let hash = user!.email
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    .lowercaseString
                    .md5()
                
                if let imageData = NSData(contentsOfURL: NSURL(string: "http://www.gravatar.com/avatar/\(hash)?d=retro")!) {
                    user?.image = UIImage(data: imageData)
                }
                
                completionHandler(user)
            })
        }
    }
    
    
    public class func addUserWithUsername(username: String, toCrowd crowdID: String, withCompletionHandler completionHandler: ((String?, Bool)->Void)?) {
        
        self.userForUsername(username) { (user) -> Void in
            if user == nil {
                completionHandler?(nil, false)
                return
            }
            
            self.sendRequestWithSubRoute("crowds/\(crowdID)/members/\(user!._id)", usingMethod: .PUT) { (result, isSuccess) -> Void in
                completionHandler?(user!._id, isSuccess)
            }
        }
    }
    
    public class func getMembersOfCrowd(crowd: Crowd, withCompletionHandler completionHandler: (([User]->Void))) {
        var users: [User] = []
        var results = 0
        
        crowd.members.forEach {
            DataHandler.getUserWithImage($0, withCompletionHandler: { (user) -> Void in
                results++
                if user != nil {
                    users.append(user!)
                }
                
                if results == crowd.members.count {
                    completionHandler(users)
                }
            })
        }
    }
    
    public class func getBooksInCrowd(crowd: Crowd, withCompletionHandler completionHandler: (([Book]->Void))) {
        
        var books: [Book] = []
        
        var usersRetrieved = 0
        for wrappedMemberID in crowd.members {
            DataHandler.getBooksWithParameters(["owner": wrappedMemberID], andCompletionHandler: { (memberBooks) -> Void in
                books = books + memberBooks
                usersRetrieved++
                if usersRetrieved == crowd.members.count {
                    completionHandler(books)
                }
            })
        }
    }
    
    public class func getTitleInformationForBooksWithParameters(parameters: [String: AnyObject]?, andCompletionHandler completionHandler: (([BookInformation])->Void)) {
        var titleInformationSet = Set<BookInformation>()
        
        DataHandler.getBooksWithParameters(parameters) { (books) -> Void in
            
            var booksRetrieved = 0
            books.forEach({ (book) -> () in
                
                DataHandler.informationAboutBook(book.isbn!, withCompletionHandler: { (titleInformation) -> Void in
                    if titleInformation.first != nil {
                        titleInformationSet.insert(titleInformation.first!)
                    }
                    
                    booksRetrieved++
                    if booksRetrieved == books.count {
                        completionHandler(titleInformationSet.map {$0})
                    }
                })
                
            })
        }
    }
    
    public class func getBooksWithInformationWithParameters(parameters: [String: AnyObject]?, andCompletionHandler completionHandler: (([Book])->Void)) {
        
        DataHandler.getBooksWithParameters(parameters) { (books) -> Void in
            if books.isEmpty {
                return completionHandler([])
            }
            
            for book in books {
                DataHandler.informationAboutBook(book.isbn!, withCompletionHandler: { (information) -> Void in
                    
                    information.forEach {
                        LocalDatabaseHandler.sharedInstance.addObject($0)
                    }
                    book.details = information.first
                    
                    completionHandler(books)
                })
            }
        }
    }
    
    /**
    Retrieves a list of all users that own a book matching the parameters
    
    - parameter parameters:         a dictionary with parameter used to filter the results
    - parameter completionHandler:  a closure to be called with the results of the request
    */
    
    public class func ownersOfBooksWithParameters(parameters: [String: AnyObject]?, withCompletionHandler completionHandler: (([User]) -> Void) ) {
        
        DataHandler.getCrowdsWithParameters(["member": User.localUser!._id]) { (userCrowds) -> Void in
            
            var memberIDs = Set<String>()
            userCrowds.forEach { crowd in
                memberIDs.unionInPlace(crowd.members)
            }
            
            DataHandler.getBooksWithParameters(parameters) { (books) -> Void in
                if books.isEmpty {
                    return completionHandler([])
                }
                
                let ownerIDs: Set<String> = Set(books.map {$0.owner!})
                
                DataHandler.usersWithCompletionHandler { users -> Void in
                    let owners = users.filter {ownerIDs.contains($0._id) && memberIDs.contains($0._id)}
                    
                    completionHandler(owners)
                }
            }
        }
    }
    
    /**
    Adds a user as renter of a random book that is available for rent, matches the provided isbn, and is owned by the specified user
    
    - parameter renterID:           ID of the renter
    - parameter ISBN:               international standard book number of the book to be rented
    - parameter ownerID:            ID of the owner
    - parameter completionHandler:  a closure to be called with the results of the request
    */
    public class func addRenter(renterID: String, toTitle isbn: String, withOwner ownerID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        DataHandler.getBooksWithParameters(["isbn": isbn, "owner":ownerID, "availableForRent": true]) { (books) -> Void in
            
            if books.isEmpty {
                completionHandler?(false)
                return
            }
            
            let randomBook = books[ Int(arc4random()) % books.count ]
            DataHandler.addRenter(renterID, toBook: randomBook._id!, withCompletionHandler: { (isSuccess) -> Void in
                completionHandler?(isSuccess)
            })
        }
    }
    
    public class func removeRenter(renterID: String, fromTitle isbn: String, withOwner ownerID: String, withCompletionHandler completionHandler: ((Bool)->Void)?) {
        DataHandler.getBooksWithParameters(["isbn": isbn, "owner":ownerID, "rentedTo": renterID]) { (books) -> Void in
            
            if books.isEmpty {
                completionHandler?(false)
                return
            }
            
            let randomBook = books[ Int(arc4random()) % books.count ]
            DataHandler.removeRenter(renterID, fromBook: randomBook._id!, withCompletionHandler: { (isSuccess) -> Void in
                completionHandler?(isSuccess)
            })
        }
    }
    
}