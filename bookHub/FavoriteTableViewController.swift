//
//  FavoriteTableViewController.swift
//  bookHub
//
//  Created by student on 10/27/21.
//

import UIKit

class FavoriteTableViewController: UITableViewController {
    
    var items = [BookInfo]()
    var selectedBook = BookInfo()
    var favoritesOnly = [BookInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 237.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        // start with empty array
        favoritesOnly = []
        if Favorites.sharedInstance.isGuest {
            print("isGuest: \(Favorites.sharedInstance.isGuest)")
        } else {
            let url = URL(string: "https://raw.githubusercontent.com/jvergara24/bookHub/main/booksbooks.json")

            guard url != nil else {
                return
            }

            if url != nil {
                parseData(url: url!)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesOnly.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 126
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteIdentifier", for: indexPath)

        let imageLabel = cell.viewWithTag(3) as! UIImageView
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let authorLabel = cell.viewWithTag(2) as! UILabel

        titleLabel.text = favoritesOnly[indexPath.row].title
        authorLabel.text = favoritesOnly[indexPath.row].author
        
        let imageUrl = favoritesOnly[indexPath.row].imageLink
        URLSession.shared.dataTask(with: imageUrl, completionHandler: {(data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                imageLabel.image = UIImage(data: data!)
            }
        }).resume()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = favoritesOnly[indexPath.row]
        self.performSegue(withIdentifier: "favoriteToBook", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favoriteToBook" {
            let bookView = segue.destination as! BookViewController
            bookView.selectedBook = selectedBook
        }
    }

    func parseData(url: URL) {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let downloadedData = data {
                self.decodeData(downloadedData: downloadedData)
            } else if let error=error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func decodeData(downloadedData: Data) {
        do {
            let decoder = JSONDecoder()
            let downloadedInfo = try decoder.decode(Array<BookInfo>.self, from: downloadedData)
            self.items = downloadedInfo

            DispatchQueue.main.async {
                self.showFavoritesOnly()
            }
        } catch {
            print("ERROR while decoding JSON!")
        }
    }
    
    // to delete cells
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            favoritesOnly.remove(at: indexPath.row)
            Favorites.sharedInstance.favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
            // have to update text file when swiping to delete
            // join Favorites.sharedInstance.favorites to writable string
            let joined = Favorites.sharedInstance.favorites.joined(separator: "\n")
            // set file name to "{username}.txt" (created during registration)
            let file = "\(Favorites.sharedInstance.username).txt"
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                let fileURL = dir.appendingPathComponent(file)
                // will replace the contents of "{username}.txt"
                do {
                    try joined.write(to: fileURL, atomically: false, encoding: .utf8)
                } catch {
                    print("Error writing to file")
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func showFavoritesOnly() {
        for book in items {
            if Favorites.sharedInstance.favorites.contains(book.title){
                favoritesOnly.append(book)
            }
        }
        self.tableView.reloadData()
    }
    
    
}
