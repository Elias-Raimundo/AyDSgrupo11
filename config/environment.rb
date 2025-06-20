require 'active_record'
require 'yaml'
require 'psych'

db_config = Psych.load(File.read('config/database.yml'), aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])

Dir[File.join(__dir__, '../models', '*.rb')].each { |file| require file }

