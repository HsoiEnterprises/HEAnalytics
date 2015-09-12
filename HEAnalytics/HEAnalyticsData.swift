//
//  HEAnalyticsData.swift
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

/// HEAnalyticsData - the data structure for encapsulating data about an analytic event.
public class HEAnalyticsData: NSObject {

    // Hsoi 2015-04-04 - strictly speaking, HEAnalyticsData should be a struct, but since it may need to be accessed from ObjC, it can't be.

    /**
    AnalyticsCategory is an enumeration of event categories, used to help hierarchically structure and organize an analytic event.
    
    Some analytics platforms directly utilize categories (e.g. Google Analytics). Those that do not should still strive to take advantage of the categorization (e.g. Flurry events will have the category name and event name concatenated to make the actual logged event).
    
    You should consider using Swift's support for enum extensions to add your own categories. You can of course use raw strings, but the enum, like using any sort of constant, can help with error reduction and code maintenance.
    
    - Activity:     Events dealing with "activity", such as from UIActivityViewController.
    - Application:  Events from the "application", such as UIApplicationDelegate notifications.
    - General:      A general "catch-all" category.
    - View:         Events dealing with views, such as tracking that a view did appear.
    - Error:        If you log errors as events, use this category.
    - Settings:     Events working with in-app settings.
    - Sharing:      A category for when the user "shares".
    - Support:      For tracking support events (e.g. tapped on the button to email tech support)
    - VersionCheck: If your app uses built-in version checking, track it with this category.
    */
    public enum AnalyticsCategory : String {
        case Activity                   =   "Activity"
        case Application                =   "Application"
        case General                    =   "General"
        case View                       =   "View"
        case Error                      =   "Error"
        case Settings                   =   "Settings"
        case Sharing                    =   "Sharing"
        case Support                    =   "Support"
        case VersionCheck               =   "VersionCheck"
    }
    
    
    /**
    The category of the event. Required.
    
    A String, to allow for flexibility, but can use an AnalyticsCategory(rawValue) for consistency.
    
    Events have an organizational hierarchy of category, event within the category, and then parameters of the event.
    */
    private (set) var category: String = AnalyticsCategory.General.rawValue
    
    
    /**
    The event. Required.
    
    A String, to allow for flexibility.
    
    Events have an organizational hierarchy of category, event within the category, and then parameters of the event.
    */
    private (set) var event: String = "<unknown>"
    
    
    /**
    The event parameters. Optional.
    
    Typed as an [NSObject:AnyObject] to maximize interoperability with NSDictionary and Objective-C code, but it is expected that the key is a (NS)String and the value is a plist-able/json-able type such as string, number, array/dictionary (of string, number). The data won't necessarily be santized before being passed along to a platform API, so the general recommendation is in your HEAnalytics subclass's specific event tracking functions to take the app-provided raw data to track and convert it to a "safe" type (strings and numbers are best), then pass this sanitized type/data in the event parameters.

    Events have an organizational hierarchy of category, event within the category, and then parameters of the event.
    */
    private (set) var parameters: [NSObject:AnyObject]?

    
    /**
    Designated Initializer.
    
    Creates an HEAnalyticsData object from the given strings and optional parameters.
    
    NB: While this may be the designated initializer, it is only because it satisfies the lowest common denominator
    for how categories and events must be handled: as a string. This is what is ultimately required by the
    analytics platforms and of course provides the client with as much flexibility as they desire. Plus, it maximizes
    interoperability with Objective-C.
    
    HOWEVER, it is recommended to utilize the AnalyticsCategory/Event(as String) initializers instead, and to
    extend those enums as needed. This will provide for clearer and less error-prone code over time.
    
    - parameter category:   The event category.
    - parameter event:      The event.
    - parameter parameters: The optional parameters. Typed as an [NSObject:AnyObject] to maximize interoperability with NSDictionary and Objective-C code, but it is expected that the key is a (NS)String and the value is a plist-able/json-able type such as string, number, array/dictionary (of string, number). The data won't necessarily be santized before being passed along to a platform API, so the general recommendation is in your HEAnalytics subclass's specific event tracking functions to take the app-provided raw data to track and convert it to a "safe" type (strings and numbers are best), then pass this sanitized type/data in the event parameters.
    
    - returns: An HEAnalyticsData object, suitable for passing to HEAnalytics.trackData()
    */
    public init(category: String, event: String, parameters: [NSObject:AnyObject]? = nil) {
        self.category = category
        self.event = event
        self.parameters = parameters
    }


    /**
    Convenience (and generally preferred) initializer.
    
    Creates an HEAnalyticsData object from the given AnalyticsCategory and a string for the event.
    
    - parameter category:   The AnalyticsCategory of the event to track
    - parameter event:      A string/name of the event to track
    - parameter parameters: The optional parameters. See comments on the designated initializer.
    
    - returns: An HEAnalyticsData object, suitable for passing to HEAnalytics.trackData()
    */
    public convenience init(category: AnalyticsCategory, event: String, parameters: [NSObject:AnyObject]? = nil) {
        self.init(category: category.rawValue, event: event, parameters: parameters)
    }

}
