//
//  NowPlayingViewController.swift
//  Flix
//
//  Created by Cameryn Boyd on 6/21/17.
//  Copyright © 2017 Cameryn Boyd. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movies : [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    var filteredMovies: [[String: Any]] = []
    
    
    
    let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
        // handle cancel response here. Doing nothing will dismiss the view.
    }
//    // add the cancel action to the alertController
//    alertController.addAction(cancelAction)
//    
//    // create an OK action
//    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
//        // handle response here.
//    }
//    // add the OK action to the alert controller
//    alertController.addAction(OKAction)
//    
//    present(alertController, animated: true) {
//    // optional code for what happens after the alert controller has finished presenting
//    }
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        fetchMovies()
        searchBar.delegate = self
        //filteredMovies = movies
        tableView.delegate = self
        
//        let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
//            // handle cancel response here. Doing nothing will dismiss the view.
//        }
//        // add the cancel action to the alertController
//        alertController.addAction(cancelAction)
//        
//        // create an OK action
//        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
//            // handle response here.
//        }
//        // add the OK action to the alert controller
//        alertController.addAction(OKAction)
//        
//        present(alertController, animated: true) {
//            // optional code for what happens after the alert controller has finished presenting
//        }
//
//        
    }
    
    

    
    
    
    
    
    func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchMovies()
    }

    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: url) { (data, respnse, error) in
            //this will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try!JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.filteredMovies = movies
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
                
            }
        }
        task.resume()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return movies.count
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = filteredMovies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        let posterURL = URL(string: baseURLString + posterPathString)!
        print("redcieved the URL")
    
        cell.posterImageView.af_setImage(withURL: posterURL)
        
        //cell.textLabel?.text = filteredMovies[indexPath.row] as? String
//        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searched")
        if searchText.isEmpty{
            print("empty")
            filteredMovies = movies
        }
        
        else {
            print("\(searchText)")
            filteredMovies = movies.filter{ (movie:[String:Any]) -> Bool in
                let title = movie["title"] as! String
                print("\(title)")
                return title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                
            }
            print(filteredMovies)
        }
        
//        filteredMovies = searchText.isEmpty ? movies : movies.filter { (item: [String: Any]) -> Bool in
//            // If dataItem matches the searchText, return true to include it
//            return (item["title"] as! String).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        
//            cell.textLabel?.text = filteredMovies[indexPath.row] as? String
        
        
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    

    

}
