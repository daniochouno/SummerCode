//
//  DetailViewController.swift
//  SummerCode
//
//  Created by daniel.martinez on 6/8/15.
//  Copyright (c) 2015 com.igz. All rights reserved.
//

import UIKit

import Haneke
import Punctual

struct ImageModel {
    let title : String?
    let url : String?
}

let FlickrApiKey = "ec986123d7f4c232bf632ab3a7fa7ea4"
let tags = "beach"

class FlickrImagesCollectionViewController: UICollectionViewController {

    @IBOutlet weak var switchBarButton: UIBarButtonItem!
    
    private var cacheEnabled = false
    
    private let reuseIdentifier = "FlickrImageCell"
    private var images = [ImageModel]()
    
    let surl = "https://api.flickr.com/services/rest/?format=json&nojsoncallback=1&method=flickr.photos.search&api_key=\(FlickrApiKey)&tags=\(tags)&extras=url_q"
    
    var session = NSURLSession.sharedSession()
    var cache = Shared.imageCache
    
    var refreshCtrl: NDRefreshControl?
    
    override func viewDidLoad() {
        
        // Create a sample view to use when engaging with the refresh control.
        let pullView = UIImageView(image: UIImage(named: "IdleImage"))
        refreshCtrl = NDRefreshControl(refreshView: pullView, scrollView: collectionView!)
        
        // Configure all the callbacks.
        refreshCtrl?.renderIdleClosure = renderIdleHandler
        refreshCtrl?.renderRefreshClosure = renderRefreshHandler
        refreshCtrl?.renderPullingClosure = renderPullingHandler
        refreshCtrl?.renderReadyForRefreshClosure = renderReadyForRefreshHandler
        
        loadDataFromServer() { success in
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView?.reloadData()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // NOTE: configureForRefresh should be called when the view controller has completely laid out the view
        // and its subviews. If you call this method in viewDidLoad, the contentInset and contentOffset values
        // are not accurate due to the navigation bar and status bar.
        refreshCtrl!.configureForRefresh()
    }
    
    // MARK: - Refresh control callback methods
    func renderIdleHandler(refreshControl: NDRefreshControl) {
        var view = refreshControl.refreshView as! UIImageView
        view.image = UIImage(named: "IdleImage")
    }
    
    func renderRefreshHandler(refreshControl: NDRefreshControl) {
        var view = refreshControl.refreshView as! UIImageView
        view.image = UIImage(named: "RefreshImage1")
        
        var imgListArray :NSMutableArray = []
        imgListArray.addObject(UIImage(named:"RefreshImage1")!)
        imgListArray.addObject(UIImage(named:"RefreshImage2")!)
        
        view.animationImages = imgListArray as [AnyObject];
        view.animationDuration = 1
        view.startAnimating()
        
        // Clear caches:
        session = NSURLSession.sharedSession()
        cache = Shared.imageCache
        
        loadDataFromServer() { success in
            dispatch_async(dispatch_get_main_queue()) {
                view.stopAnimating()
                refreshControl.endRefresh()
                self.collectionView?.reloadData()
            }
        }
        
    }
    
    func renderPullingHandler(refreshControl: NDRefreshControl) {
        var view = refreshControl.refreshView as! UIImageView
        view.image = UIImage(named: "PullingImage")
    }
    
    func renderReadyForRefreshHandler(refreshControl: NDRefreshControl) {
        var view = refreshControl.refreshView as! UIImageView
        view.image = UIImage(named: "ReadyForRefreshImage")
    }
    
    @IBAction func enableOrDisableCache(sender: AnyObject) {
        cacheEnabled = !cacheEnabled
        updateSwitchBarButton()
        self.collectionView?.reloadData()
    }
    
    func updateSwitchBarButton() {
        switchBarButton.title = (cacheEnabled) ? "Disable" : "Enable"
    }
    
    func loadDataFromServer(completion: (success: Bool) -> Void) {
        
        let request = NSURLRequest(URL: NSURL(string: surl)!)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if (error != nil) {
                return
            }
            
            var photos: NSArray = NSArray()
            let json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error:nil) as! NSDictionary
            let results = json["photos"] as! NSDictionary
            photos = results["photo"] as! NSArray
            
            self.images = [ImageModel]()
            for photo in photos {
                let imageModel = ImageModel(title: photo["title"] as? String, url: photo["url_q"] as? String)
                self.images.append(imageModel)
            }
            
            completion(success: true)
            
        }
        task.resume()
        
    }
    
    func downloadImage(cell: FlickrImageCell, url: NSURL) {
        cell.activity.startAnimating()
        cell.activity.hidden = false
        cell.timeLabel.text = ""
        cell.timeLabel.hidden = true
        if (cacheEnabled) {
            downloadImageWithHaneke(cell, url: url)
        } else {
            downloadImageWithNSURLSession(cell, url: url)
        }
    }
    
    func downloadImageWithHaneke(cell: FlickrImageCell, url: NSURL) {
        let start_ts = NSDate()
        cache.fetch(URL: url).onSuccess { image in
            let ts = (NSDate() - start_ts).timeInterval! * 1000
            dispatch_async(dispatch_get_main_queue()) {
                cell.imageView.contentMode = UIViewContentMode.ScaleAspectFit
                cell.imageView.image = image
                cell.timeLabel.text = NSString(format: "%.4f ms", ts) as String
                cell.timeLabel.hidden = false
                cell.activity.hidden = true
                cell.activity.stopAnimating()
            }
        }
    }
    
    func downloadImageWithNSURLSession(cell: FlickrImageCell, url: NSURL) {
        let start_ts = NSDate()
        loadDataFromUrl(url) { data in
            let ts = (NSDate() - start_ts).timeInterval! * 1000
            dispatch_async(dispatch_get_main_queue()) {
                if let d = data {
                    cell.imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    cell.imageView.image = UIImage(data: d)
                }
                cell.timeLabel.text = NSString(format: "%.4f ms", ts) as String
                cell.timeLabel.hidden = false
                cell.activity.hidden = true
                cell.activity.stopAnimating()
            }
        }
    }
    
    func loadDataFromUrl(url: NSURL, completion: ((data: NSData?) -> Void)) {
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url) { (data, response, error) in
            completion(data: data)
            }.resume()
    }

}

extension FlickrImagesCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrImageCell
        let imageModel = self.images[indexPath.row]
        cell.imageView.image = nil
        cell.imageURL = imageModel.url
        return cell
    }
    
}

extension FlickrImagesCollectionViewController {
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        println("FlickrImagesCollectionViewController, scrollViewDidEndDecelerating")
        updateVisibleImages()
    }
    
    private func updateVisibleImages() {
        var cells = collectionView?.visibleCells()
        println("FlickrImagesCollectionViewController, scrollViewDidEndDecelerating, visibleCells: \(cells!.count)")
        for flickrImageCell in cells! as! [FlickrImageCell] {
            if let url = NSURL(string: flickrImageCell.imageURL) {
                downloadImage(flickrImageCell, url: url)
            }
        }
    }
    
}

extension FlickrImagesCollectionViewController : UICollectionViewDelegateFlowLayout {
        
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSize(width: 160, height: 160)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 20.0, left: 20.0, bottom: 50.0, right: 20.0)
    }
    
}

