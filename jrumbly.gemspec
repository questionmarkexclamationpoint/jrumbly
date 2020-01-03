lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'jrumbly'
  spec.version       = '0.0.1'
  spec.authors       = ['T. Commons']
  spec.email         = ['tcc5m@uvawise.edu']
  spec.summary       = 'An IDE for a simple assembly language written in jruby'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('lib/**/*')
  spec.executables   = []
  spec.test_files    = []
  spec.require_paths = ['lib']
end
