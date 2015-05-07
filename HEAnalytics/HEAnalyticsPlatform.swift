//
//  HEAnalyticsPlatform.swift
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

import Foundation
import UIKit

/**
HEAnalyticsPlatform provides the base class and structure for implementing an analytics platform's specific API and integrating it into the HEAnalytics framework.
*/
@objc(HEAnalyticsPlatform)
public class HEAnalyticsPlatform: NSObject {

    /**
    Initializer.
    
    :param: platformData The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
    
    :returns: A properly initialized HEAnalyticsPlatform object.
    */
    required public init(platformData: [NSObject:AnyObject]) {
        super.init()
        self.initializePlatform(platformData)
    }

    
    /**
    Initializes the platform with the given data.
    
    Subclasses are required to override and implement this in whatever way gets the platform's SDK intialized and ready (but not started). Think of it like starting the motor on the car and letting it idle being ready to go (whereas start() is when the car is put in gear and your foot depresses the gas pedal).
    
    Subclasses should invoke super (generally at the end, before returning).
    
    :param: platformData The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
    */
    internal func initializePlatform(platformData: [NSObject:AnyObject]) {

    }
    
    
    /**
    Starts the platform actually recording events.
    
    Subclasses generally will want to override this to start their SDK's collection of data. Note that, depending upon the implementation details of the SDK, you may need to check the  HEAnalyticsPlatform.optOut property to ensure you actually should start collecting or not.
    */
    func start() {

    }
    
    
    /**
    Stops the platform from actually recording events.
    
    Subclasses will generally want to override this to stop their SDK's collection of data.
    */
    func stop() {

    }

    /// Has the user opt'd out of data collection? Note this value is not persisted anywhere by HEAnalytics. Exposing this setting in the GUI, persisting the value, restoring the value, and enforcing it generally is the responsibility of the app developer.
    var optOut: Bool = false
    
    
    /**
    The core function that's actually tracks/logs the analytic event data.
    
    Subclasses will need to override this and implement the SDK's event logging/tracking mechanism.
    
    :param: data The HEAnalyticsData with the information to be recorded. It is up to the subclass to interpret, preserve, and convey this data as richly and appropriately as the platform SDK allows.
    */
    func trackData(data: HEAnalyticsData) {

    }
    
    
    /**
    Used to track views of a UIViewController.
    
    Subclasses will need to override and implement the SDK's view logging/tracking mechanism.
    
    Consider use of viewControlerTitle() to help in tracking.
    
    :param: viewController The UIViewController to track.
    */
    func trackView(viewController: UIViewController) {
        // subclasses expected to override and implement to implement the tracking for that platform.
        // No need to call `super`.
    }
    

    /**
    A helper for obtaining the UIViewController "title" for use in trackView().
    
    See UIViewController+HEAnalytics and the HE_analyticsViewTrackingTitle() extension
    
    :param: viewController The UIViewController to extract a tracking title from
    
    :returns: The title to use for tracking.
    */
    internal func viewControlerTitle(viewController: UIViewController) -> String {
        var title: String = "<unknown>"
        if viewController.respondsToSelector(Selector("HE_analyticsViewTrackingTitle")) {
            title = viewController.HE_analyticsViewTrackingTitle()
        }
        else {
            if let viewTitle = viewController.title {
                title = viewTitle
            }
        }
        return title
    }
    
}
