require "json"
package = JSON.parse(File.read('package.json'))

Pod::Spec.new do |s|
  s.name             = package['name']
  s.version          = package['version']
  s.summary          = package['description']
  s.requires_arc = true
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/svhawks/react-native-message-composer'
  s.source       = { :git => "https://github.com/svhawks/react-native-message-composer" }
  s.author       = 'Joltup'
  s.source_files = 'RNMessageComposer/**/*.{h,m}'
  s.platform     = :ios, "8.0"
  s.dependency 'React-Core'
end
