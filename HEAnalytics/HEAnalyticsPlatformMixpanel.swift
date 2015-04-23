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
class HEAnalyticsPlatformMixpanel: HEAnalyticsPlatform {
   
    required init(platformData: [NSObject:AnyObject]) {
        super.init(platformData: platformData)
    }
    
    // Hsoi 2015-04-23 - We don't uset the Mixpanel.sharedInstance() and instead allocate our own instance, because that
    // facilitates things in case someone wants to use multiple HEAnalytics instances.
    private var mixpanel: Mixpanel!
    
    override func initializePlatform(platformData: [NSObject:AnyObject]) {
        
        var defaultFlushInterval: UInt = 15
        if let flushInterval = platformData["flushInterval"] as? UInt {
            defaultFlushInterval = flushInterval
        }

        let token = platformData["token"] as String
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
    
    
    // Hsoi 2015-04-23 - As far as I can tell about Mixpanel, it doesn't really have any sort of mechanism to enforce
    // optOut/in or start/stop. So we'll just keep track of it ourselves.
    private var started: Bool = false
    
    override func start() {
        if !self.optOut {
            if !self.started {
                super.start()
                self.started = true
            }
        }
    }
    
    
    override func stop() {
        super.stop()
        self.started = false
    }
    
    
    override func trackData(data: HEAnalyticsData) {
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
    
    
    override func trackView(viewController: UIViewController) {
        if self.optOut || !self.started {
            return
        }
        
        let title = self.viewControlerTitle(viewController)
        let event = "TrackView - " + title
        self.mixpanel.track(event)
    }
    
}
