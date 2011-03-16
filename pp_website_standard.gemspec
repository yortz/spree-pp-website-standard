Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'pp_website_standard'
  s.version     = '0.8.1'
  s.summary     = 'Spree extension for integration with PayPal Website Standard payment'
  #s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Gregg Pollack, Sean Schofield, Tomasz Stachewicz'
  # s.email             = 'david@loudthinking.com'
  s.homepage          = 'http://github.com/tomash/spree-pp-website-standard'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.30.0')
end
