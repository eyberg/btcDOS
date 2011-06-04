require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-aggregates'
require 'dm-migrations'

$KCODE = 'UTF8' unless RUBY_VERSION >= '1.9'

require 'db-config.rb'

Dir.glob('models/**/*.rb').each do |f|
  require f
end

desc 'wipe and seed db'
task :auto_migrate do
  DataMapper.auto_migrate!
end

desc 'auto_upgrade the database'
task :auto_upgrade do
  DataMapper.auto_upgrade!
end
