namespace :db do
  desc 'PG backup'
  task backup: [:environment, :load_config] do
    #stamp the filename
    dateformat = ENV['date-format'] || '%Y-%m-%d_%H-%M-%S'
    datestamp  = Time.now.strftime(dateformat)

    #create backups folder
    mkdir_p(backup_dir)

    config        = ActiveRecord::Base.connection_config
    database_name = ActiveRecord::Base.connection.current_database
    backup_file   = File.join(backup_dir, "#{database_name}_#{datestamp}.dump")

    #dump the backup and zip it up
    sh dump_command(config, database_name, backup_file)

    latest_file_name = File.join(backup_dir, "#{database_name}_latest.dump")
    if File.exist? latest_file_name
      rm latest_file_name
    end
    safe_ln backup_file, latest_file_name
  end

  desc 'PG restore from the last backup file'
  task restore: ['db:create', :environment, :load_config] do
    config        = ActiveRecord::Base.connection_config
    database_name = ActiveRecord::Base.connection.current_database
    backup_dir    = ENV['backup-path'] || Rails.root.join('db', 'backups')
    backup_file   = File.join(backup_dir, "#{database_name}_latest.dump")

    execute_task!('db:kill_postgres_connections')
    execute_task!('db:drop')
    execute_task!('db:create')

    command = db_restore_command(config, database_name, backup_file)
    sh "#{command} || echo 'done'"
  end

  task :kill_postgres_connections => :environment do
    config = ActiveRecord::Base.connection_config
    next if config[:adapter] != "postgresql"
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

  desc 'Clean up old dumps'
  task :cleanup do
    dumps = FileList.new(File.join(backup_dir, '*.dump')).exclude(/_latest.dump$/)

    if keep_versions > 0 && dumps.count >= keep_versions
      puts "Keep #{keep_versions} dumps"
      files = (dumps - dumps.last(keep_versions))
      if files.any?
        files.each do |f|
          rm_r f
        end
      end
    end

  end

  def backup_dir
    @_backup_dir ||= ENV['backup-path'] || Rails.root.join('db', 'backups')
  end

  def keep_versions
    @_keep_versions ||= ENV['ROTATE'].to_i
  end

  def postgres_dump_command(config, database_name, backup_file)
    result  = "#{postgres_password(config)} pg_dump #{database_name} -w -F c"
    result += postgres_auth_options(config)
    result + " > #{backup_file}"
  end

  def mysql_dump_command(config, database_name, backup_file)
    result  = "mysqldump #{database_name} "
    result += mysql_auth_options(config)
    result + " > #{backup_file}"
  end

  def dump_command(config, database_name, backup_file)
    case config[:adapter]
    when /mysql/
      mysql_dump_command(config, database_name, backup_file)
    when 'postgresql', 'pg'
      postgres_dump_command(config, database_name, backup_file)
    end
  end

  def db_restore_command(config, database_name, backup_file)
    case config[:adapter]
    when /mysql/
      mysql_restore_command(config, database_name, backup_file)
    when 'postgresql', 'pg'
      postgres_restore_command(config, database_name, backup_file)
    end
  end

  def postgres_restore_command(config, database_name, backup_file)
    result = "#{postgres_password(config)} pg_restore -d #{database_name} -F c -w #{backup_file}"
    result += postgres_auth_options(config)
    result + ' -O -c'
  end

  def mysql_restore_command(config, database_name, backup_file)
    "mysql #{database_name} #{mysql_auth_options(config)} < #{backup_file}"
  end

  def postgres_password(config)
    "PGPASSWORD='#{config[:password]}'" if config[:password].present?
  end

  def postgres_auth_options(config)
    command_options = ''
    command_options += " -h #{config[:host]}" if config[:host].present?
    command_options += " -U #{config[:username]}" if config[:username].present?
    command_options
  end

  def mysql_auth_options(config)
    command_options = ''
    command_options += "--password='#{config[:password]}'" if config[:password].present?
    command_options += " -h #{config[:host]}" if config[:host].present?
    command_options += " -u #{config[:username]}" if config[:username].present?
    command_options
  end

end

#TODO: Use setting to get S3 credentials
def send_to_amazon(file_path)
  bucket    = "db-backups"
  file_name = File.basename(file_path)
  AWS::S3::Base.establish_connection!(:access_key_id => 'YOUR KEY', :secret_access_key => 'YOUR SECRET')
  #push the file up
  AWS::S3::S3Object.store(file_name, File.open(file_path), bucket)
end

def execute_task!(task_name)
  Rake::Task[task_name].reenable
  Rake::Task[task_name].invoke
end
