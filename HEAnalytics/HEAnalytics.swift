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



/*

So the expectation....

Apps always are unique in the analytics they want to track. Thus, we can only provide base structure.

The app should subclass HEAnalytics. Likely you'll want the one-and-only-one instance of the analytics
tracker, so adding sharedInstance() to your subclass makes sense. Of course, if you want to have multiple
trackers that's fine (Google Analytics API docs even discuss doing this), but you'll have to make it
go (e.g. you may need to subclass the HEAnalyticsPlatform classes to add in the way to get the unique
API keys per tracker and so on). And then, into your HEAnalytics subclass you should add whatever
individual functions are needed to track your stuff. For example:

    func userTappedSomeImportantButton() {
        let data = HEAnalyticsData(category: .General, event: "Tapped Important Button")
        trackData(data)
    }

Then throughout the app code...

The analytics MUST be setup in application(application, willFinishLaunchingWithOptions). NB: ** WILL ** NOT "DID"

    MyAppAnalytics.sharedInstance().addPlatform(HEAnalyticsPlatformFlurry())
    MyAppAnalytics.sharedInstance().addPlatform(HEAnalyticsPlatformGAI())
    MyAppAnalytics.sharedInstance().start()

and that'll start things rolling.

Again NOTE! It must be set up in "WILL FINISH" so that everything can be fully established, including the automatic
tracking of Application events. By the time "did finish launching" happens, it's too late.

Then in relevant spots, call things:

    @IBAction func importantButtonTapped(sender: AnyObject?) {
        MyAppAnalytics.sharedInstance().userTappedSomeImportantButton()
    }

Note: if you need to, the analytic tracking functions can take arguments, which you can then funnel into the
parameters... whatever is relevant to you. Just a few things to note:

-   try to minimize the work you do in the code that will invoke the analytics API. That code shouldn't
    know nor care about how the analytics tracks or massages the data. Try to encapsulate any sort of
    data massaging in the analytics (sub)classes.
-   When implementing your analytics (sub)classes, be mindful of passing nil data around, as the analytics
    don't always like that. What you may have to do before passing along to the lower-level APIs is
    sanitize the data, like turn nil into "" (empty string) or "<unknown value>" or something else. Remember
    that 1. we don't want things to crash, 2. it's better to be more expressive in the data collected
    because once the release goes out the door we can't get at more analytics data -- so it's generally
    better to collect more data and then filter it out afterwards (easier to filter than try to gather
    after the fact).


On "optOut" - this is something HEAnalytics works to provide infrastructre for, but use of it is up to you.
It is upon you to provide UI for working with this setting. It is up to you to persist this setting across
launches, and to enforce the application of it into the HEAnalytics framework.

*/

import UIKit

public class HEAnalytics: NSObject {

    /*
    class var sharedInstance: HEAnalytics {
        struct Static {
            static let instance: HEAnalytics = HEAnalytics()
        }
        return Static.instance
    }
    */
    
    deinit {
        self.stop()
    }
    
    private var platforms: [HEAnalyticsPlatform] = []
    
    func addPlatform(platform: HEAnalyticsPlatform) {
        platform.initializePlatform()
        platforms.append(platform)
    }
    
    
    func start() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationBackgroundRefreshStatusDidChangeNotification:"), name: UIApplicationBackgroundRefreshStatusDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationDidBecomeActiveNotification:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationDidEnterBackgroundNotification:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationDidFinishLaunchingNotification:"), name: UIApplicationDidFinishLaunchingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationUserDidTakeScreenshotNotification:"), name: UIApplicationUserDidTakeScreenshotNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationWillEnterForegroundNotification:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationWillResignActiveNotification:"), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIApplicationWillTerminateNotification:"), name: UIApplicationWillTerminateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUIContentSizeCategoryDidChangeNotification:"), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        for platform in self.platforms {
            platform.start()
        }
    }

    
    func stop() {
        for platform in self.platforms {
            platform.stop()
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func optOut(opt: Bool) {
        for platform in self.platforms {
            platform.optOut = opt
        }
    }

    
    
    func trackData(data: HEAnalyticsData) {
        for platform in self.platforms {
            platform.trackData(data)
        }
    }
    
    
    func trackView(viewController: UIViewController) {
        for platform in self.platforms {
            platform.trackView(viewController)
        }
    }
    
    
// MARK: - Application Events

    func handleUIApplicationBackgroundRefreshStatusDidChangeNotification(notification: NSNotification) {
        var status = "<unknown>"
        let currentBackgroundRefreshStatus = UIApplication.sharedApplication().backgroundRefreshStatus
        switch currentBackgroundRefreshStatus {
        case .Restricted:
            status = "restricted"
            
        case .Denied:
            status = "denied"
            
        case .Available:
            status = "available"
            
        default:
            status = "uncased value - \(currentBackgroundRefreshStatus)"
        }

        let data = HEAnalyticsData(category: .Application, event: "Background Refresh Status Did Change", parameters: ["status":status])
        self.trackData(data)
    }
    
    func handleUIApplicationDidBecomeActiveNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Did Become Active")
        self.trackData(data)
    }

    func handleUIApplicationDidEnterBackgroundNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Did Enter Background")
        self.trackData(data)
    }
    
    func handleUIApplicationDidFinishLaunchingNotification(notification: NSNotification) {
        var parameters:[NSObject:AnyObject] = [:]
        if let notificationObject:AnyObject = notification.object {
            if let applicationObject = notificationObject as? UIApplication {
                // don't track the application object
            }
            else {
                parameters["object"] = notificationObject.description ?? NSStringFromClass(notificationObject.dynamicType)
            }
        }
        
        if let userInfo: [NSObject:AnyObject] = notification.userInfo {
            if let launchOptions = userInfo[UIApplicationLaunchOptionsURLKey] as? NSURL {
                if let urlstring = launchOptions.absoluteString {
                    parameters["launchOptionsURL"] = urlstring
                }
                else {
                    parameters["launchOptionsURL"] = "<unknown>"
                }
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
        self.trackData(data)
    }
    
    func handleUIApplicationUserDidTakeScreenshotNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Did Take Screenshot")
        self.trackData(data)
    }
    
    func handleUIApplicationWillEnterForegroundNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Will Enter Foreground")
        self.trackData(data)
    }
    
    func handleUIApplicationWillResignActiveNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Will Resign Active")
        self.trackData(data)
    }
    
    func handleUIApplicationWillTerminateNotification(notification: NSNotification) {
        let data = HEAnalyticsData(category: .Application, event: "Will Terminate")
        self.trackData(data)
    }
    
    func handleUIContentSizeCategoryDidChangeNotification(notification: NSNotification) {
        var parameters:[NSObject:AnyObject] = ["contentSize":"<unknown>"]
        if let userInfo: [NSObject:AnyObject] = notification.userInfo {
            if let newSize:AnyObject = userInfo[UIContentSizeCategoryNewValueKey] {
                parameters["contentSize"] = newSize
            }
        }
        let data = HEAnalyticsData(category: .Application, event: "Content Size Category Did Change", parameters: parameters)
        self.trackData(data)
    }

    /*
    
    // MARK: - Version checking (based upon https://github.com/nicklockwood/iVersion )
    
    func newVersionDisplayAlert(newVersion: String?)
    func newVersionDownload(newVersion: String?)
    func newVersionReminder(newVersion: String?)
    func newVersionIgnore(newVersion: String?)
*/
}

