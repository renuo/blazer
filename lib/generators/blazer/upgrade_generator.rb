require "rails/generators/active_record"

module Blazer
  module Generators
    class UpgradeGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration
      source_root File.join(__dir__, "templates")

      def copy_migrations
        migration_templates.each do |template|
          migration_name = File.basename(template, ".rb.tt")
          next if migration_exists?(migration_name)

          migration_template(
            "migrations/#{File.basename(template)}",
            "db/migrate/#{migration_name}.rb",
            migration_version: migration_version
          )
        end
      end

      private

      def migration_templates
        Dir[File.join(self.class.source_root, "migrations", "*.rb.tt")].sort
      end

      def migration_exists?(name)
        Dir[Rails.root.join("db/migrate/*_#{name}.rb"), Rails.root.join("db/migrate/#{name}.rb")].any?
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
