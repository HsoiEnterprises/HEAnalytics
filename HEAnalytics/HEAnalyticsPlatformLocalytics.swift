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
public class HEAnalyticsPlatformLocalytics: HEAnalyticsPlatform {
    // Tracks internals state.
    private var started = false
    
    /**
     Initializes the platform with the given data.
     
     Subclasses are required to override and implement this in whatever way gets the platform's SDK intialized and ready (but not started). Think of it like starting the motor on the car and letting it idle being ready to go (whereas start() is when the car is put in gear and your foot depresses the gas pedal).
     
     Subclasses should invoke super (generally at the end, before returning).
     
     - parameter platformData: The platform's unique settings data, usually including whatever identifier/key is used to identify this app, and any other configuration data that may be relevant to the platform. The keys and values for each platform is unique to that platform.
     */
    internal override func initializePlatform(platformData: [NSObject:AnyObject]) {
        let trackingID = platformData["trackingID"] as! String
        Localytics.integrate(trackingID)
        
        if let dispatchInterval = platformData["dispatchInterval"] as? NSTimeInterval {
            Localytics.setSessionTimeoutInterval(dispatchInterval)
        }
        else {
            Localytics.setSessionTimeoutInterval(60) // Localytics's documented default.
        }
        
        super.initializePlatform(platformData)
    }
    
    
    /// Has the user opt'd out of data collection? Note this value is not persisted anywhere by HEAnalytics. Exposing this setting in the GUI, persisting the value, restoring the value, and enforcing it generally is the responsibility of the app developer.
    public override var optOut: Bool {
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
    public override func start() {
        guard !optOut && !started else { return }
        
        super.start()
        Localytics.openSession()
        Localytics.upload()
    }
    
    
    /**
     Stops the platform from actually recording events.
     
     Subclasses will generally want to override this to stop their SDK's collection of data.
     */
    public override func stop() {
        guard started else { return }
        
        super.stop()
        Localytics.dismissCurrentInAppMessage()
        Localytics.closeSession()
        Localytics.upload()
    }
    
    
    /**
     The core function that's actually tracks/logs the analytic event data.
     
     Subclasses will need to override this and implement the SDK's event logging/tracking mechanism.
     
     - parameter data: The HEAnalyticsData with the information to be recorded. It is up to the subclass to interpret, preserve, and convey this data as richly and appropriately as the platform SDK allows.
     */
    public override func trackData(data: HEAnalyticsData) {
        guard !optOut && started else { return }
        
        Localytics.tagEvent(data.event, attributes: data.parameters)
    }
    
    
    /**
     Used to track views of a UIViewController.
     
     Subclasses will need to override and implement the SDK's view logging/tracking mechanism.
     
     Consider use of viewControlerTitle() to help in tracking.
     
     - parameter viewController: The UIViewController to track.
     */
    public override func trackView(viewController: UIViewController) {
        guard !optOut && started else { return }
        
        Localytics.tagScreen(viewControlerTitle(viewController))
    }
    
    /**
     Used to track specific users.
     
     Subclasses will need to override and implement the SDK's user tracking mechanism.
     
     - parameter user: The HEAnalyticsUser to track.
     */
    public override func trackUser(user: HEAnalyticsUser) {
        guard !optOut && started else {
            return
        }
        
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
