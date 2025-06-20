require 'yaml'
require 'active_record'
require_relative '../server'

ENV['RACK_ENV'] ||= 'test'

db_config = YAML.load_file(File.expand_path('../../config/database.yml', __FILE__), aliases: true)
ActiveRecord::Base.establish_connection(db_config[ENV['RACK_ENV']])

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # 🧹 Limpieza segura antes de cada test respetando dependencias
  config.before(:each) do
    # Ordenar según dependencia (de hijos a padres)
    models = [
      SavingTransaction,
      Withdrawal,
      Income,
      Saving,
      Transaction,
      Account,
      User,
      Person
    ]

    models.each do |model|
      begin
        model.delete_all
      rescue ActiveRecord::InvalidForeignKey => e
        puts "Error al borrar datos de #{model.name}: #{e.message}"
      end
    end
  end
end
