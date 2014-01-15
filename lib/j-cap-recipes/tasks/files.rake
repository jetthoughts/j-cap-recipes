namespace :files do
  desc 'Downlaod remote shared files to local machine.'
  task :download, :path do |task, args|
    on primary fetch(:migration_role) do
      within shared_path do
        download! "#{shared_path}/#{args[:path]}", '.', recursive: true, verbose: true
      end
    end
  end
end
