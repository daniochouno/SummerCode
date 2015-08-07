SummerCode
===========
This project aims to be a starting point to deepen the knowledge of some of the more useful libraries available for Swift 1.2 (by now, most have not yet migrated to Swift 2) 

#### Libraries included
- [Alamofire](https://github.com/Alamofire/Alamofire) for **HTTP networking**, via CocoaPods
- [Haneke](https://github.com/Haneke/HanekeSwift) for **Caching**, via CocoaPods
- [FillableLoaders](https://github.com/poolqf/FillableLoaders) for **Creating customizables loaders**, via CocoaPods
- [Punctual](https://github.com/harlanhaskins/Punctual.swift) for **Easy management with dates**, via CocoaPods
- [NDRefresh](https://github.com/Nextdoor/NDRefresh) for **Creating customizables Pull-To-Refresh views**, via Manual Installation

#### Modules

**Image caching**
-----------------

A collection of URLs of images is downloaded from **Flickr** using their API. Pressing the top right button you can enable or disable caching with **Haneke**.

If the cache is disabled (by default), the image is displayed by connecting to the URL using the **NSURLSession** class and **dataTaskWithURL** method.

If the cache is enabled, Haneke check if the image is cached or not. If you are not in the cache, automatically download and save.

In the application you can also check the load times for each image. It is interesting to compare the times after turn on and off several times the cache, to also check the operation of the cache that already use NSURLSession.

In a **'PullToRefresh'** event, both caches (which manages NSURLSession and managed Haneke) are cleaned and the collection of images is downloaded again from Flickr.

In the 'PullToRefresh' the **NDRefresh** library has been used, which allows you to customize the view shown, using images. Very useful if you want, for example, displaying a banner ad while the data is being reloaded.

**Fillable Loaders**
--------------------

**FillableLoaders** library allows create a view using any vector graphics that can be built through the CoreGraphics library. This example uses a graphic provided by the library, but you could use any other built similarly.

## Author
Daniel Martínez (daniel.martinez@intelygenz.com)

&copy; 2015