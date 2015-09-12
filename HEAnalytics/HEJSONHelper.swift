//
//  HEJSONHelper.swift
//  HEAnalytics
//
//  Created by hsoi on 4/6/15.
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
HEJSONHelper provides some simple helpers for working with JSON.
*/
public class HEJSONHelper: NSObject {
   
    
// MARK: - Filtering
    
    /**
    Given a value, filter out NSNull by converting to nil.
    
    This is needed because some JSON parsing can return "null" values, and it's easier in client code to
    just treat it as nil, since effectively that is what is meant. Keeps client code from having to always
    conditionalize on the potential for NSNull, which is a non-nil object but semantically we generally want
    to treat it as nil. This way everything is either nil or a valid useable object.
    
    - parameter value: The value to filter.
    
    - returns: if value is nil, return nil. If value is NSNull, return nil. If value is something else, return something else.
    */
    public class func filterNull(obj: AnyObject?) -> AnyObject? {
        if obj is NSNull {
            return nil
        }
        return obj
    }
    
    
    /**
    Given a value, filter out NSNulland empty strings by converting to nil.
    
    This is needed because some JSON parsing can return "null" values, and it's easier in client code to
    just treat it as nil, since effectively that is what is meant. Keeps client code from having to always
    conditionalize on the potential for NSNull, which is a non-nil object but semantically we generally want
    to treat it as nil. As well, sometimes empty strings can be returned when intending to specify a null/nil/no-value
    situation. This way everything is either nil or a valid useable object.
    
    NB: sometimes an non-nil-but-empty string is a valid response, so it is up to you to decide upon appropriate handling.
    
    - parameter value: The value to filter.
    
    - returns: if value is nil, return nil. If value is NSNull, return nil. If the value is a string and the string is empty,
    return nil. For all other things, return that thing.
    */
    public class func filterNullAndEmpty(obj: AnyObject?) -> AnyObject? {
        if let objString = obj as? String where objString.isEmpty {
            return nil
        }
        
        return filterNull(obj)
    }
    
    
// MARK: - Canonicalization

    /**
    Returns the given JSON object with a canonicalized JSON representation string.
    
    Note: the return is a string of JSON, not JSON itself. The intent is to allow obtaining JSON in a stable
    and ordered format, to facilitate logging, reporting, comparing, human-eyes reading, etc..
    
    Why this? Items stored in a (NS)Dictionary have no guaranteed order. When converting to a JSON string, one 
    conversion may put "keyA" before "keyB", but another conversion may put "keyB" first. Many times this doesn't matter, 
    but sometimes it can (see above "Note").
    
    The ordering will simply be sorting the keys alphabetically.
    
    No ordering changes happen to contents of arrays, as ordering of arrays is generally intended as-is
    and something we shouldn't change.
    
    - parameter object:  A JSON object (array, dictionary), able to be converted to JSON. This means that all
                    contents are also JSON-legal objects (array, dictionary, string, number, boolean, null)
    
    - returns: The object, converted to a canonicalized JSON string.
    */
    
    public class func canonicalJSONRepresentationWithObject(object: AnyObject?) -> String {
        var json = ""
        
        // Hsoi 2015-04-11 - legally, the "top-level" of JSON must be an object ("{}") or an array ("[]"), so that's what this works upon.
        
        if let object:AnyObject = object {
            switch object {
            case let dictionary as [NSObject:AnyObject]:
                json = HEJSONHelper.canonicalJSONRepresentationWithDictionary(dictionary)
                
            case let array as [AnyObject]:
                json = HEJSONHelper.canonicalJSONRepresentationWithArray(array)
                
            default:
                break
            }
        }
        
        return json
    }
    
    
    /// Private function for converting a dictionary to canonical JSON representation.
    private class func canonicalJSONRepresentationWithDictionary(dictionary:[NSObject:AnyObject]?) -> String {

        // Hsoi 2014-11-10 - This canonical JSON support is based upon: http://stackoverflow.com/a/26591452/1737738
        //
        // Our use-case is due to Analytics. Whereas Flurry's analytics lets you log a dictionary of parameters
        // and have them treated as unique bits of data, Google's analytics does not provide for such support. So what is done
        // is the dictionary of parameters is converted to a JSON string and the string logged as the "label" of
        // the GAI event.
        //
        // Well, there's a problem with that.
        //
        // NSDictionary -- by defintion -- stores its data in whatever order it deems most appropriate to do what it
        // needs to do. We cannot and do not have control over it. And so, it's very possible to get data where
        // key1:value1 comes before key2:value2.. but another time key2:value2 comes BEFORE key1:value1. While this
        // generally doesn't matter for most JSON work, it totally matters for this GAI stuff because the "label"
        // field is just treated as a string by Google -- simple string comparison, and while we can tell that
        // "key1, key2" is the same as "key2, key1", GAI cannot and so data reporting can be skewed.
        //
        // And so, we have this as an attempt to canonicalize the JSON output.
        //
        // I have taken the code from the above SO posting and molded it a bit to make it work. This includes adding
        // support for numbers, nulls, and booleans
        
        var json = ""
        json += "{"
        
