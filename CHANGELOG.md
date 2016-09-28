# HEAnalytics CHANGELOG


## v1.0.0 - 2016-09-24

* Conversion to Swift 3 (and Xcode 8). `:props:` to @kreeger for the massive contribution!


## v0.6.1 - 2016-09-24

* Fixed a Localytics tracking bug

Last version to support Swift 2.2


## v0.6 - 2016-03-26

* Xcode 7.3 and Swift 2.2 support.
* Tracking "started" state. Thanx to @kreeger
* Added `HEAnalyticsUser` to track user information. Thanx to @kreeger
* Added Localytics support. Thanx (again) to @kreeger
* Simpilfied `HEAnalyticsPlatform.viewControllerTitle()` because Swift 2.2. We shouldn't NEED that logic anyways (right?)


## v0.5.2 - 2015-09-12

Minor adjustments from the Xcode 7 GM


## v0.5.1 - 2015-09-06

Originally this release was going to bring Cocoapods support, but due to HEAnalytics being written in Swift, Cocoapods requiring Swift-based pods to be in frameworks, that all the analytics SDKs are distributed as static libraries, and that the way Cocoapods works regarding dynamic frameworks and static libraries having issues... well, it won't happen. But changes made were primarily towards that end.

### Added

* This CHANGELOG

### Changed

* Cleaned up access levels.
* Updated example project.
* Improved README.


## v0.5 - 2015-07-16

### Added

* Intercom support


## v0.4 - 2015-05-26

### Added

* Added better custom app versioning support.


## v0.3 - 2015-05-08


### Added

* Sample project

### Changed

* Requires Swift 1.2


## v0.2 - 2015-04-23

### Added

* Mixpanel support


## v0.1 - 2015-04-19

Initial release.
