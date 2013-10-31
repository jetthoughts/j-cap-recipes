namespace :nginx do
  desc 'Restart nginx'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo', '/etc/init.d/nginx restart'
    end
  end

  desc 'Stop nginx'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo', '/etc/init.d/nginx stop'
    end
  end

  desc 'Start nginx'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo', '/etc/init.d/nginx start'
    end
  end

end
