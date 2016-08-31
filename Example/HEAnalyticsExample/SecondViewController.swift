//
//  SecondViewController.swift
//  HEAnalyticsExample
//
//  Created by hsoi on 5/7/15.
//  Copyright (c) 2015 Hsoi Enterprises LLC. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SampleAnalytics.sharedInstance.trackView(self)
    }
    
    override func HE_analyticsViewTrackingTitle() -> String {
        return "Second ViewController"
    }

}

