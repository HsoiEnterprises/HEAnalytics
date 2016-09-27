//
//  SampleAnalytics.swift
//  HEAnalyticsExample
//
//  Created by hsoi on 5/8/15.
//  Copyright (c) 2015 Hsoi Enterprises LLC. All rights reserved.
//

import Foundation

/** SampleAnalytics Class

*/
class SampleAnalytics : HEAnalytics {

    static let sharedInstance = SampleAnalytics()
    
    
    func selectedTab1() {
        let data = HEAnalyticsData(category: .View, event: "Selected Tab 1")
        self.track(data: data)
    }

    func selectedTab2() {
        let data = HEAnalyticsData(category: .View, event: "Selected Tab 2")
        self.track(data: data)
    }

}
