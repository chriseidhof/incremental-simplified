Pod::Spec.new do |s|
  s.name         = "Incremental"
  s.version      = "0.0.1"
  s.summary      = "This is an implementation of incremental programming."
  s.description  = "This is an implementation of incremental programming. It's based on the ideas in incremental, which are on turn based on the ideas of self-adjusting computation."

  s.homepage     = "https://github.com/chriseidhof/incremental-simplified"

  s.license      = { :type => "MIT", :file => "LICENSE.txt" }

  s.authors            = { "chriseidhof" => "mail@objc.io" }
  s.social_media_url   = "https://twitter.com/chriseidhof"

  s.swift_version = "4.1"

  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/chriseidhof/incremental-simplified.git", :tag => s.version }
  
  s.source_files  = ["Incremental/*.swift"]
  s.requires_arc = true
end
