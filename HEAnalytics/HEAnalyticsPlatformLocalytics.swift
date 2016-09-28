//
//  HEAnalyticsPlatformLocalytics.swift
//
//  Created by Ben Kreeger on 3/17/16.
//  https://github.com/kreeger
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

@objc(HEAnalyticsPlatformLocalytics)
open class HEAnalyticsPlatformLocalytics: HEAnalyticsPlatform {
    // Tracks internals state.
    fileprivate var started = false
    
    /**
     Initializes the platform with the given data.
     
     Subclasses are required to override and implement this in whatever way gets the platform's SDK intialized and ready (but not started). Think of it like starting the motor on the car and letting it idle being ready to go (whereas start() is when the car is put in gear and your foot depresses the gas pedal).
     
     Subclasses should invoke super (generally at the end, before returning).
     
     - parameter platformData: The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
     */
    internal override func initialize(with platformData: [String:Any]) {
        let trackingID = platformData["trackingID"] as! String
        Localytics.integrate(trackingID)
        
        if let dispatchInterval = platformData["dispatchInterval"] as? TimeInterval {
            Localytics.setOptions(["session_timeout": dispatchInterval as NSObject])
        }
        else {
            // Hsoi 2016-09-28 - when I originally wrote this, Localytics had a setSessionTimeoutInterval() API and
            // documented 60 seconds at the default. While updating for Swift 3, I also updated the Localytics SDK
            // and it dropped the lone API call for `setOptions()` using `session_timeout`. There's little documentation
            // on the option and nothing stating what the default is, but Localytics.h's one reference to "timeout"
            // says: BACKGROUND_SESSION_TIMEOUT, (15 seconds by default). Is `BACKGROUND_SESSION_TIMEOUT` the same
            // as the `session_timeout`? I don't know. Either way, I'm sticking with 60 so that MY code at least
            // remains consistent with its prior versions. If you want 15 (or any other value) of course it's
            // easy enough to change by specifying the `dispatchInterval` in the platform data plist.
            Localytics.setOptions(["session_timeout": 60 as NSObject])
        }
        
        super.initialize(with: platformData)
    }
    
    
    /// Has the user opt'd out of data collection? Note this value is not persisted anywhere by HEAnalytics. Exposing this setting in the GUI, persisting the value, restoring the value, and enforcing it generally is the responsibility of the app developer.
    open override var optOut: Bool {
        didSet {
            if optOut {
                stop()
            } else {
                start()
            }
        }
    }
    
    
    /**
     Starts the platform actually recording events.
     
     Subclasses generally will want to override this to start their SDK's collection of data. Note that, depending upon the implementation details of the SDK, you may need to check the  HEAnalyticsPlatform.optOut property to ensure you actually should start collecting or not.
     */
    open override func start() {
        guard !optOut && !started else { return }
        
        super.start()
        Localytics.openSession()
        Localytics.upload()
        self.started = true
    }
    
    
    /**
     Stops the platform from actually recording events.
     
     Subclasses will generally want to override this to stop their SDK's collection of data.
     */
    open override func stop() {
        guard started else { return }
        
        super.stop()
        Localytics.dismissCurrentInAppMessage()
        Localytics.closeSession()
        Localytics.upload()
        self.started = false
    }
    
    
    /**
     The core function that's actually tracks/logs the analytic event data.
     
     Subclasses will need to override this and implement the SDK's event logging/tracking mechanism.
     
     - parameter data: The HEAnalyticsData with the information to be recorded. It is up to the subclass to interpret, preserve, and convey this data as richly and appropriately as the platform SDK allows.
     */
    open override func track(data: HEAnalyticsData) {
        guard !optOut && started else { return }
        
        // Hsoi 2016-09-28 - While we allow the data.parameters value to be anything (because different analytics
        // platforms work in their own ways), LOCALYTICS DOES NOT WANT THIS.
        //
        // As of (at least) Localytics SDK v4.1.0, the event attributes are specified in their ObjC header as:
        //
        //  nullable NSDictionary<NSString *, NSString *> *
        //
        // A nice way that Swift improved ObjC - lightweight generics! So Localytics expects string values.
        //
        // Our cast here is what Xcode 8 suggested to us as a fix, and I think it's OK -- because the hope is that
        // you will test your code, and if there's a problem with the data you pass, it's better to crash now
        // and get you to detect it sooner rather than later (and hopefully you'll read this comment and it
        // provides a hint as to the issue and how to resolve it).
        Localytics.tagEvent(data.event, attributes: data.parameters as! [String : String]?)
    }
    
    
    /**
     Used to track views of a UIViewController.
     
     Subclasses will need to override and implement the SDK's view logging/tracking mechanism.
     
     Consider use of titleFor(viewController:) to help in tracking.
     
     - parameter viewController: The UIViewController to track.
     */
    open override func track(viewController: UIViewController) {
        guard !optOut && started else { return }
        
        Localytics.tagScreen(titleFor(viewController: viewController))
    }
    
    /**
     Used to track specific users.
     
     Subclasses will need to override and implement the SDK's user tracking mechanism.
     
     - parameter user: The HEAnalyticsUser to track.
     */
    open override func track(user: HEAnalyticsUser) {
        guard !optOut && started else { return }
        
        Localytics.setCustomerId(user.identifier)
        if let firstName = user.firstName {
            Localytics.setCustomerFirstName(firstName)
        }
        
        if let lastName = user.lastName {
            Localytics.setCustomerLastName(lastName)
        }
        
        if let fullName = user.fullName {
            Localytics.setCustomerFullName(fullName)
        }
        
        if let email = user.emailAddress {
            Localytics.setCustomerEmail(email)
        }
    }
}
