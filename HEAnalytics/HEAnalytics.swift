//
//  HEAnalytics.swift
//
//  Created by hsoi on 4/4/15.
//
//  HEAnalytics - Copyright (c) 2015, Hsoi Enterprises LLC
//  All rights reserved.
//  hsoi@hsoienterprises.com
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name of HEAnalytics nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import UIKit

/**
HEAnalytics provides a base API for logging analytics.

While not required, it's **strongly** recommended to subclass `HEAnalytics` and that your application use this subclass.

First, you can make your subclass a singleton. Yes I know the arguments for and against singleton, and I believe this is a case where it's not so evil to use a singleton pattern. However, there is nothing that requires or mandates singleton.

Second, `HEAnalytics` ams to provide a unified abstraction layer for analytics platforms, allowing calling code to be simpler, cleaner, easier to read and maintain. Thus, while clients can certainly use the `HEAnalytics` class directly and `trackData()` directly in client code, it's preferred to put the implementation details into a subclass of `HEAnalytics`. Since analytics are inherently app-specific, this calls for a subclass.

Thus, instead of code like:

```
class MyViewController: UIViewController {
    @IBAction func sliderValueDidChange(sender: AnyObject?) {
        if let slider = sender as? UISlider {
            // Do whatever you do with the slider value, like updating your data model.
            myDataObject.value = slider.value

            let parameters = ["value": slider.value]
            let data = HEAnalyticsData(category: .Settings, event: "Slider Value Updated", parameters: parameters)
            myHEAnalyticsInstance.trackData(data)
        }
    }
}
```

You should do:

```
class MyAppAnalytics: HEAnalytics {
    static let sharedInstance = MyAppAnalytics()

    func trackSliderValue(value: Float) {
        let parameters = ["value": value]
        let data = HEAnalyticsData(category: .Settings, event: "Slider Value Updated", parameters: parameters)
        self.trackData(data)
    }
}
```

Then in your code:

```
class MyViewController: UIViewController {
    @IBAction func sliderValueDidChange(sender: AnyObject?) {
        if let slider = sender as? UISlider {
            // Do whatever you do with the slider value, like updating your data model.
            myDataObject.value = slider.value

            MyAppAnalytics.sharedInstance.trackSliderValue(slider.value)
        }
    }

    func HE_analyticsViewTrackingTitle() -> String {
        return "My Interesting View"
    }
}
```

This approach:

* Keeps calling code cleaner, easier to read.
* Abstracts away the details.
* Encapsulates all analytics code and logic into a single, centralized location (which becomes a useful reference).
* Improves maintainability.

There's nothing that prevents you from the former approach, but in the author's experience the latter approach is preferrable.
*/
public class HEAnalytics: NSObject {

    /**
    Designated initializer.
    
    - returns: an instance of HEAnalytics
    */
    public override init() {
        super.init()
    }
    
    
    /**
    Deinitializer.
    
    Will cause analytics collection to `stop()`.
    */
    deinit {
        stop()
    }
    
    
    /// Private record of the instance's `HEAnalyticsPlatform` objects.
    private var platforms: [HEAnalyticsPlatform] = []
    
