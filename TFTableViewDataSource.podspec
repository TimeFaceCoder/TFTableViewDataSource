#
# Be sure to run `pod lib lint TFTableViewDataSource.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TFTableViewDataSource'
  s.version          = '1.0.0'
  s.summary          = '不适合小型项目的列表数据管理工具'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/TimeFaceCoder/TFTableViewDataSource'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'melvin7' => 'yangmin@timeface.cn' }
  s.source           = { :git => 'https://github.com/TimeFaceCoder/TFTableViewDataSource.git', :tag => s.version.to_s }


  s.ios.deployment_target = '9.0'

  s.source_files = 'TFTableViewDataSource/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TFTableViewDataSource' => ['TFTableViewDataSource/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'TFNetwork'
  s.dependency 'TFTableViewManager'

end
