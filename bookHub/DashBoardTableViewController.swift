//
//  DashBoardTableViewController.swift
//  bookHub
//
//  Created by student on 10/21/21.
//

import UIKit

struct BookInfo : Codable, Equatable{
    init(){
        title = ""
        author = ""
        genre = ["", "", ""]
        fiction = false
        imageLink = URL(string: "https://www.google.com")!
        language = ""
        goodreads_link = URL(string: "https://www.goodreads.com")!
        amazon_link = URL(string: "https://www.amazon.com")!
        ebay_link = URL(string: "https://www.ebay.com")!
        ebooks_link = URL(string: "https://www.ebooks.com/en-us/")!
        summary = ""
        pages = 0
        year = 1111
        isbn = ""
        rating = 0.0
    }
    let title: String
    let author: String
    let genre: [String]
    let fiction: Bool
    let language: String
    let imageLink: URL
    let goodreads_link: URL
    let amazon_link: URL
    let ebay_link: URL
    let ebooks_link: URL
    let summary: String
    let pages: Int
    let year: Int
    let isbn: String
    let rating: Double
}

func ==(lhs: BookInfo, rhs: BookInfo) -> Bool {
    return lhs.title == rhs.title
}

class DashBoardTableViewController: UITableViewController {
    
    var username = "default"
    var items = [BookInfo]()
    var selectedBook = BookInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 237.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        
        let file = "\(Favorites.sharedInstance.username).txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let fileURL = dir.appendingPathComponent(file)
            // read the array
            do {
                let favorites = try String(contentsOf: fileURL, encoding: .utf8)
                let arr = favorites.split(whereSeparator: \.isNewline)
                print("Arr from text file: " + "\(arr)")
                for item in arr {
                    if Favorites.sharedInstance.favorites.contains(String(item)){
                        // something
                        print("Book from txt file already in favorites")
                    } else {
                        Favorites.sharedInstance.favorites.append("\(item)")
                    }
                }
                print("Favorites: " + "\(Favorites.sharedInstance.favorites)")
            } catch {
                print("Error reading from file")
            }
        }
        // temporary end
        let url = URL(string: "https://raw.githubusercontent.com/jvergara24/bookHub/main/booksbooks.json")

        guard url != nil else {
            return
        }
        
        if url != nil {
            parseData(url: url!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.hidesBackButton = false
    }
        
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 126
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardCell",for:indexPath)
        let imageLabel = cell.viewWithTag(2) as! UIImageView
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let ratingLabel = cell.viewWithTag(3) as! UILabel
        
        titleLabel.text = items[indexPath.row].title
        ratingLabel.text = "\(items[indexPath.row].author),  \(items[indexPath.row].rating)"
        
        // get image url from info
        let imageUrl = items[indexPath.row].imageLink
        // next, download the data
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
    
    // when specific cell is clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = items[indexPath.row]
        self.performSegue(withIdentifier: "dashboardToBook", sender: self)
    }
    
    // pass data to book view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashboardToBook" {
            let bookView = segue.destination as! BookViewController
            bookView.selectedBook = selectedBook
        }
    }
    
    // we give one task to download the data
    func parseData(url: URL) {
        // initialize one task
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            // if download is successful, we try to decode it
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
            
            // reload table with the information
            DispatchQueue.main.async {
                self.showOnlyHighRatingBooks()
            }
        } catch {
            print("ERROR while decoding JSON!")
        }
    }
    
    func showOnlyHighRatingBooks() {
        var i = 0
        while i < self.items.count {
            if self.items[i].rating < 4.5 {
                self.items.remove(at: i)
            } else {
                i = i + 1
            }
        }
        self.tableView.reloadData()
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
