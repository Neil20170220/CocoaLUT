Pod::Spec.new do |s|
  s.name         = "FRCocoaLUT"
  s.version      = '0.2.29'
  s.summary      = "LUTs (1D and 3D color lookup tables) for Cocoa applications."
  s.homepage     = "https://github.com/Neil20170223/CocoaLUT"
  s.license      = 'MIT'
  s.author       = { "Wil Gieseler" => "wil@wilgieseler.com", "Greg Cotten" => "greg@gregcotten.com"}
  s.source       = { :git => "https://github.com/Neil20170223/CocoaLUT.git", :tag => s.version }

  s.resource_bundle = {'TransferFunctionLUTs' => 'Assets/TransferFunctionLUTs/*.cube',
                       'ManufacturerLUTs' => 'Assets/ManufacturerLUTs/*.cube'}

  s.requires_arc = true
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.frameworks = ['QuartzCore']

  s.dependency 'RegExCategories'
  s.dependency 'M13OrderedDictionary'
  s.dependency 'XMLDictionary'
  s.dependency 'MustOverride'

  # iOS
  s.ios.frameworks = 'UIKit'
  s.ios.exclude_files = 'Classes/osx'
  s.ios.deployment_target = '7.0'

  # OS X
  s.osx.frameworks = 'AppKit'
  s.osx.exclude_files = 'Classes/ios'
  s.osx.deployment_target = '10.7'

end
