//
//  DetailViewController.swift
//  SummerCode
//
//  Created by daniel.martinez on 6/8/15.
//  Copyright (c) 2015 com.igz. All rights reserved.
//

import UIKit

import Alamofire
import Haneke
import Punctual

struct ImageModel {
    let title : String?
    let url : String?
}

let FlickrApiKey = "ec986123d7f4c232bf632ab3a7fa7ea4"
let tags = "beach"

// Preload parameters:
let PageSize = 100
let PreloadMargin = 25

class FlickrImagesCollectionViewController: UICollectionViewController {

    @IBOutlet weak var switchBarButton: UIBarButtonItem!
    
    private var cacheEnabled = false
    
    private let reuseIdentifier = "FlickrImageCell"
    
    let operationQueue = NSOperationQueue()
    
    // Data:
    private var data = [ImageModel]()
    private var preloaded = [Int: [ImageModel]]()
    private var preloadOperations = [Int: NSOperation]()
    private var currentPage: Int = 0
    
    let RequestURL = "https://api.flickr.com/services/rest/?format=json&nojsoncallback=1&method=flickr.photos.search&api_key=\(FlickrApiKey)&tags=\(tags)&extras=url_q&per_page=\(PageSize)"
    
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
        
        // First Load:
        loadFirstDataFromServer({ success in })
        
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
        
        // Clear data:
        data = [ImageModel]()
        preloaded = [Int: [ImageModel]]()
        preloadOperations = [Int: NSOperation]()
        
        loadFirstDataFromServer({ success in
            view.stopAnimating()
            refreshControl.endRefresh()
        })
        
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
    
    func loadFirstDataFromServer(completion: (success: Bool) -> Void) {
        currentPage = 0
        loadDataFromServer(currentPage) { success in
            self.data = self.preloaded[self.currentPage]!
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView?.reloadData()
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.updateVisibleImages()
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(success:true)
            }
        }
    }
    
    func loadDataFromServer(page: Int, completion: (success: Bool) -> Void) {
        
        // Set Page in request:
        var _url = RequestURL + "&page=\(page + 1)"
        let request = NSURLRequest(URL: NSURL(string: _url)!)
    
        // Initialize array to prevent similar multiple requests:
        self.preloaded[page] = [ImageModel]()

        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if (error != nil) {
                // An error appears, set array for page to nil:
                self.preloaded[page] = nil
                return
            }
            
            let json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error:nil) as! NSDictionary
            var photos: NSArray = NSArray()
            let results = json["photos"] as! NSDictionary
            photos = results["photo"] as! NSArray
            
            var array = [ImageModel]()
            for photo in photos {
                let imageModel = ImageModel(title: photo["title"] as? String, url: photo["url_q"] as? String)
                array.append(imageModel)
            }
            self.preloaded[page] = array
            
            if (self.currentPage == (page - 1)) {
                
                // Data downloaded are in the next page. We need to add them to the main data array.
                self.data += self.preloaded[page]!
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView?.reloadData()
                })
                
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
        return self.data.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // Preload data if index is near to the end:
        preloadDataIfNeededForRow(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrImageCell
        let imageModel = self.data[indexPath.row]
        cell.timeLabel.text = ""
        cell.imageView.image = UIImage(named: "Placeholder")
        cell.imageURL = imageModel.url
        return cell
        
    }
    
    private func preloadDataIfNeededForRow(row: Int) {
        
        currentPage = (row / PageSize)
        if (needsLoadDataForPage(currentPage)) {
            preloadDataForPage(currentPage)
        }
        
        let nextPage = ((row + PreloadMargin) / PageSize)
        if ((nextPage > currentPage) && (needsLoadDataForPage(nextPage))) {
            preloadDataForPage(nextPage)
        }
        
    }
    
    private func needsLoadDataForPage(page: Int) -> Bool {
        return (self.preloaded[page] == nil)
    }
    
    private func preloadDataForPage(page: Int) {
        loadDataFromServer(page, completion: { success in })
    }
    
}

extension FlickrImagesCollectionViewController {
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateVisibleImages()
    }
    
    // 'scrollViewDidEndDecelerating' would not be called in some cases (for example, when the page is fully scrolled in place). Then use this:
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            updateVisibleImages()
        }
    }
    
    // Load images only for visible cells
    private func updateVisibleImages() {
        var cells = collectionView?.visibleCells()
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

