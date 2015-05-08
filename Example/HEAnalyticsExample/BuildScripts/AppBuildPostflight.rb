#!/usr/bin/ruby

# AppBuildPostflight.rb

require 'pathname'
require 'fileutils'
require 'rubygems'
require 'cfpropertylist'  # gem is actually named "CFPropertyList"


built_app_path = Pathname.new(ENV['CONFIGURATION_BUILD_DIR'] + "/" + ENV['EXECUTABLE_NAME'] + ENV['WRAPPER_SUFFIX'])

### Copy in the AnalyticsPlatformConfig file.

analyticsplatformconfig_folder_path = Pathname.new(ENV['SRCROOT'] + "/HEAnalyticsExample/AnalyticsPlatformConfig/" + ENV['CONFIGURATION'])
configplist_file_path = Pathname.new(analyticsplatformconfig_folder_path + "AnalyticsPlatformConfig.plist")
FileUtils.cp_r File.expand_path(configplist_file_path), built_app_path


### Massage the Info.plist.
# We do this here because the Info.plist that's actually in the project file isn't directly used by Xcode, but
# rather Xcode uses it as the basis for the end Info.plist, but also inserts a bunch of other things
# in there during the build process. What we need to do is come in after the fact an modify the generated
# Info.plist. 

# Get the git version hash that we're building from, so we can insert it into the Info.plist.
gitver = `git rev-parse --short HEAD`.strip 

info_plist_file_path = Pathname.new(built_app_path + "Info.plist")
info_plist = CFPropertyList::List.new(:file => info_plist_file_path)

#plist_additions_file_path = Pathname.new(ENV['SRCROOT'] + "/BuildResources/Common/InfoPlistAdditions.plist")
#plist_additions = CFPropertyList::List.new(:file => plist_additions_file_path.to_s)
#plist_additions_native =  CFPropertyList.native_types(plist_additions.value)

#plist_additions_native.each do | key, value |
#  info_plist.value.value[key] = CFPropertyList.guess(value)
#end

info_plist.value.value['HESourceVersion'] = CFPropertyList::CFString.new(gitver)

info_plist.save(info_plist_file_path, CFPropertyList::List::FORMAT_BINARY)
