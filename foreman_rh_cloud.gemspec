require File.expand_path('lib/foreman_rh_cloud/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'foreman_rh_cloud'
  s.version     = ForemanRhCloud::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['Foreman Red Hat Cloud team']
  s.email       = ['rlavi@redhat.com, sshtein@redhat.com']
  s.homepage    = 'https://github.com/theforeman/foreman_rh_cloud'
  s.summary     = 'Summary of ForemanRhCloud.'
  # also update locale/gemspec.rb
  s.description = 'Foreman plugin that process & upload data to Red Hat Cloud'

  s.files = Dir['{app,config,db,lib,locale,webpack}/**/*'] +
            ['LICENSE', 'Rakefile', 'README.md'] +
            ['package.json']
  s.files -= Dir['**/*.orig']
  s.test_files = Dir['test/**/*']
  s.test_files -= Dir['test/**/*.orig']

  s.required_ruby_version = '>= 2.7', '< 4'

  s.add_dependency 'foreman_ansible', '< 15'
  s.add_dependency 'foreman-tasks', '< 10'
  s.add_runtime_dependency 'katello', '>= 4.14.0.rc1.1', '< 4.15'

  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'theforeman-rubocop', '~> 0.1.0'
end
