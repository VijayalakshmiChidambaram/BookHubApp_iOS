//
//  ResourcesViewController.swift
//  bookHub
//
//  Created by student on 10/3/21.
//

import UIKit

class ResourcesViewController: UIViewController {
    
    @IBOutlet weak var bookCover: UIImageView!
    
    //
    
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var selectedBook = BookInfo()

    override func viewDidLoad() {
        super.viewDidLoad()
        bookTitleLabel.text = selectedBook.title
        isbnLabel.text = selectedBook.isbn
        authorLabel.text = selectedBook.author
        
        // get image url from info
        let imageUrl = selectedBook.imageLink
        // next, download the data
        URLSession.shared.dataTask(with: imageUrl, completionHandler: {(data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                self.bookCover.image = UIImage(data: data!)
            }
        }).resume()

        configureItems()
    }
    
    @objc func bookmark(){
        print("bookmark pressed")
        if Favorites.sharedInstance.isGuest {
            createAlert(title: "Sign in required", msg: "Please sign in to use the bookmark feature")
        } else if (Favorites.sharedInstance.favorites.contains(selectedBook.title)){
            createAlert(title: "Duplicate Bookmark", msg: "The selected book is already in your wishlist!")
        } else {
            // append bookmarked book (title only) to favorites
            Favorites.sharedInstance.favorites.append(selectedBook.title)
            // join Favorites.sharedInstance.favorites to writable string
            let joined = Favorites.sharedInstance.favorites.joined(separator: "\n")
            // set file name to "{username}.txt" (created during registration)
            let file = "\(Favorites.sharedInstance.username).txt"
            print("file name: " + file)
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                let fileURL = dir.appendingPathComponent(file)
                // will replace the contents of "{username}.txt"
                do {
                    try joined.write(to: fileURL, atomically: false, encoding: .utf8)
                } catch {
                    print("Error writing to file")
                }
                
                // reading - testing
                do {
                    let text = try String(contentsOf: fileURL, encoding: .utf8)
                    let arr = text.split(whereSeparator: \.isNewline)
                    print("test arr: " + "\(arr)")
                } catch {
                    print("Error reading from file")
                }
            }
            createAlert(title: "Bookmarked", msg: "This book was successfully added to your wishlist!")
        }
    }
    
    func createAlert(title: String, msg: String) {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.hidesBackButton = true
    }
    
    private func configureItems(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "bookmark"),
            style: .done,
            target: self,
            action: #selector(bookmark))
    }

    @IBAction func amazonButton(_ sender: UIButton) {
        UIApplication.shared.open(selectedBook.amazon_link, options: [:], completionHandler: nil)
    }

    @IBAction func ebayButton(_ sender: UIButton) {
        UIApplication.shared.open(selectedBook.ebay_link, options: [:], completionHandler: nil)
    }
    
  
    @IBAction func ebooksButton(_ sender: UIButton) {
        UIApplication.shared.open(selectedBook.ebooks_link, options: [:], completionHandler: nil)
    }
    
    @IBAction func goodreadsButton(_ sender: UIButton) {
        UIApplication.shared.open(selectedBook.goodreads_link, options: [:], completionHandler: nil)
    }
}
