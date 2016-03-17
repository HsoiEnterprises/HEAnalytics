//
//  HEAnalyticsUser.swift
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

/// The data structure for encapsulating data about a user object to track via analytics.
public class HEAnalyticsUser: NSObject {
    
    /// The user's unique identifier. Required.
    private (set) var identifier: String = ""
    /// The user's first name. Optional.
    private (set) var firstName: String?
    /// The user's last name. Optional.
    private (set) var lastName: String?
    /// The user's full name. Optional. If not provided, first and last name will be used.
    private (set) var fullName: String?
    /// The user's email address. Optional.
    private (set) var emailAddress: String?
    /// Any extra parameters to be sent back as auxiliary data on behalf of a user.
    private (set) var parameters: [NSObject:AnyObject]?
    
    
    /**
     Designated Initializer.
     
     Creates an HEAnalyticsUser object from the given strings and optional parameters.
     
     - parameters:
        - identifier: The user's unique identifier.
        - firstName: The user's first name. Optional.
        - lastName: The user's last name. Optional.
        - fullName: The user's full name. Optional. If not provided, first and last name will be used.
        - emailAddress: The user's email address. Optional.
        - parameters: The optional parameters. Typed as an [NSObject:AnyObject] to maximize interoperability with NSDictionary and Objective-C code, but it is expected that the key is a (NS)String and the value is a plist-able/json-able type such as string, number, array/dictionary (of string, number). The data won't necessarily be santized before being passed along to a platform API, so the general recommendation is in your HEAnalytics subclass's specific event tracking functions to take the app-provided raw data to track and convert it to a "safe" type (strings and numbers are best), then pass this sanitized type/data in the event parameters.
     
     - returns: An HEAnalyticsUser object, suitable for passing to HEAnalytics.trackUser()
     */
    public init(identifier: String, firstName: String? = nil, lastName: String? = nil, fullName: String? = nil, emailAddress: String? = nil, parameters: [NSObject:AnyObject]? = nil) {
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        if self.fullName == nil {
            let joinedName = [firstName, lastName].flatMap { $0 }.joinWithSeparator(" ")
            self.fullName = joinedName.isEmpty ? nil : joinedName
        }
        
        self.emailAddress = emailAddress
        self.parameters = parameters
    }
}
