Gem::Specification.new do |s|
  s.name = 'spstrigger_execute'
  s.version = '0.5.2'
  s.summary = 'An SPS client built for reponding to messages which match ' + 
      'keywords and conditions.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/spstrigger_execute.rb']
  s.add_runtime_dependency('dynarex', '~> 1.9', '>=1.9.6')
  s.add_runtime_dependency('chronic_between', '~> 0.5', '>=0.5.0')
  s.add_runtime_dependency('xmlregistry_objects', '~> 0.8', '>=0.8.0')
  s.signing_key = '../privatekeys/spstrigger_execute.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/spstrigger_execute'
end
