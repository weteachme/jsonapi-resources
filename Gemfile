source 'https://rubygems.org'

gemspec

platforms :ruby do
  gem 'sqlite3'
  gem 'simplecov', group: :test
end

version = ENV['RAILS_VERSION'] || 'default'

case version
when 'master'
  gem 'railties', { git: 'https://github.com/rails/rails.git' }
  gem 'arel', { git: 'https://github.com/rails/arel.git' }
when 'default'
  gem 'railties', '>= 5.0'
else
  gem 'railties', "~> #{version}"
end
