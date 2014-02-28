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
    dump_command  = "pg_dump #{database_name} -w -F c"
    dump_command  += " -h #{config[:hostname]}" if config[:hostname].present?
    dump_command  += " -U #{config[:username]}" if config[:username].present?
    dump_command  += " > #{backup_file}"

    sh dump_command

    safe_ln backup_file, File.join(backup_dir, "#{database_name}_latest.dump")

    #send_to_amazon backup_file
    #remove the file on completion so we don't clog up our app
    #File.delete backup_file
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

    restore_command = "pg_restore -d #{database_name} -F c -w #{backup_file}"
    restore_command = postgres_command_options restore_command, config
    sh "#{restore_command} || echo 'done'"
  end

  task :kill_postgres_connections => :environment do
    database_name = ActiveRecord::Base.connection.current_database
    command = <<EOF
ps xa \
  | grep postgres: \
  | grep #{database_name} \
  | grep -v grep \
  | awk '{print $1}' \
  | xargs kill || true
EOF
    sh command
  end

end

def postgres_command_options(str, config)
  str += " -h #{config[:hostname]}" if config[:hostname].present?
  str += " -U #{config[:username]}" if config[:username].present?
  str
end

#TODO: Use setting to get S3 credentials
def send_to_amazon(file_path)
  bucket    = "db-backups"
  file_name = File.basename(file_path)
  AWS::S3::Base.establish_connection!(:access_key_id => 'YOUR KEY', :secret_access_key => 'YOUR SECRET')
  #push the file up
  AWS::S3::S3Object.store(file_name, File.open(file_path), bucket)
end