        if let dictionary = dictionary {
            var keys = dictionary.keys.sort {
                (obj1, obj2) in

                // Forcing casts because they SHOULD be strings. If they are not, then there's programmer error somewhere
                // and we should crash to become aware of whatever the problem is.
                let s1 = obj1 as! String
                let s2 = obj2 as! String
                return s1 < s2
            }
            
            for index in 0..<keys.count {
                let key = keys[index]
                json += "\"\(key)\":"

                let item: AnyObject = dictionary[key]!
                
                switch item {
                case let string as String:
                    json += "\"\(HEJSONHelper.canonicalJSONRepresentationWithString(string))\""
                    
                case let attributedString as NSAttributedString:
                    json += "\"\(HEJSONHelper.canonicalJSONRepresentationWithString(attributedString.string))\""

                case let dictionary as [NSObject:AnyObject]:
                    json += HEJSONHelper.canonicalJSONRepresentationWithDictionary(dictionary)

                case let array as [AnyObject]:
                    json += HEJSONHelper.canonicalJSONRepresentationWithArray(array)

                case let number as NSNumber:
                    if HEJSONHelper.isBool(number) {
                        let itemBool = number as Bool
                        if itemBool == true {
                            json += "true"
                        }
                        else {
                            json += "false"
                        }
                    }
                    else {
                        json += "\(number)"
                    }

                case is NSNull:
                    json += "null"
                    
                default:
                    assertionFailure("canonicalJSONRepresentationWithDictionary does not have support for class: '\(NSStringFromClass(item.dynamicType))' for data: \(item.description)")
                }
                
                if index < (keys.count - 1) {
                    json += ","
                }
            }
        }
        
        json += "}"
        
        return json
    }


    /// Private function for converting an array to canonical JSON representation.
    private class func canonicalJSONRepresentationWithArray(array: [AnyObject]) -> String {
        var json = ""
        json += "["
        
        for index in 0..<array.count {
            let item: AnyObject = array[index]

            switch item {
            case let string as String:
                json += "\"\(HEJSONHelper.canonicalJSONRepresentationWithString(string))\""

            case let attributedString as NSAttributedString:
                json += "\"\(HEJSONHelper.canonicalJSONRepresentationWithString(attributedString.string))\""

            case let dictionary as [NSObject:AnyObject]:
                json += HEJSONHelper.canonicalJSONRepresentationWithDictionary(dictionary)

            case let array as [AnyObject]:
                json += HEJSONHelper.canonicalJSONRepresentationWithArray(array)

            case let number as NSNumber:
                if HEJSONHelper.isBool(number) {
                    let itemBool = number as Bool
                    if itemBool == true {
                        json += "true"
                    }
                    else {
                        json += "false"
                    }
                }
                else {
                    json += "\(number)"
                }

            case is NSNull:
                json += "null"

            default:
                assertionFailure("canonicalJSONRepresentationWithArray does not have support for class: '\(NSStringFromClass(item.dynamicType))' for data: \(item.description)")
            }
            
            if index < (array.count - 1) {
                json += ","
            }
        }
        
        json += "]"
        
        return json
    }
    
    
    /// Private function for converting a string to canonical JSON representation.
    private class func canonicalJSONRepresentationWithString(string: String) -> String {
        let dict = ["a":string]
        var error: NSError?
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
            if let json = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
                let colonQuote = json.rangeOfString(":\"")
                let lastQuote = json.rangeOfString("\"", options: NSStringCompareOptions.BackwardsSearch)
                let range = NSMakeRange(colonQuote.location + 2, lastQuote.location - colonQuote.location - 2)
                let rc = json.substringWithRange(range)
                return rc
            }
            else {
                #if DEBUG
                NSLog("An error converting JSON to string")
                #endif
                return "string conversion error"
            }
        } catch let error1 as NSError {
            error = error1
            #if DEBUG
            NSLog("An error serializing string json: \(error!.description)")
            #endif
            return "error"
        }
    }
    
    // Hsoi 2015-04-11 - It is difficult to tell the difference between a "number" and a "bool", since in many
    // respects a Bool is-a Number. Depending what class-type test we did first a value of '0' could be considered
    // '0' or 'false'. In our needs here, we need '0' to be '0' and 'false' to be 'false'. So we have this function to
    // help us ensure to treat a boolean value (a json value of 'true' or 'false') as a Bool and not an Int.
    //
    // This is based upon some logic I found in SwiftyJSON.
    private class func isBool(obj: AnyObject?) -> Bool {
        if let obj:AnyObject = obj {
            let trueNumber = NSNumber(bool: true)
            let falseNumber = NSNumber(bool: false)
            let trueObjCType = String.fromCString(trueNumber.objCType)
            let falseObjCType = String.fromCString(falseNumber.objCType)
            let objCType = String.fromCString(obj.objCType)
            
            if (obj.compare(trueNumber) == NSComparisonResult.OrderedSame && objCType == trueObjCType) || (obj.compare(falseNumber) == NSComparisonResult.OrderedSame && objCType == falseObjCType) {
                return true
            }
        }
        
        return false
    }

}
