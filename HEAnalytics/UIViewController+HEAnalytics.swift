//
//  UIViewController+HEAnalytics.swift
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
HEAnalytic's extension to UIViewController.
*/
public extension UIViewController {
    
    /**
    HE_analyticsViewTrackingTitle is an effort to always provide a stable value for view tracking by HEAnalytics.
    
    By default, it wants to return the title of the ViewController. If however the ViewController does not have
    a title (either nil or empty), it will return the name of the ViewController class (e.g. "MyUIViewController").
    
    You can also implement this method in your UIViewController subclasses. This can be useful if you want to track
    views by a more stable identifier. For example, a ViewController might have a title based upon the content of
    the ViewController, but you just want to track they went to "this view" so you could override this method
    to return a stable string constant.
    
    
    - returns: A string to use as the view tracking title.
    */
    public func HE_analyticsViewTrackingTitle() -> String {
        if let title = title {
            if !title.isEmpty {
                return title
            }
        }
        return NSStringFromClass(self.dynamicType)
    }

}
