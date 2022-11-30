Pod::Spec.new do |s|
  s.name         = 'CleanroomLogger'
  s.version      = '7.0.1'
  s.summary      = 'Extensible Swift-based logging API that is simple, lightweight and performant'
  s.homepage     = 'https://github.com/emaloney/CleanroomLogger'
  s.author       = 'emaloney'
  s.source       = { :git => 'https://github.com/emaloney/CleanroomLogger.git', :tag => s.version }
  s.ios.deployment_target 		= "9.0"
  s.watchos.deployment_target 	= "4.0"
  s.tvos.deployment_target 		= "12.0"
  s.osx.deployment_target 		= "10.10"
  s.source_files = 'Sources/*.swift'
  s.license = 'MIT'

  s.swift_version = '5.0'
end