    /**
    Starts the recording of analytics.
    
    Loads the `AnalyticsPlatformConfig.plist`, creates the `HEAnalyticsPlatform`s from it, initializes and starts each platform, and registers for some events that it can automatically track for you.
    
    Recommended to be invoked from `application(application, willFinishLaunchingWithOptions)`.
    */
    public func start() {
        
        loadPlatforms()
        
        registerForNotifications()
        
        for platform in platforms {
            platform.start()
        }
    }
    
    
    /**
    Internal function to load the platforms.
    */
    internal func loadPlatforms() {
        assert(platforms.count == 0, "calling HEAnalytics.start() and there are loaded platforms. How did this happen?")
        
        // Hsoi 2015-04-18 - Load up the configuration.
        //
        // Note the interesting things we must do because Swift isn't the most dynamic of languages. Long live Objective-C!
        // A subtle thing you may miss is that our HEAnalyticsPlatform subclasses all have to declare an `@objc` name for
        // the class in the class declaration -- that's vital for this to work.
        let configFileURL = NSBundle.mainBundle().URLForResource("AnalyticsPlatformConfig", withExtension: "plist")
        assert(NSFileManager.defaultManager().fileExistsAtPath(configFileURL!.path!), "AnalyticsPlatformConfig.plist does not exist in the mainBundle")
        
        if let theURL = configFileURL, configDict = NSDictionary(contentsOfURL: theURL) {
            configDict.enumerateKeysAndObjectsUsingBlock({ (key:AnyObject, value:AnyObject, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                if let keyString = key as? String, valueDictionary = value as? [NSObject:AnyObject] {
                    let theClass = NSClassFromString(keyString) as! HEAnalyticsPlatform.Type
                    let platform = theClass.init(platformData: valueDictionary)
                    self.platforms.append(platform)
                }
            })
        }
        assert(platforms.count > 0, "no analytics platforms were loaded. Is the AnalyticsPlatformConfig.plist present and populated?")
    }
    
    
    /**
    Internal function to unload the platforms.
    */
    internal func unloadPlatforms() {
        platforms = []
    }
    
    
    /**
    Registers for various `NSNotification`s that we can handle ourselves, and that would be generally useful to clients.
    
    For now, registers for all useful `UIApplication` notifications.
    */
    internal func registerForNotifications() {
        // Hsoi 2015-04-18 - Most apps want to track UIApplication events, so let's just track them automatically. One less thing
        // for you to have to worry about!
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationBackgroundRefreshStatusDidChangeNotification:"), name: UIApplicationBackgroundRefreshStatusDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationDidBecomeActiveNotification:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationDidEnterBackgroundNotification:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationDidFinishLaunchingNotification:"), name: UIApplicationDidFinishLaunchingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationUserDidTakeScreenshotNotification:"), name: UIApplicationUserDidTakeScreenshotNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationWillEnterForegroundNotification:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationWillResignActiveNotification:"), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationWillTerminateNotification:"), name: UIApplicationWillTerminateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIContentSizeCategoryDidChangeNotification:"), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    
    /**
    Unregisters for notifications.
    */
    internal func unregisterForNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    /**
    Stops the recording of analytics.
    */
    public func stop() {
        for platform in platforms {
            platform.stop()
        }
        
        unregisterForNotifications()
        unloadPlatforms()
    }
    
    
    /**
    Sets the "opt-out" feature.
    
    This doesn't affect start/stop, just an opt-out feature. So things may be running, just not recorded. Can depend upon the particulars of an SDK.
    
    NB: this feature is something you generally should expose in the GUI of the app to allow the user to configure if data can be collected or not -- see the terms of use of each analytics platform. HEAnalytics does nothing to manage this setting/feature: it's upon the app developer to expose, maintain, persist, enforce, etc. this setting.
    
    - parameter opt: true to opt out, false to not. Defaults to not being opted out (false)
    */
    public func optOut(opt: Bool) {
        for platform in platforms {
            platform.optOut = opt
        }
    }

    
    /**
    The key function for actually tracking the analytics data.
    
    While in general you could fill out an HEAnalyticsData and call trackData() from client code, the general recommendation is in your HEAnalytics subclass to implement functions for particular events and encapsulate the logic in the analytics class, not client code.
    
    For example:
    
        func tappedSomeInterestingButton() {
            let data = HEAnalyticsData(category: .General, event: "Tapping Interesting Button")
            trackData(data)
        }
    
    then client code just invokes `MyAnalytics.sharedInstance().tappedSomeInterestingButton()`.
    
    - parameter data: The HEAnalyticsData containing the data to track.
    */
    public func trackData(data: HEAnalyticsData) {
        for platform in platforms {
            platform.trackData(data)
        }
    }
    
    
    /**
    The key function for view tracking.
    
    You'll want to call this at a time such as in the UIViewController's implementation of viewDidAppear(), or some other appropriate location.
    
    - parameter viewController: The UIViewController to track.
    */
    public func trackView(viewController: UIViewController) {
        for platform in platforms {
            platform.trackView(viewController)
        }
    }
    
    
