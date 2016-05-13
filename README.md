SummerCode
===========
This project aims to be a starting point to deepen the knowledge of some of the more useful libraries available for Swift 1.2 (by now, most have not yet migrated to Swift 2) 

#### Libraries included
- [Alamofire](https://github.com/Alamofire/Alamofire) for **HTTP networking**, via CocoaPods
- [Haneke](https://github.com/Haneke/HanekeSwift) for **Caching**, via CocoaPods
- [FillableLoaders](https://github.com/poolqf/FillableLoaders) for **Creating customizables loaders**, via CocoaPods
- [Punctual](https://github.com/harlanhaskins/Punctual.swift) for **Easy management with dates**, via CocoaPods
- [NDRefresh](https://github.com/Nextdoor/NDRefresh) for **Creating customizables Pull-To-Refresh views**, via Manual Installation
- [SideMenu3D](https://github.com/themsaid/swift-sidemenu-3d) for **Implementing a Side Menu with 3D rotation**, via Manual Installation
- [SCLAlertView](https://github.com/vikmeup/SCLAlertView-Swift) for **Creating animated Alert views**, via CocoaPods

**Image caching**
-----------------

![SummerCode image caching screenshot](https://github.com/daniochouno/SummerCode/blob/master/Resources/Screenshots/ImageCaching.png) 

A collection of URLs of images is downloaded from **Flickr** using their API. Pressing the top right button you can enable or disable caching with **Haneke**.

If the cache is disabled (by default), the image is displayed by connecting to the URL using the **NSURLSession** class and **dataTaskWithURL** method.

If the cache is enabled, Haneke check if the image is cached or not. If you are not in the cache, automatically download and save.

In the application you can also check the load times for each image. It is interesting to compare the times after turn on and off several times the cache, to also check the operation of the cache that already use NSURLSession.

In a **'PullToRefresh'** event, both caches (which manages NSURLSession and managed Haneke) are cleaned and the collection of images is downloaded again from Flickr.

In the 'PullToRefresh' the **NDRefresh** library has been used, which allows you to customize the view shown, using images. Very useful if you want, for example, displaying a banner ad while the data is being reloaded.

**Fillable Loaders**
--------------------

![SummerCode fillable loaders screenshot](https://github.com/daniochouno/SummerCode/blob/master/Resources/Screenshots/FillableLoaders.png)

**FillableLoaders** library allows create a view using any vector graphics that can be built through the CoreGraphics library. This example uses a graphic provided by the library, but you could use any other built similarly.

**Side Menu**
--------------------

![SummerCode side menu screenshot](https://github.com/daniochouno/SummerCode/blob/master/Resources/Screenshots/SideMenu.png)

Pressing the Menu button, a screenshot of the current view is taken. Then, the background image for the Side Menu is displayed and a 3D rotation is executed in the screenshot captured. Finally, the options are shown.

When a menu option is selected, the **SCLAlertView** shows a distinct alert view.

![SummerCode alert view screenshot](https://github.com/daniochouno/SummerCode/blob/master/Resources/Screenshots/SCLAlertView.png)

## Author
Daniel Mart&iacute;nez (dmartinez@danielmartinez.info)

&copy; 2015
