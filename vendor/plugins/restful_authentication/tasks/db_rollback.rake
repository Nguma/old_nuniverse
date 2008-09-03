namespace :db do
  namespace :migrate do
    desc "Rollback the database schema to the previous version"
    task :rollback => :environment do
      previous_version = ActiveRecord::Migrator.current_version.to_i - 1
      ActiveRecord::Migrator.migrate("db/migrate/", previous_version)
      puts "Schema rolled back to previous verison (#{previous_version})."
    end
  end
end