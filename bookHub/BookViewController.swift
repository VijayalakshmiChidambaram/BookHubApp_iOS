//
//  BookViewController.swift
//  bookHub
//
//  Created by student on 10/3/21.
//

import UIKit

class BookViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!

    var selectedBook = BookInfo()
    var fictionText = "Fiction"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "\(selectedBook.title)"
        authorLabel.text = "\(selectedBook.author), \(selectedBook.language)"
        
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
        
        if (selectedBook.fiction == true){
            fictionText = "Fiction"
        } else {
            fictionText = "Non-fiction"
        }
        
        genresLabel.text = "\(fictionText), \(selectedBook.genre[0]), \(selectedBook.genre[1]), \(selectedBook.genre[2])"
        publishDateLabel.text = "Published: \(String(selectedBook.year)) | Rating: \(String(selectedBook.rating)) | Pages: \(String(selectedBook.pages))"
        
        descriptionLabel.text = selectedBook.summary

        configureItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.hidesBackButton = true
//        self.navigationController?.navigationBar.isHidden = true
//        self.navigationItem.title = ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookToResources" {
            let resourcesView = segue.destination as! ResourcesViewController
            resourcesView.selectedBook = selectedBook
        }
    }
    
    @objc func navigateToResources(){
        self.performSegue(withIdentifier: "bookToResources", sender: self)
    }
    
    private func configureItems(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "book.closed"),
            style: .done,
            target: self,
            action: #selector(navigateToResources))
    }
    
    @IBAction func bookmarkBook(_ sender: Any) {
        print("bookmark pressed")
        //Favorites.sharedInstance.favorites.append(selectedBook.title)
        //print(Favorites.sharedInstance.favorites)
        // TEST '==' overload
//        if (Favorites.sharedInstance.books.count >= 2){
//            print("test: \(Favorites.sharedInstance.books[Favorites.sharedInstance.books.count - 1] == Favorites.sharedInstance.books[Favorites.sharedInstance.books.count - 2])")
//        }
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
}
