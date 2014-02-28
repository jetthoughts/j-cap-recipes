require 'securerandom'

namespace :deploy do
  namespace :check do
    task :linked_files => 'config/database.yml'
  end
end

namespace :db do
  desc 'Created the DB'
  task :create do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:create'
        end
      end
    end
  end

  desc 'Create backup of the DB'
  task :backup do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:backup'
        end
      end
    end
  end

  desc 'Restore the latest dump of the DB'
  task :restore do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:restore'
        end
      end
    end
  end

  desc 'Downlaod to local machine the latest backup'
  task :dump_download do
    on primary fetch(:migration_role) do
      within release_path do
        FileUtils.mkdir_p 'db/backups'
        bakup_file = "db/backups/#{fetch(:application)}_#{fetch(:rails_env).to_s}_latest.dump"
        download! "#{release_path}/#{bakup_file}", bakup_file
      end
    end
  end

  desc 'Downlaod to local machine the latest backup'
  task :dump_upload do
    on primary fetch(:migration_role) do
      within release_path do
        FileUtils.mkdir_p 'db/backups'
        bakup_file = "db/backups/#{fetch(:application)}_#{fetch(:rails_env).to_s}_latest.dump"
        upload! bakup_file, "#{release_path}/#{bakup_file}"
      end
    end
  end


end

remote_file 'config/database.yml' => '/tmp/database.yml', roles: :app
after 'config/database.yml', :remove_db_tmp_file do
  File.delete '/tmp/database.yml'
end

file '/tmp/database.yml' do |t|
  default_template = <<-EOF
      base: &base
        adapter: sqlite3
        timeout: 5000
      development:
        database: #{shared_path}/db/development.sqlite3
        <<: *base
      test:
        database: #{shared_path}/db/test.sqlite3
        <<: *base
      production:
        database: #{shared_path}/db/production.sqlite3
        <<: *base
  EOF

  location = fetch(:template_dir,  File.join(File.dirname(__FILE__), 'templates', 'database.yml.erb'))
  template = File.file?(location) ? File.read(location) : default_template

  config = ERB.new(template)
  File.open t.name, 'w' do |f|
    f.puts config.result(binding)
  end
end
