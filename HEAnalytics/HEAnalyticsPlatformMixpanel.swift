//
//  HEAnalyticsPlatformGAI.swift
//
//  Created by hsoi on 4/23/15.
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
An HEAnalyticsPlatform for the Mixpanel platform.
*/
@objc(HEAnalyticsPlatformMixpanel)
public class HEAnalyticsPlatformMixpanel: HEAnalyticsPlatform {
   

    /**
    Initializer.
    
    - parameter platformData: The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
    
    - returns: A properly initialized HEAnalyticsPlatform object.
    */
    public required init(platformData: [NSObject:AnyObject]) {
        super.init(platformData: platformData)
    }
    
    
    /// Our own private Mixpanel instance (instead of the Mixpanel.sharedInstance()), since that facilitates the use of multiple HEAnalytics instances.
    private var mixpanel: Mixpanel!
    
    
    /**
    Initializes the platform with the given data.
    
    Subclasses are required to override and implement this in whatever way gets the platform's SDK intialized and ready (but not started). Think of it like starting the motor on the car and letting it idle being ready to go (whereas start() is when the car is put in gear and your foot depresses the gas pedal).
    
    Subclasses should invoke super (generally at the end, before returning).
    
    - parameter platformData: The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
    */
    internal override func initializePlatform(platformData: [NSObject:AnyObject]) {
        
        var defaultFlushInterval: UInt = 15
        if let flushInterval = platformData["flushInterval"] as? UInt {
            defaultFlushInterval = flushInterval
        }

        let token = platformData["token"] as! String
        self.mixpanel = Mixpanel(token: token, launchOptions: nil, andFlushInterval: defaultFlushInterval)
        
        if let flushOnBackground = platformData["flushOnBackground"] as? Bool {
            self.mixpanel.flushOnBackground = flushOnBackground
        }
        
        if let showNetworkActivityIndicator = platformData["showNetworkActivityIndicator"] as? Bool {
            self.mixpanel.showNetworkActivityIndicator = showNetworkActivityIndicator
        }
        
        if let checkForSurveysOnActive = platformData["checkForSurveysOnActive"] as? Bool {
            self.mixpanel.checkForSurveysOnActive = checkForSurveysOnActive
        }
        
        if let showSurveyOnActive = platformData["showSurveyOnActive"] as? Bool {
            self.mixpanel.showSurveyOnActive = showSurveyOnActive
        }
        
        if let checkForNotificationsOnActive = platformData["checkForNotificationsOnActive"] as? Bool {
            self.mixpanel.checkForNotificationsOnActive = checkForNotificationsOnActive
        }
        
        if let checkForVariantsOnActive = platformData["checkForVariantsOnActive"] as? Bool {
            self.mixpanel.checkForVariantsOnActive = checkForVariantsOnActive
        }
        
        if let showNotificationOnActive = platformData["showNotificationOnActive"] as? Bool {
            self.mixpanel.showNotificationOnActive = showNotificationOnActive
        }
        
        if let miniNotificationPresentationTime = platformData["miniNotificationPresentationTime"] as? CGFloat {
            self.mixpanel.miniNotificationPresentationTime = miniNotificationPresentationTime
        }
        
        super.initializePlatform(platformData)
    }
    
    
    /// Has Mixpanel tracking started or not? As far as I can tell, Mixpanel doesn't have any sort of mechanism to enforce optOut/in or start/stop so we'll keep track of it ourselves.
    private var started: Bool = false
    
    
    /**
    Starts the platform actually recording events.
    
    Subclasses generally will want to override this to start their SDK's collection of data. Note that, depending upon the implementation details of the SDK, you may need to check the  HEAnalyticsPlatform.optOut property to ensure you actually should start collecting or not.
    */
    public override func start() {
        if !self.optOut {
            if !self.started {
                super.start()
                self.started = true
            }
        }
    }
    
    
    /**
    Stops the platform from actually recording events.
    
    Subclasses will generally want to override this to stop their SDK's collection of data.
    */
    public override func stop() {
        super.stop()
        self.started = false
    }
    
    
    /**
    The core function that's actually tracks/logs the analytic event data.
    
    Subclasses will need to override this and implement the SDK's event logging/tracking mechanism.
    
    - parameter data: The HEAnalyticsData with the information to be recorded. It is up to the subclass to interpret, preserve, and convey this data as richly and appropriately as the platform SDK allows.
    */
    public override func trackData(data: HEAnalyticsData) {
        if self.optOut || !self.started {
            return
        }

        let event = data.category + " - " + data.event
        if let dataParameters = data.parameters {
            self.mixpanel.track(event, properties: dataParameters)
        }
        else {
            self.mixpanel.track(event)
        }
    }
    
    
    /**
    Used to track views of a UIViewController.
    
    Subclasses will need to override and implement the SDK's view logging/tracking mechanism.
    
    Consider use of viewControlerTitle() to help in tracking.
    
    - parameter viewController: The UIViewController to track.
    */
    public override func trackView(viewController: UIViewController) {
        if self.optOut || !self.started {
            return
        }
        
        let title = self.viewControlerTitle(viewController)
        let event = "TrackView - " + title
        self.mixpanel.track(event)
    }
    
}
