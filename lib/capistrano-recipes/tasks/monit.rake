namespace :monit do
  desc 'Restart monit'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo', '/etc/init.d/monit restart'
    end
  end

  desc 'Stop monit'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo', '/etc/init.d/monit stop'
    end
  end

  desc 'Start monit'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo', '/etc/init.d/monit start'
    end
  end

  desc 'Exec monit command'
  task :exec, :command do |task, args|
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo', 'monit', args[:command]
    end
  end
end
