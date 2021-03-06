//
//  HEAnalyticsPlatform.swift
//
//  Created by hsoi on 4/4/15.
//
//  HEAnalytics - Copyright (c) 2015-2016, Hsoi Enterprises LLC
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
open class HEAnalyticsPlatform: NSObject {

    /**
    Initializer.
    
    - parameter platformData: The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
    
    - returns: A properly initialized HEAnalyticsPlatform object.
    */
    required public init(platformData: [String:Any]) {
        super.init()
        initialize(with: platformData)
    }

    
    /**
    Initializes the platform with the given data.
    
    Subclasses are required to override and implement this in whatever way gets the platform's SDK intialized and ready (but not started). Think of it like starting the motor on the car and letting it idle being ready to go (whereas start() is when the car is put in gear and your foot depresses the gas pedal).
    
    Subclasses should invoke super (generally at the end, before returning).
    
    - parameter platformData: The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
    */
    internal func initialize(with platformData: [String:Any]) {

    }
    
    
    /**
    Starts the platform actually recording events.
    
    Subclasses generally will want to override this to start their SDK's collection of data. Note that, depending upon the implementation details of the SDK, you may need to check the  HEAnalyticsPlatform.optOut property to ensure you actually should start collecting or not.
    */
    open func start() {

    }
    
    
    /**
    Stops the platform from actually recording events.
    
    Subclasses will generally want to override this to stop their SDK's collection of data.
    */
    open func stop() {

    }

    /// Has the user opt'd out of data collection? Note this value is not persisted anywhere by HEAnalytics. Exposing this setting in the GUI, persisting the value, restoring the value, and enforcing it generally is the responsibility of the app developer.
    open var optOut: Bool = false
    
    
    /**
    The core function that's actually tracks/logs the analytic event data.
    
    Subclasses will need to override this and implement the SDK's event logging/tracking mechanism.
    
    - parameter data: The HEAnalyticsData with the information to be recorded. It is up to the subclass to interpret, preserve, and convey this data as richly and appropriately as the platform SDK allows.
    */
    open func track(data: HEAnalyticsData) {

    }
    
    
    /**
    Used to track views of a UIViewController.
    
    Subclasses will need to override and implement the SDK's view logging/tracking mechanism.
    
    Consider use of titleFor(viewController:) to help in tracking.
    
    - parameter viewController: The UIViewController to track.
    */
    open func track(viewController: UIViewController) {
        // subclasses expected to override and implement to implement the tracking for that platform.
        // No need to call `super`.
    }
    
    /**
     Used to track specific users.
     
     Subclasses will need to override and implement the SDK's user tracking mechanism.
     
     - parameter user: The HEAnalyticsUser to track.
     */
    open func track(user: HEAnalyticsUser) {
        // subclasses expected to override and implement to implement the tracking for that platform.
        // No need to call `super`.
    }
    
    
    /**
     Used to stop tracking a specific user.
     
     Subclasses will need to override and implement the SDK's user logout/reset mechanism.
     
     - parameter user: The HEAnalyticsUser to stop tracking; optional.
     */
    open func stopTracking(user: HEAnalyticsUser?) {
        // subclasses expected to override and implement to implement the necessary logic for that platform.
        // No need to call `super`.
    }
    
    /**
    Internal function for obtaining the app version.
    
    I like using the `CFBundleShortVersionString` as either a semantic or marketing version, such as "x.y.z". The `CFBundleVersion` then is used as a simple forever-incrementing integer build number. We will concatenate the two versions for a more descriptive version that if an analytics SDK supports it, we can use to set it to have a more robust version reporting.
    
    - returns: an app version string.
    */
    internal var appVersion: String? {
        if let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            let fullVersion = shortVersion + "." + bundleVersion
            return fullVersion
        }
        return nil
    }
    

    /**
    A helper for obtaining the UIViewController "title" for use in track(viewController:).
    
    See UIViewController+HEAnalytics and the HE_analyticsViewTrackingTitle extension
    
    - parameter viewController: The UIViewController to extract a tracking title from
    
    - returns: The title to use for tracking.
    */
    internal func titleFor(viewController: UIViewController) -> String {
        return viewController.HE_analyticsViewTrackingTitle
    }
    
}
