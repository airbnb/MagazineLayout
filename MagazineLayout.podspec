Pod::Spec.new do |s|
  s.name     = 'MagazineLayout'
  s.version  = '1.0.0'
  s.license  = 'Apache License, Version 2.0'
  s.summary  = 'A collection view layout that can display items in a grid and list arrangement.'
  s.homepage = 'https://github.com/airbnb/MagazineLayout'
  s.authors  = 'Airbnb'
  s.source   = { :git => 'https://github.com/airbnb/MagazineLayout.git', :tag => "v#{ s.version.to_s }" }
  s.swift_version = '4.0'
  s.source_files = 'MagazineLayout/**/*.{swift,h}'
  s.ios.deployment_target = '10.0'
end
