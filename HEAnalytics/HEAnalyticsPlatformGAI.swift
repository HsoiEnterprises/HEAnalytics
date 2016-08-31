//
//  HEAnalyticsPlatformGAI.swift
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
An HEAnalyticsPlatform for the Google Analytics (GAI) platform.
*/
@objc(HEAnalyticsPlatformGAI)
open class HEAnalyticsPlatformGAI: HEAnalyticsPlatform {
   
    /**
    Initializer.
    
    - parameter platformData: The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
    
    - returns: A properly initialized HEAnalyticsPlatformGAI object.
    */
    public required init(platformData: [String:Any]) {
        super.init(platformData: platformData)
    }


    /**
    Initializes the platform with the given data.
    
    Subclasses are required to override and implement this in whatever way gets the platform's SDK intialized and ready (but not started). Think of it like starting the motor on the car and letting it idle being ready to go (whereas start() is when the car is put in gear and your foot depresses the gas pedal).
    
    Subclasses should invoke super (generally at the end, before returning).
    
    - parameter platformData: The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
    */
    internal override func initializePlatform(_ platformData: [String:Any]) {

        let trackingID = platformData["trackingID"] as! String
        GAI.sharedInstance().tracker(withTrackingId: trackingID)

        if let dispatchInterval = platformData["dispatchInterval"] as? TimeInterval {
            GAI.sharedInstance().dispatchInterval = dispatchInterval
        }
        else {
            GAI.sharedInstance().dispatchInterval = 120 // Google's documented default.
        }
        
        if let logLevel = platformData["logLevel"] as? UInt {
            GAI.sharedInstance().logger.logLevel = GAILogLevel(rawValue: logLevel) ?? .error
        }
        else {
        #if DEBUG
            GAI.sharedInstance().logger.logLevel = .Verbose
        #else
            GAI.sharedInstance().logger.logLevel = .error
        #endif
        }
        
        if let dryRun = platformData["dryRun"] as? Bool {
            GAI.sharedInstance().dryRun = dryRun
        }
        else {
            GAI.sharedInstance().dryRun = false
        }

        if let allowIDFACollection = platformData["allowIDFA"] as? Bool {
            GAI.sharedInstance().defaultTracker.allowIDFACollection = allowIDFACollection
        }
        
        // Hsoi 2015-05-23 - https://groups.google.com/forum/#!topic/ga-mobile-app-analytics/U4nqqBnBhjU
        if let appVersion = appVersion() {
            GAI.sharedInstance().defaultTracker.set(kGAIAppVersion, value: appVersion)
        }

        super.initializePlatform(platformData)
    }
    

    /// Has the user opt'd out of data collection? Note this value is not persisted anywhere by HEAnalytics. Exposing this setting in the GUI, persisting the value, restoring the value, and enforcing it generally is the responsibility of the app developer.
    open override var optOut: Bool {
        didSet {
            GAI.sharedInstance().optOut = optOut
        }
    }
    
    
    /**
    Starts the platform actually recording events.
    
    Subclasses generally will want to override this to start their SDK's collection of data. Note that, depending upon the implementation details of the SDK, you may need to check the  HEAnalyticsPlatform.optOut property to ensure you actually should start collecting or not.
    */
    open override func start() {
        guard !optOut else {
            return
        }
        
        super.start()
        GAI.sharedInstance().optOut = false
    }
    
    
    /**
    Stops the platform from actually recording events.
    
    Subclasses will generally want to override this to stop their SDK's collection of data.
    */
    open override func stop() {
        super.stop()
        GAI.sharedInstance().optOut = true
    }
    
    
    /**
    The core function that's actually tracks/logs the analytic event data.
    
    Subclasses will need to override this and implement the SDK's event logging/tracking mechanism.
    
    - parameter data: The HEAnalyticsData with the information to be recorded. It is up to the subclass to interpret, preserve, and convey this data as richly and appropriately as the platform SDK allows.
    */
    open override func trackData(_ data: HEAnalyticsData) {
        guard !optOut && !GAI.sharedInstance().optOut else {
            return
        }
        
        var JSONString: String?
        if let dataParameters = data.parameters {
            JSONString = HEJSONHelper.canonicalJSONRepresentationWithObject(dataParameters as AnyObject?)
        }
        let sendData = GAIDictionaryBuilder.createEvent(withCategory: data.category, action:data.event, label:JSONString, value:nil).build()
        var converted = [String:Any]()
        sendData?.forEach { key, value in
            guard let key = key as? String else { return }
            converted[key] = value
        }
        GAI.sharedInstance().defaultTracker.send(converted)
    }


    /**
    Used to track views of a UIViewController.
    
    Subclasses will need to override and implement the SDK's view logging/tracking mechanism.
    
    Consider use of viewControlerTitle() to help in tracking.
    
    - parameter viewController: The UIViewController to track.
    */
    open override func trackView(_ viewController: UIViewController) {
        guard !optOut && !GAI.sharedInstance().optOut else {
            return
        }

        let tracker = GAI.sharedInstance().defaultTracker
        let title = viewControlerTitle(viewController)
        tracker?.set(kGAIScreenName, value: title)
        var converted = [String:Any]()
        GAIDictionaryBuilder.createScreenView().build()?.forEach { key, value in
            guard let key = key as? String else { return }
            converted[key] = value
        }
        tracker?.send(converted)
    }

}
