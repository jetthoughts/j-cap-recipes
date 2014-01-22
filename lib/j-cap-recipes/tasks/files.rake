namespace :files do
  desc 'Downlaod remote shared files to local machine.'
  task :download, :path do |task, args|

    if args[:path].nil?
      puts "You should provide the file path.\nExample: `cap #{fetch(:stage)} \"files:download[config/database.yml]\"`"
      puts "If you want to download share folder use next: `cap #{fetch(:stage)} \"files:download[.]\"`"
      exit
    end

    on primary fetch(:migration_role) do
      info "Started downloading remote file '#{args[:path]}'"
      within shared_path do
        archive_path = '/tmp/download.tar'
        info "Archive to #{archive_path}"
        execute :tar,  '-cvf', archive_path, args[:path]
        info 'Downloading...'
        download! archive_path, '.', recursive: true, verbose: true
        info "Remove archive file #{archive_path}"
        execute :rm, archive_path
      end
    end
  end
end
