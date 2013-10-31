namespace :hpusher do
  desc 'Upload config/hpusher.yml to remote server'
  task :update => 'config/hpusher.yml'
end

remote_file 'config/hpusher.yml' => File.join(Dir.pwd, 'config', 'hpusher.yml')
