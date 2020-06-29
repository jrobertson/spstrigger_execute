Gem::Specification.new do |s|
  s.name = 'spstrigger_execute'
  s.version = '0.5.1'
  s.summary = 'An SPS client built for reponding to messages which match ' + 
      'keywords and conditions.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/spstrigger_execute.rb']
  s.add_runtime_dependency('dynarex', '~> 1.8', '>=1.8.25')
  s.add_runtime_dependency('chronic_between', '~> 0.3', '>=0.3.1')
  s.add_runtime_dependency('xmlregistry_objects', '~> 0.7', '>=0.7.5')
  s.signing_key = '../privatekeys/spstrigger_execute.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/spstrigger_execute'
end
