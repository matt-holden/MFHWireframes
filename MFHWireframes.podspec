#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "MFHWireframes"
  s.version          = "0.1.0"
  s.summary          = "MFHWireframes is exciting!"

=begin
  s.description      = <<-DESC
                       An optional longer description of MFHWireframes

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
=end

  s.homepage         = "github.com/matt-holden/MFHWireframes"
  s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Matthew Holden" => "jftholden@yahoo.com" }
  s.source           = { :git => "http://EXAMPLE/NAME.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MFHolden'

  # s.platform     = :ios, '5.0'
  s.ios.deployment_target = '7.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'Classes/*.m'
  #s.resources = 'Assets/*.png'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/MFHWireframe.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end