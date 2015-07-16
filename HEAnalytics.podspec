Pod::Spec.new do |spec|
  spec.name          = 'HEAnalytics'
  spec.version       = '0.5'
  spec.source        = { :git => 'https://github.com/HsoiEnterprises/HEAnalytics.git', :tag => "v#{spec.version}" }
  spec.summary       = 'A simple Swift-based framework for iOS app analytics across analytics platforms.'
  spec.author        = { 'John C. Daub (@hsoi)' => 'hsoi@hsoienterprises.com' }
  spec.description   = 'A simple Swift-based framework for iOS app analytics across analytics platforms.'
  spec.requires_arc  = true
  spec.license       = { :type => 'BSD 3-clause “New” or “Revised”', :file => 'LICENSE' }
  spec.source_files  = ['HEAnalytics/*.swift', 'HEAnalytics/*.h']

  spec.subspec 'Flurry' do |flurry|
    flurry.source_files = 'HEAnalytics/HEAnalyticsPlatformFlurry.swift'
    flurry.dependency 'FlurrySDK'
  end

  spec.subspec 'GoogleAnalytics' do |gai|
    gai.source_files = 'HEAnalytics/HEAnalyticsPlatformGAI.swift'
    gai.dependency 'GoogleAnalytics'
  end

  spec.subspec 'Mixpanel' do |mixpanel|
    mixpanel.source_files = 'HEAnalytics/HEAnalyticsPlatformMixpanel.swift'
    mixpanel.dependency 'Mixpanel'
  end

  spec.subspec 'Intercom' do |intercom|
    intercom.source_files = 'HEAnalytics/HEAnalyticsPlatformIntercom.swift'
    intercom.dependency 'Intercom'
  end

end