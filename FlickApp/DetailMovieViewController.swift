//
//  DetailMovieViewController.swift
//  FlickApp
//
//  Created by Hoang Trung Hieu on 3/10/16.
//  Copyright © 2016 Hoang Trung Hieu. All rights reserved.
//

import UIKit

class DetailMovieViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    let largeURL = "https://image.tmdb.org/t/p/original"
    let smallURL = "https://image.tmdb.org/t/p/w45"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        print(movie)
        let title = movie["title"] as? String
        self.title = title
        titleLabel.text = title
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        if let poster_path = movie["poster_path"] as? String {
            let smallImageURL = NSURL(string: self.smallURL + poster_path)
            let largeImageURL = NSURL(string: self.largeURL + poster_path)
//            posterImageView.setImageWithURL(postURL!)
            posterImageView.setImageWithURLRequest(NSURLRequest(URL: smallImageURL!), placeholderImage: nil, success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                self.posterImageView.alpha = 0.0
                self.posterImageView.image = smallImage
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.posterImageView.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterImageView.setImageWithURLRequest(
                            NSURLRequest(URL: largeImageURL!),
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterImageView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
                }, failure: {(request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
            })
        }
        
        infoView.frame.origin.y = posterImageView.frame.origin.y + posterImageView.frame.size.height
        infoView.frame.size.height = titleLabel.frame.origin.y + titleLabel.frame.size.height + overviewLabel.frame.origin.y + overviewLabel.frame.size.height
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
