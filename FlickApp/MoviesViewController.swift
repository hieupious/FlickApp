//
//  MoviesViewController.swift
//  FlickApp
//
//  Created by Hoang Trung Hieu on 3/8/16.
//  Copyright © 2016 Hoang Trung Hieu. All rights reserved.
//

import UIKit
import MBProgressHUD
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var switchViewButton: UIBarButtonItem!
    
    
    var movieList: [NSDictionary]?
    var filtedList: [NSDictionary] = []
    
    var networkErrorView: UIView = NetworkErrorView(frame: CGRectZero)
    let root_path = "https://image.tmdb.org/t/p/w342"
    var endpoint: String!
    var searchActive: Bool = false
    var isListView: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set delegate
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.hidden = true
        
        searchBar.delegate = self
        searchBar.placeholder = "Enter your text"
        
        
        tableView.addSubview(networkErrorView)
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        fetchData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            if filtedList.count > 1 {
                return filtedList.count
            }
            return 1
        }
        return movieList?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MovieCell
        
        var movie = movieList![indexPath.row] as NSDictionary
        if(searchActive && filtedList.count > 0) {
            movie = filtedList[indexPath.row]
        }

        if filtedList.count == 0 && searchActive {
            cell.titleLabel.text = "No result"
            cell.overviewLabel.text = ""
            cell.thumbnailImageView.image = nil
        } else {
            cell.titleLabel.text = movie["title"] as? String
            cell.overviewLabel.text = movie["overview"] as? String
            //        cell.overviewLabel.sizeToFit()
            if let poster_path = movie["poster_path"] as? String {
                let url = NSURL(string: self.root_path + poster_path)
//                cell.thumbnailImageView.setImageWithURL(url!)
                let imageRequest = NSURLRequest(URL: url!)
                cell.thumbnailImageView.setImageWithURLRequest(imageRequest,
                    placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                        // imageResponse will be nil if the image is cached
                        if imageResponse != nil {
                            print("Image was NOT cached, fade in image")
                            cell.thumbnailImageView.alpha = 0.0
                            cell.thumbnailImageView.image = image
                            UIView.animateWithDuration(1.0, animations: { () -> Void in
                                cell.thumbnailImageView.alpha = 1.0
                            })
                        } else {
                            print("Image was cached so just update the image")
                            cell.thumbnailImageView.image = image
                        }
                    }, failure: { (imageRequest, imageResponse, error) -> Void in
                        
                })
            }
        }
        
        return cell
    }
    
    // MARK: - Search Bar
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
//        searchActive = false;
//        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        print("cancel button clicked")
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }

    
    func searchBar(searchBar: UISearchBar,
        textDidChange searchText: String) {
            filtedList = (movieList?.filter({ (text) -> Bool in
                let tmp: String = text["title"] as! String
                let range = tmp.rangeOfString(searchText, options: .CaseInsensitiveSearch)
                return !(range?.isEmpty == nil)
            }))!
            searchActive = true
//            if filtedList.count == 0 {
//                searchActive = false
//            } else {
//                searchActive = true
//            }
            self.tableView.reloadData()
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("prepare for segue")
        
        let cell = sender as! MovieCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movieList![indexPath!.row]	
        let detailViewController = segue.destinationViewController as! DetailMovieViewController
        detailViewController.movie = movie
        
    }


    func fetchData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            // Hide HUD once the network request comes back (must be done on main UI thread)
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.networkErrorView.hidden = true
                            print("response: \(responseDictionary)")
                            self.movieList = responseDictionary["results"] as? [NSDictionary]
                            print("movie list: \(self.movieList)")
                            self.tableView.reloadData()
                            self.collectionView.reloadData()
                    }
                }
                if let err = error {
                    self.networkErrorView.hidden = false
                    // Hide HUD once the network request comes back (must be done on main UI thread)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    print(err)
                }
        })
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        print("refresh call")
        fetchData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func switchViewAction(sender: UIBarButtonItem) {
        if self.isListView {
            switchViewButton.image = UIImage(named: "grid")
            isListView = false
            tableView.hidden = true
            collectionView.hidden = false
        } else {
            switchViewButton.image = UIImage(named: "list")
            isListView = true
            tableView.hidden = false
            collectionView.hidden = true
        }

    }
    
    // MARK: Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList?.count ?? 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellCollection", forIndexPath: indexPath) as! MovieCollectionViewCell
        
        var movie = movieList![indexPath.row] as NSDictionary
        
        cell.titleLabel.text = movie["title"] as? String
        
        if let poster_path = movie["poster_path"] as? String {
            let url = NSURL(string: self.root_path + poster_path)
            //                cell.thumbnailImageView.setImageWithURL(url!)
            let imageRequest = NSURLRequest(URL: url!)
            cell.posterImageView.setImageWithURLRequest(imageRequest,
                placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animateWithDuration(1.0, animations: { () -> Void in
                            cell.posterImageView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterImageView.image = image
                    }
                }, failure: { (imageRequest, imageResponse, error) -> Void in
                    print(error)
                    self.networkErrorView.hidden = false
            })
        }
        
        return cell
    }


}
