namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, current_path.join('tmp/restart.txt')
    end
  end

  desc 'Store the deploy date and version to project file'
  task :update_version do
    on release_roles(:all) do
      within release_path do
        build_number = fetch(:build_number, [fetch(:current_revision), release_timestamp].compact.join('-'))
        version_file_name = fetch(:version_filename, 'VERSION')
        execute %{sed -i.bak 's/$/@#{build_number}/' #{release_path.join(version_file_name)}}
      end
    end
  end
end
