# HEAnalytics
A simple Swift-based framework for iOS app analytics across analytics platforms.


# Background and Approach

Apps want analytics, and analytics are inherently app-specific. However, much of the logic for making analytics go is the same across apps, and one bit of complexity to manage is the inevitable desire to track analytics across multiple analytics platforms (Flurry, Google Analytics, Mixpanel, etc.). Having been a part of enough apps/projects that needed such things, and having dealt with some headaches of other approaches, this is something I came up with to try to manage those issues. It's just one way to approach this problem.

## Flexible Platform Choice

Some apps want to use platform X, some way to use Y, some way to use both X and Y. Inevitably those platforms do things different, so the complexity of contending with their API differences should be something the app developer shouldn't have to worry about. Let that all happen within the analytics framework.

As well, try to be as robust as possible in utilizing that platform's API and features, but bridging functionality where required. For example, Flurry has a nice way of tracking event parameters but Google Analytics does not, so `HEAnalytics` does the best it can to provide the event parameters in a useful manner under GAI. On the other side, GAI has a nice way of tracking screen views while Flurry essentially requires you to treat it as another event; `HEAnalytcs` at least tries to make this event easily discernable from the other events.

Need to support a new platform? Subclass `HEAnalyticsPlatform` and `addPlatform()`.

## Configuration Options

Platform configuration comes by way of a `AnalyticsPlatformConfig.plist` file within the main app bundle. This allows for greater flexibility in build and runtime configuration. For example, a white-label product could create a `AnalyticsPlatformConfig.plist` per product and your build system brings in the proper .plist file at build time. Or perhaps based upon build configuration (Debug vs. Release) you may choose a different configuration (e.g. you have a dev analytics account so your daily dev work doesn't skew your true analytics data).

## Uniformity

Events generally are identified as a string. However this can be a hassle and introduce errors if one isn't careful. The power of Swift enums, including the ability to have extensions to enums, helps minimize the potential for such errors.

## Centralization and Abstraction

Often analytics are approached by directly accessing the API at the point in the app code where the analytic needs to be logged; the API is either directly calling an analytics platform API or calling some other wrapper. While reasonable, I found over time this approach did not scale nor maintain well. Instead, I prefer to wrap up all the gory details of analytics into the analytics wrapper class (`HEAnalytics` or a subclass) so that the client code merely calls one function passing whatever information is relevant to log.

This allows all analytics details to be centralized in one file. This can make tracking and modification easier as the project carries on.

It enables logic for converting the data-to-track into something the analytics APIs can understand to be performed somewhere else so as to keep the client code cleaner and easier to read. As well, many times while a particular analytic event may be unique in its use in the app, many times the parameters to track are similar across events. By encapsulating such logic into a single location, code reuse can be facilitated so you can write the "parameter conversion" code once and multiple event trackers can easily reuse.

# License

BSD 3-clause “New” or “Revised” License. See included "License" file.
