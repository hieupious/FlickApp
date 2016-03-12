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

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var movieList: [NSDictionary]?
    var networkErrorView: UIView?
    let root_path = "https://image.tmdb.org/t/p/w342"
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // init network error
        networkErrorView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 21))
        networkErrorView!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 21))
        errorLabel.textAlignment = .Center
        errorLabel.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        errorLabel.text = "Network Error"
        networkErrorView!.addSubview(errorLabel)
        networkErrorView!.hidden = true
        tableView.addSubview(networkErrorView!)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MovieCell
        let movie = movieList![indexPath.row] as NSDictionary 
        cell.titleLabel.text = movie["title"] as? String
        cell.overviewLabel.text = movie["overview"] as? String
//        cell.overviewLabel.sizeToFit()
        if let poster_path = movie["poster_path"] as? String {
            let url = NSURL(string: self.root_path + poster_path)
            cell.thumbnailImageView.setImageWithURL(url!)
            let imageRequest = NSURLRequest(URL: url!)
            cell.thumbnailImageView.setImageWithURLRequest(imageRequest,
                placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.thumbnailImageView.alpha = 0.0
                    cell.thumbnailImageView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.thumbnailImageView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.thumbnailImageView.image = image
                }
                }, failure: { (imageRequest, imageResponse, error) -> Void in
            
            })
        }
        return cell
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
                            self.networkErrorView!.hidden = true
                            print("response: \(responseDictionary)")
                            self.movieList = responseDictionary["results"] as? [NSDictionary]
                            print("movie list: \(self.movieList)")
                            self.tableView.reloadData()
                    }
                }
                if let err = error {
                    self.networkErrorView!.hidden = false
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
}
