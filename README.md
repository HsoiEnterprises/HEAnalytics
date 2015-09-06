<!---![Build Status](https://travis-ci.org/HsoiEnterprises/HEAnalytics.svg) -->
![Cocoapods Compatible](https://img.shields.io/cocoapods/v/HEAnalytics.svg)
![License](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)

# HEAnalytics
A simple Swift-based framework for iOS app analytics across various and selectable analytics platforms.


# Background and Approach

Apps want analytics, and analytics are inherently app-specific. However, much of the logic for making analytics go is the same across apps, and one bit of complexity to manage is the inevitable desire to track analytics across multiple analytics platforms (Flurry, Google Analytics, Mixpanel, etc.). Having been a part of enough apps/projects that needed such things, and having dealt with some headaches of other approaches, this is something I came up with to try to manage those issues. It's just one way to approach this problem.

## Flexible Platform Choice

Some apps want to use platform X, some way to use Y, some way to use both X and Y. Inevitably those platforms do things different, so the complexity of contending with their API differences should be something the app developer shouldn't have to worry about. Let that all happen within the analytics framework.

As well, try to be as robust as possible in utilizing that platform's API and features, but bridging functionality where required. For example, Flurry has a nice way of tracking event parameters but Google Analytics does not, so `HEAnalytics` does the best it can to provide the event parameters in a useful manner under GAI. On the other side, GAI has a nice way of tracking screen views while Flurry essentially requires you to treat it as another event; `HEAnalytcs` at least tries to make this event easily discernable from the other events.

Need to support a new platform? Subclass `HEAnalyticsPlatform` and add it to your `AnalyticsPlatformConfig.plist`.

## Configuration Options

Platform configuration comes by way of a `AnalyticsPlatformConfig.plist` file within the main app bundle. This allows for greater flexibility in build and runtime configuration. For example, a white-label product could create a `AnalyticsPlatformConfig.plist` per product and your build system brings in the proper .plist file at build time. Or perhaps based upon build configuration (Debug vs. Release) you may choose a different configuration (e.g. you have a dev analytics account so your daily dev work doesn't skew your true analytics data).

## Uniformity

Events generally are identified as a string. However this can be a hassle and introduce errors if one isn't careful. The power of Swift enums, along with the suggested design approach of subclassing and centralization, helps minimize the potential for such errors.

## Centralization and Abstraction

Often analytics are approached by directly accessing the API at the point in the app code where the analytic needs to be logged; the API is either directly calling an analytics platform API or calling some basic wrapper. While reasonable, I found over time this approach did not scale nor maintain well. Instead, I prefer to wrap up and abstract away all the gory details of analytics into the analytics wrapper class (`HEAnalytics` or a subclass) so that the client code merely calls one function passing whatever information is relevant to log.

This allows all analytics details to be centralized in one file. This can make tracking and modification easier as the project carries on.

It enables logic for converting the data-to-track into something the analytics APIs can understand to be performed somewhere else so as to keep the client code cleaner and easier to read. As well, many times while a particular analytic event may be unique in its use in the app, many times the parameters to track are similar across events. By encapsulating such logic into a single location, code reuse can be facilitated so you can write the "parameter conversion" code once and multiple event trackers can easily reuse.


# Supported OS and SDK

Developed with

- Xcode 6.4
- Swift 1.2
- iOS 8

It should work with iOS 7, but has not been extensively tested.

No effort has been made to make this work on Mac OS X, and there are presently no plans to do so.


# Installation

Installation can be performed as a git submodule or via Cocoapods.

## Submodule

Add the HEAnalytics source files to your project.  You can omit `HEAnalyticsPlatform` subclasses for platforms you don't intend to support.

You will also need to obtain and integrate the analytics platform SDK of your choice (available separately and many are available via Cocoapods).

## Cocoapods

```ruby
pod "HEAnalytics", :subspecs => ["Flurry", "GoogleAnalytics"]
```


# Usage

## AnalyticsPlatformConfig.plist

Create an `AnalyticsPlatformConfig.plist` file. The structure of this file is fairly simple. The plist root is a dictionary. Each entry in the root dictionary is another dictionary, the key of which is the class name of the `HEAnalyticsPlatform` subclass you want to support – the subclass name is important as `HEAnalytics` uses this to perform a dynamic instantiation of the named class. Within the platform dictionary, place the platform-specific configuration info. Refer to each `HEAnalyticsPlatform[subclass].initializePlatform()` implementation for knowledge of what keys/values are supported.

For example, if you want to support both Flurry and Google Analytics, your file might look like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>HEAnalyticsPlatformGAI</key>
	<dict>
		<key>trackingID</key>
		<string>UA-12345678-1</string>
		<key>dispatchInterval</key>
		<integer>15</integer>
	</dict>
	<key>HEAnalyticsPlatformFlurry</key>
	<dict>
		<key>apiKey</key>
		<string>ABC123DEF456GHI789J0</string>
	</dict>
</dict>
</plist>
```

It is up to you and your project needs as to how the plist file is integrated into your project. It may be as simple as adding the file to the project and ensuring it is copied into the app bundle during the "Copy Bundle Resources" build phase. It may be that you add a "Run Script" build phase that copies in a different plist file depending upon the build configuration (i.e. one configuration for debug builds, another for release builds). How the file is added to the main bundle is up to you, just ensure that it is.

**In the Example code, be sure to look at the `AnalyticsPlatformConfig` folder, as well as the `Run Script - HEAnalytics` build phase (and `AppBuildPostflight.rb` build script). This is one way to integrate.**


## Subclassing and Integrating `HEAnalytics` 

While not required, it's **strongly** recommended to subclass `HEAnalytics` and that your application use this subclass.

First, you can make your subclass a singleton. Yes I know the arguments for and against singleton, and I believe this is a case where it's not so evil to use a singleton pattern. However, there is nothing that requires or mandates singleton.

Second, `HEAnalytics` ams to provide a unified abstraction layer for analytics platforms, allowing calling code to be simpler, cleaner, easier to read and maintain. Thus, while clients can certainly use the `HEAnalytics` class directly and `trackData()` directly in client code, it's preferred to put the implementation details into a subclass of `HEAnalytics`. Since analytics are inherently app-specific, this calls for a subclass.

Thus, instead of code like:

```swift
class MyViewController: UIViewController {
    @IBAction func sliderValueDidChange(sender: AnyObject?) {
        if let slider = sender as? UISlider {
            // Do whatever you do with the slider value, like updating your data model.
            myDataObject.value = slider.value
            
            let parameters = ["value": slider.value]
            let data = HEAnalyticsData(category: .Settings, event: "Slider Value Updated", parameters: parameters)
            myHEAnalyticsInstance.trackData(data)
        }
    }
}
```

You should do:

```swift
class MyAppAnalytics: HEAnalytics {
    static let sharedInstance = MyAppAnalytics()

    func trackSliderValue(value: Float) {
        let parameters = ["value": value]
        let data = HEAnalyticsData(category: .Settings, event: "Slider Value Updated", parameters: parameters)
        self.trackData(data)
    }
}
```

Then in your code:

```swift
class MyViewController: UIViewController {
    @IBAction func sliderValueDidChange(sender: AnyObject?) {
        if let slider = sender as? UISlider {
            // Do whatever you do with the slider value, like updating your data model.
            myDataObject.value = slider.value
            
            MyAppAnalytics.sharedInstance.trackSliderValue(slider.value)
        }
    }
    
    func HE_analyticsViewTrackingTitle() -> String {
        return "My Interesting View"
    }
}
```

**See `handleUIApplicationDidFinishLaunchingNotification()` in `HEAnalytics.swift` for a more detailed illustration of the utility of this approach.

This approach:

* Keeps calling code cleaner, easier to read.
* Abstracts away the details.
* Encapsulates all analytics code and logic into a single, centralized location (which becomes a useful reference).
* Improves maintainability.

There's nothing that prevents you from the former approach, but in the author's experience the latter approach is preferrable.


## Startup and Initialization

Because `HEAnalytics` automatically tracks `UIApplicationDelegate` notifications, the best place to start analytics tracking is within `application(application, willFinishLaunchingWithOptions)`. Note! _willFinish_ **NOT** _didFinish_. Starting is simple:

```swift
func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    MyAppAnalytics.sharedInstance.start()
    return true
}
```

## Tracking

Event tracking is performed by filling out an `HEAnalyticsData` object and passing it to `HEAnalytics.trackData()`. While one can perform this "raw" at any point in code, again it is recommended to have an app-specific subclass of `HEAnalytics` that performs the heavy lifting (see above).

View tracking can be performed by invoking `HEAnalytics.trackView()`, passing the `UIViewController` you wish to track. Invoking `trackView()` can technically be done anywhere, but makes most sense to be called in your `UIViewController` subclass override of `viewDidAppear()`. To facilitate view tracking, `HEAnalytics` extends `UIViewController` with the `HE_analyticsViewTrackingTitle()` function. This function is intended to provide a stable value for analytics view tracking. By default it returns the `viewController.title` if it is non-nil and non-empty, else returns the name of the `UIViewController` (sub)class. This default behavior is acceptable, but may not always be desired. For example, if your ViewController's title is based upon the contents of the ViewController, that may make it difficult for you to track the view. To counter this, your `UIViewController` subclass can override and implement `HE_analyticsViewTrackingTitle()` and return a known stable title string that is useful for tracking and doesn't interfere with your UI.

```swift
override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    MyAppAnalytics.sharedInstance.trackView(self)
}

override func HE_analyticsViewTrackingTitle() -> String {
    return "My Cool ViewController"
}
```


## App Version

If the analytics platform supports setting the app's version, `HEAnalytics` will do so. The version will be synthesized from the `CFBundleShortVersionString` and the `CFBundleVersion` as "`CFBundleShortVersionString`.`CFBundleVersion`". The intention is the `CFBundleShortVersionString` is a public/marketing/semantic version only bumped for releases, and the `CFBundleVersion` is a forever-incrementing build number (integer) which can be bumped during development/testing/releases. Thus you may have a "2.0.1.55" then a "2.0.1.56" and finally "2.0.1.57" is actually what's released to the public, so next version becomes "3.0.0.58".

If you wish to have a different approach, you can subclass the relevant `HEAnalyticsPlatform` and override `appVersion()`.


## Opt-Out

Tracking and privacy are important to users. Many analytics platforms offer a means of opting out, and so `HEAnalytics` provides and API for this.

Some considerations:

- `HEAnalytics` considers "start/stop" and "opt-out" as related but distinct. You can still start if opted out, and depending upon the platform it may or may not result in side-effect behaviors.
- `HEAnalytics` does nothing to manage the "opt-out" state. This is something you should expose to your users somewhere in your GUI (e.g. a `UISwitch`). In doing so, you are responsible for saving and restoring the state, enforcing the state, ensuring `HEAnalytics` is in compliance with the state.


# Contact

## Hsoi Enterprises
- [Website][hsoienterprises-website]
- [Facebook][hsoienterprises-facebook]
- [Twitter (@HsoiEnterprises)][hsoienterprises-twitter]

## Creator
- John C. Daub [(@hsoi)][hsoi-twitter]


# Changes / Release Notes

See included `CHANGELOG.md` file.


# License

BSD 3-clause “New” or “Revised” License. See included "License" file.



[hsoienterprises-website]: http://www.hsoienterprises.com
[hsoienterprises-facebook]: https://www.facebook.com/HsoiEnterprises
[hsoienterprises-twitter]: http://twitter.com/hsoienterprises
[hsoi-twitter]: http://twitter.com/hsoi
