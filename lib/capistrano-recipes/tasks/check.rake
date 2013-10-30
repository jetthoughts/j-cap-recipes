namespace :deploy do

  namespace :check do

    # Check the nodejs runtime
    task :nodejs do
      on roles(:all) do |host|
        # centos responds to node
        if test("[ $(which nodejs || which node ) ]")
          info "Javascript runtime nodejs is available on #{host}"
        else
          error "Javascript runtime nodejs is not available on #{host}"
        end
      end
    end
    after 'deploy:check', 'deploy:check:nodejs'

    task :imagemagick do
      on roles(:all) do |host|
        if test("[ $(which identify) ]")
          info "Javascript runtime nodejs is available on #{host}"
        else
          error "Javascript runtime nodejs is not available on #{host}"
        end
      end
    end
    after 'deploy:check', 'deploy:check:imagemagick'

  end

end