// MARK: - Application Events
    
    
    /**
    Private handler for UIApplicationBackgroundRefreshStatusDidChangeNotification
    
    - parameter notification: the notification object.
    */
    @objc private func handleUIApplicationBackgroundRefreshStatusDidChangeNotification(notification: NSNotification) {
        var status = "<unknown>"
        let currentBackgroundRefreshStatus = UIApplication.sharedApplication().backgroundRefreshStatus
        switch currentBackgroundRefreshStatus {
        case .Restricted:
            status = "restricted"
            
        case .Denied:
            status = "denied"
            
        case .Available:
            status = "available"
        }

        let data = HEAnalyticsData(category: .Application, event: "Background Refresh Status Did Change", parameters: ["status":status])
        trackData(data)
    }
    
    
    /**
    Private handler for UIApplicationDidBecomeActiveNotification
    
    - parameter notification: the notification object.
    */
    @objc private func handleUIApplicationDidBecomeActiveNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Did Become Active")
        trackData(data)
    }

    
    /**
    Private handler for UIApplicationDidEnterBackgroundNotification
    
    - parameter notification: the notification object.
    */
    @objc private func handleUIApplicationDidEnterBackgroundNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Did Enter Background")
        trackData(data)
    }
    
    
    /**
    Private handler for UIApplicationDidFinishLaunchingNotification
    
    - parameter notification: the notification object.
    */
    @objc private func handleUIApplicationDidFinishLaunchingNotification(notification: NSNotification) {
        var parameters:[NSObject:AnyObject] = [:]
        if let notificationObject:AnyObject = notification.object {
            if let _ = notificationObject as? UIApplication {
                // don't track the application object
            }
            else {
                parameters["object"] = notificationObject.description ?? NSStringFromClass(notificationObject.dynamicType)
            }
        }
        
        if let userInfo: [NSObject:AnyObject] = notification.userInfo {
            if let launchOptions = userInfo[UIApplicationLaunchOptionsURLKey] as? NSURL {
                parameters["launchOptionsURL"] = launchOptions.absoluteString
            }
            if let sourceApplication:AnyObject = userInfo[UIApplicationLaunchOptionsSourceApplicationKey] {
                parameters["sourceApplication"] = sourceApplication
            }
            if let remoteNotification:AnyObject = userInfo[UIApplicationLaunchOptionsRemoteNotificationKey] {
                parameters["remoteNotification"] = remoteNotification.description ?? "<unknown>"
            }
            if let localNotification:AnyObject = userInfo[UIApplicationLaunchOptionsLocalNotificationKey] {
                parameters["localNotification"] = localNotification.description ?? "<unknown>"
            }
        }
        
        let dataParameters:[NSObject:AnyObject]? = parameters.count != 0 ? parameters : nil
        let data = HEAnalyticsData(category: .Application, event: "Did Finish Launching", parameters: dataParameters)
        trackData(data)
    }
    
    
    /**
    Private handler for UIApplicationUserDidTakeScreenshotNotification
    
    - parameter notification: the notification object.
    */
    @objc private func handleUIApplicationUserDidTakeScreenshotNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Did Take Screenshot")
        trackData(data)
    }
    
    
    /**
    Private handler for UIApplicationWillEnterForegroundNotification
    
    - parameter notification: the notification object.
    */
    @objc private func handleUIApplicationWillEnterForegroundNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Will Enter Foreground")
        trackData(data)
    }
    
    
    /**
    Private handler for UIApplicationWillResignActiveNotification
    
    - parameter notification: the notification object.
    */
    @objc private func handleUIApplicationWillResignActiveNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Will Resign Active")
        trackData(data)
    }
    
    
    /**
    Private handler for UIApplicationWillTerminateNotification
    
    - parameter notification: the notification object.
    */
    @objc private func handleUIApplicationWillTerminateNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Will Terminate")
        trackData(data)
    }
    
    
    /**
    Private handler for UIContentSizeCategoryDidChangeNotification
    
    - parameter notification: the notification object.
    */
    @objc private func handleUIContentSizeCategoryDidChangeNotification(notification: NSNotification) {
        var parameters:[NSObject:AnyObject] = ["contentSize":"<unknown>"]
        if let userInfo: [NSObject:AnyObject] = notification.userInfo, newSize: AnyObject = userInfo[UIContentSizeCategoryNewValueKey] {
            parameters["contentSize"] = newSize
        }
        let data = HEAnalyticsData(category: .Application, event: "Content Size Category Did Change", parameters: parameters)
        trackData(data)
    }

}

