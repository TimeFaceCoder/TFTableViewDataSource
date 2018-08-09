Pod::Spec.new do |s|
  s.name         = "TFTableViewDataSource"
  s.version      = "1.0.0"
  s.summary      = "时光流影iOS TableView DataSource 框架"
  s.homepage     = "https://git.coding.net/TimeFace/TFTableViewDataSource.git"
  s.license      = "Copyright (C) 2016 TimeFace, Inc.  All rights reserved."
  s.author             = { "Melvin" => "yangmin@timeface.cn" }
  s.social_media_url   = "http://www.timeface.cn"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://git.coding.net/TimeFace/TFTableViewDataSource.git"}
  s.source_files  = "TFTableViewDataSource/**/*.{h,m,c}"
  s.requires_arc = true
end
