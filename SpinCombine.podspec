Pod::Spec.new do |s|
  s.name = "SpinCombine"
  s.version = "0.18.0"
  s.swift_version = "5.2.2"
  s.summary = "Spin is a tool whose only purpose is to help you build feedback loops called Spins"
  s.description = <<-DESC
Spin is a tool to build feedback loops within a Swift based application allowing you to use a unified syntax whatever the underlying reactive programming framework and whatever Apple UI technology you use (RxSwift, ReactiveSwift, Combine and UIKit, AppKit, SwiftUI).
                        DESC
  s.homepage = "https://github.com/Spinners/Spin.Swift"
  s.screenshots = "https://raw.githubusercontent.com/Spinners/Spin.Swift/master/Resources/spin-logo.png"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Thibault Wittemberg" => "thibault.wittemberg@gmail.com" }
  s.source           = { :git => "https://github.com/Spinners/Spin.Swift.git", :tag => s.version.to_s }
  s.social_media_url = "http://twitter.com/thwittem"
  
  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"
  s.watchos.deployment_target = "6.0"
  s.tvos.deployment_target = "13.0"

  s.requires_arc = true

  s.source_files = 'Sources/Combine/*.swift'

  s.dependency 'SpinCommon', '>= 0.18.0'

end
