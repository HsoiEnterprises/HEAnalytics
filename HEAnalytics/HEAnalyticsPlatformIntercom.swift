//
//  HEAnalyticsPlatformIntercom.swift
//
//  Created by hsoi on 6/5/15.
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
import Intercom

/**
An HEAnalyticsPlatform for the Intercom.io platform.
*/

@objc(HEAnalyticsPlatformIntercom)
public class HEAnalyticsPlatformIntercom: HEAnalyticsPlatform {
   
    public required init(platformData: [NSObject:AnyObject]) {
        super.init(platformData: platformData)
    }
    
    public override func initializePlatform(platformData: [NSObject:AnyObject]) {
        
        Intercom.reset()
        
        let apikey = platformData["apiKey"] as! String
        let appID = platformData["appID"] as! String
        Intercom.setApiKey(apikey, forAppId: appID)
        
        if let logging = platformData["enableLogging"] as? Bool where logging {
            Intercom.enableLogging()
        }
        
        super.initializePlatform(platformData)
    }
    
    
    // Hsoi 2015-06-05 - As far as I can tell about Intercom, it doesn't really have any sort of mechanism to enforce
    // optOut/in or start/stop. So we'll just keep track of it ourselves.
    private var started: Bool = false
    
    public override func start() {
        if !self.optOut {
            if !self.started {
                super.start()
                self.started = true
            }
        }
    }
    
    
    public override func stop() {
        super.stop()
        self.started = false
    }
    
    
    public override func trackData(data: HEAnalyticsData) {
        if self.optOut || !self.started {
            return
        }

        let event = data.category + " - " + data.event
        if let dataParameters = data.parameters where dataParameters.count > 0 {
            Intercom.logEventWithName(event, metaData: dataParameters)
        }
        else {
           Intercom.logEventWithName(event)
        }
    }
    
    
    public override func trackView(viewController: UIViewController) {
        if self.optOut || !self.started {
            return
        }
        
        let title = self.viewControlerTitle(viewController)
        let event = "TrackView - " + title
        Intercom.logEventWithName(event)
    }
    
}
