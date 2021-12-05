//
//  SearchTableViewController.swift
//  bookHub
//
//  Created by student on 10/26/21.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    let searchController = UISearchController()

    var bookList = [BookInfo]()
    var filteredBooks = [BookInfo]()
    var selectBook = BookInfo()
    var filterbook = BookInfo()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 237.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        let url = URL(string: "https://raw.githubusercontent.com/jvergara24/bookHub/main/booksbooks.json")

        guard url != nil else {
            return
        }
        
        if url != nil {
            parseData(url: url!)
        }
        initSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.hidesBackButton = true
    }
    
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext = true
                
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.scopeButtonTitles = ["All", "Fantasy", "History", "Science", "Comedy", "Horror"]
        searchController.searchBar.placeholder = "Search books"
        searchController.searchBar.delegate = self
        searchController.searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
            return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if(searchController.isActive)
        {
            print("222222222",filteredBooks.count)
            print("222222222",filterbook)
            if(filteredBooks.count == 0) {
                print("no result")
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No Result Found."
                noDataLabel.textColor     = UIColor.black
                noDataLabel.font = UIFont(name:"BodoniSvtyTwoITCTT-Book", size: 25.0)
                noDataLabel.textAlignment = .center
                self.tableView.backgroundView  = noDataLabel
                self.tableView.backgroundColor = UIColor(hue: 0.1528, saturation: 0.14, brightness: 0.94, alpha: 1.0)
                self.tableView.separatorStyle = .none
            }
            else if(filteredBooks.count > 0) {
                self.tableView.backgroundView = nil
            }
                return filteredBooks.count
        }
        self.tableView.backgroundView = nil
        return bookList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 126
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "searchToBook", sender: self)

    }
    
    // pass data to book view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToBook" {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let bookView = segue.destination as! BookViewController
                        
                        if(searchController.isActive)
                        {
                            selectBook = filteredBooks[indexPath.row]
                        }
                        else
                        {
                            selectBook = bookList[indexPath.row]
                        }
            

            bookView.selectedBook = selectBook
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
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
            self.bookList = downloadedInfo

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("ERROR while decoding JSON!")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchIdentifier", for: indexPath)
        let imageLabel = cell.viewWithTag(1) as! UIImageView
        let titleLabel = cell.viewWithTag(2) as! UILabel
        let genreLabel = cell.viewWithTag(3) as! UILabel
        let authorLabel = cell.viewWithTag(4) as! UILabel
        //let bookmarkItem = cell.viewWithTag(5) as! UIButton
        
        let thisBook: BookInfo!
                if(searchController.isActive)
                {
                    thisBook = filteredBooks[indexPath.row]
                }
                else
                {
                    thisBook = bookList[indexPath.row]
                }
        
        titleLabel.text = "\(thisBook.title)"
        
        let imageUrl = thisBook.imageLink
        
        URLSession.shared.dataTask(with: imageUrl, completionHandler: {(data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                imageLabel.image = UIImage(data: data!)
            }
        }).resume()
        

        
        genreLabel.text = "\(thisBook.genre[0]), \(thisBook.genre[1]), \(thisBook.genre[2])"
        authorLabel.text = "\(thisBook.author)"
        /*bookmarkItem.tag = indexPath.row
        bookmarkItem.addTarget(self, action: #selector(addToButton), for: .touchUpInside)*/
        return cell
    }
   /* @objc func addToButton(sender:UIButton) {
        let indexpath1 = IndexPath(row: sender.tag, section: 0)
        print("Button pressed")
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let indexpath1 = IndexPath(row: sender.tag, section: 0)
            print("navigate")
        if segue.identifier == "searchToFavorite" {
            //let indexPath = self.tableView.indexPathForSelectedRow!
            let bookView = segue.destination as! FavoriteTableViewController
                        
                        if(searchController.isActive)
                        {
                            selectBook = filteredBooks[indexpath1.row]
                        }
                        else
                        {
                            selectBook = bookList[indexpath1.row]
                        }
                        
                
            bookView.favoriteBook = selectBook
                        
            self.tableView.deselectRow(at: indexpath1, animated: true)
            
            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                //selectBook = bookList[indexPath.row]
                self.performSegue(withIdentifier: "searchToFavorite", sender: self)

            }
        }

    }
    }*/
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        
        filterForSearchTextAndScopeButton(searchText: searchText, scopeButton: scopeButton)
    }
    func filterForSearchTextAndScopeButton(searchText: String, scopeButton : String = "All")
        {
            filteredBooks = bookList.filter
            {
                search in
                let scopeMatch = (scopeButton == "All" ||
                                    search.genre[0].lowercased().contains(scopeButton.lowercased()) || search.genre[1].lowercased().contains(scopeButton.lowercased())||search.genre[2].lowercased().contains(scopeButton.lowercased()))
                if(searchController.searchBar.text != "")
                {
                    let searchTextMatch = (search.title.lowercased().contains(searchText.lowercased()) ||
                                            search.genre[0].lowercased().contains(searchText.lowercased())||search.genre[1].lowercased().contains(searchText.lowercased())||search.genre[2].lowercased().contains(searchText.lowercased()) || (search.author.lowercased().contains(searchText.lowercased())))
                    return scopeMatch && searchTextMatch
                }
                
                else
                {
                    return scopeMatch
                }
            }
            tableView.reloadData()
        }
}
