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

public class HEAnalyticsPlatform: NSObject {

    override init() {
        super.init()
    }

    
    internal func initializePlatform() {
        // Intended for subclasses to override and implement in whatever way makes sense to
        // get the platform initialized and generally started (tho perhaps not yet event tracking... think
        // of it like starting the engine but you haven't put the transmision in "Drive" and put your
        // foot on the gas pedal -- that happens in start()).
        //
        // You should call "super" at the end of your subclass work.
    }
    
    
    func start() {
        // subclasses should override, if relevant.
        //
        // call super. yeah, today it does nothing, but it doesn't hurt.
    }
    
    
    func stop() {
        // subclasses should override, if relevant.
        //
        // call super. yeah, today it does nothing, but it doesn't hurt.
    }

    
    var optOut: Bool = false
    
    
    func trackData(data: HEAnalyticsData) {
        // subclasses expected to override and implement to implement the tracking for that platform.
        // No need to call `super`.
    }
    
    
    func trackView(viewController: UIViewController) {
        // subclasses expected to override and implement to implement the tracking for that platform.
        // No need to call `super`.
    }
    

    // Helper for obtaining some sort of "title" of the given view controller for trackView() purposes.
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

    
// MARK: - Internal Config
    
    internal var platformKey: String {
        return "subclass-must-override"
    }
    
    internal func loadPlatformConfig() -> [NSObject:AnyObject] {
        let configFileURL = NSBundle.mainBundle().URLForResource("AnalyticsPlatformConfig", withExtension: "plist")
        assert(NSFileManager.defaultManager().fileExistsAtPath(configFileURL!.path!), "AnalyticsPlatformConfig.plist does not exist in the mainBundle")
        
        var platformConfig:[NSObject:AnyObject] = [NSObject:AnyObject]()
        if let theURL = configFileURL {
            if let configDict = NSDictionary(contentsOfURL: theURL) {
                if let platformDict = configDict[self.platformKey] as? [NSObject:AnyObject] {
                    platformConfig = platformDict
                }
            }
        }

        return platformConfig
    }
}
