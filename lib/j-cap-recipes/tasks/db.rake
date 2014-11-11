namespace :db do
  desc 'PG backup'
  task backup: [:environment, :load_config] do
    #stamp the filename
    datestamp  = Time.now.strftime('%Y-%m-%d_%H-%M-%S')

    #create backups folder
    backup_dir = ENV['backup-path'] || Rails.root.join('db', 'backups')
    mkdir_p(backup_dir)

    config        = ActiveRecord::Base.connection_config
    database_name = ActiveRecord::Base.connection.current_database
    backup_file   = File.join(backup_dir, "#{database_name}_#{datestamp}.dump")

    #dump the backup and zip it up
    dump_command  = "#{postgres_password(config)} pg_dump #{database_name} -w -F c"
    dump_command += postgres_auth_options(config)
    dump_command += " > #{backup_file}"

    sh dump_command

    safe_ln backup_file, File.join(backup_dir, "#{database_name}_latest.dump")
  end

  desc 'PG restore from the last backup file'
  task restore: [:environment, :load_config] do
    config        = ActiveRecord::Base.connection_config
    database_name = ActiveRecord::Base.connection.current_database
    backup_dir    = ENV['backup-path'] || Rails.root.join('db', 'backups')
    backup_file   = File.join(backup_dir, "#{database_name}_latest.dump")

    Rake::Task['db:kill_postgres_connections'].invoke
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke

    restore_command = "#{postgres_password(config)} pg_restore -d #{database_name} -F c -w #{backup_file}"
    restore_command += postgres_auth_options(config)
    restore_command += ' -O -c'
    sh "#{restore_command} || echo 'done'"
  end

  task :kill_postgres_connections => :environment do
    db_name = ActiveRecord::Base.connection.current_database
    pid_column_name = if ActiveRecord::Base.connection.send(:postgresql_version) > 90200
      'pid'
    else
      'procpid'
    end

    kill_query = <<-QUERY
      SELECT pg_terminate_backend(#{pid_column_name})
      FROM pg_stat_activity
      WHERE datname = '#{db_name}';
    QUERY

    begin
      ActiveRecord::Base.connection.exec_query(kill_query)
    rescue ActiveRecord::StatementInvalid => ex
      puts "All connections to #{db_name} were killed successfully!"
      puts "Database message: #{ex.message}"
    end
  end

end

def postgres_password(config)
  "PGPASSWORD='#{config[:password]}'" if config[:password].present?
end

def postgres_auth_options(config)
  command_options = ''
  command_options += " -h #{config[:hostname]}" if config[:hostname].present?
  command_options += " -U #{config[:username]}" if config[:username].present?
  command_options
end

#TODO: Use setting to get S3 credentials
def send_to_amazon(file_path)
  bucket    = "db-backups"
  file_name = File.basename(file_path)
  AWS::S3::Base.establish_connection!(:access_key_id => 'YOUR KEY', :secret_access_key => 'YOUR SECRET')
  #push the file up
  AWS::S3::S3Object.store(file_name, File.open(file_path), bucket)
end
