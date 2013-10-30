namespace :log do
  desc 'Tail current log file from the remote'
  task :tail, :filepattern do |t, args|
    filepattern = args[:filepattern] || fetch(:stage)
    on roles(:all) do |host|
      within "#{shared_path}/log" do
        execute :tail, '-f', "#{filepattern}.log"
      end
    end
  end
end
