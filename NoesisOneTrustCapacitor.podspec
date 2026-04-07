require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'NoesisOneTrustCapacitor'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = package['repository']['url']
  s.author = package['author']
  s.source = { :git => package['repository']['url'], :tag => s.version.to_s }
  s.source_files = 'ios/Sources/**/*.{swift,h,m,c,cc,mm,cpp}'

  s.ios.deployment_target = '15.0'
  s.dependency 'Capacitor'

  # OneTrust CMP native SDK — mirrors the Cordova plugin's plugin.xml dep:
  #   <pod name="OneTrust-CMP-XCFramework" spec="~> 202303.2.0.0" />
  # Pinned to the same version family the Cordova plugin shipped with so the
  # observable behavior matches.
  s.dependency 'OneTrust-CMP-XCFramework', '~> 202303.2.0.0'

  s.swift_version = '5.1'
end
