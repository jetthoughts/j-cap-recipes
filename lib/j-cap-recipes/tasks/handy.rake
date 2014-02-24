namespace :config do

  task settings: 'settings:show'

  namespace :settings do
    desc 'Update the remote config/settings/<stage>.yml file with local'
    task upload: :delete do
      invoke "config/settings/#{fetch(:stage)}.yml"
    end

    desc 'Delete remote config/settings/<stage>.yml file'
    task :delete do
      on roles(:all) do |host|
        within shared_path do
          execute :rm, '-f', "config/settings/#{fetch(:stage)}.yml"
        end
      end
    end

    desc 'Show current settings'
    task :show do
      on roles(:all) do |host|
        within current_path.join('config') do
          execute :cat, 'settings.yml'
          execute :cat, "settings/#{fetch(:stage)}.yml"
        end
      end
    end

    desc 'Show current settings'
    task :get do
      on roles(:all) do |host|
        local_dir = File.join(Dir.pwd, 'config', 'settings')
        FileUtils.mkdir_p local_dir
        download! current_path.join('config', 'settings', "#{fetch(:stage)}.yml"), local_dir
      end
    end
  end

end

stages.each do |stage|
  remote_file "config/settings/#{stage}.yml" => File.join(Dir.pwd, 'config', 'settings', "#{stage}.yml")
end
