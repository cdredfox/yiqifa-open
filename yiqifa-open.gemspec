Gem::Specification.new do |s|
  s.name        = "yiqifa-open"
  s.version     = "1.0.0"
  s.author      = "Fei Yang"
  s.email       = "cdredfox@gmail.com"
  s.homepage    = "https://github.com/cdredfox/yiqifa-open"
  s.summary     = "Yiqifa openplatm api."
  s.description = "Yiqifa openplatm api."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]
  s.rubyforge_project = s.name
end