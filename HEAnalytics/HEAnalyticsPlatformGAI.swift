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
class HEAnalyticsPlatformGAI: HEAnalyticsPlatform {
   
    required init(platformData: [NSObject:AnyObject]) {
        super.init(platformData: platformData)
    }

    override func initializePlatform(platformData: [NSObject:AnyObject]) {

        let trackingID = platformData["trackingID"] as! String
        GAI.sharedInstance().trackerWithTrackingId(trackingID)

        if let dispatchInterval = platformData["dispatchInterval"] as? NSTimeInterval {
            GAI.sharedInstance().dispatchInterval = dispatchInterval
        }
        else {
            GAI.sharedInstance().dispatchInterval = 120 // Google's documented default.
        }
        
        if let logLevel = platformData["logLevel"] as? UInt {
            GAI.sharedInstance().logger.logLevel = GAILogLevel(rawValue: logLevel) ?? .Error
        }
        else {
        #if DEBUG
            GAI.sharedInstance().logger.logLevel = .Verbose
        #else
            GAI.sharedInstance().logger.logLevel = .Error
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
        GAI.sharedInstance().defaultTracker.set(kGAIAppVersion, value: self.appVersion())

        super.initializePlatform(platformData)
    }
    

    override var optOut: Bool {
        didSet {
            GAI.sharedInstance().optOut = self.optOut
        }
    }
    
    
    override func start() {
        if !self.optOut {
            super.start()
            GAI.sharedInstance().optOut = false
        }
    }
    
    
    override func stop() {
        super.stop()
        GAI.sharedInstance().optOut = true
    }
    
    
    override func trackData(data: HEAnalyticsData) {
        if self.optOut || GAI.sharedInstance().optOut {
            return
        }
        
        var JSONString: String?
        if let dataParameters = data.parameters {
            JSONString = HEJSONHelper.canonicalJSONRepresentationWithObject(dataParameters)
        }
        let sendData = GAIDictionaryBuilder.createEventWithCategory(data.category, action:data.event, label:JSONString, value:nil).build()
        GAI.sharedInstance().defaultTracker.send(sendData as [NSObject: AnyObject])
    }

    
    override func trackView(viewController: UIViewController) {
        if self.optOut || GAI.sharedInstance().optOut {
            return
        }

        let tracker = GAI.sharedInstance().defaultTracker
        let title = self.viewControlerTitle(viewController)
        tracker.set(kGAIScreenName, value: title)
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    }

}
