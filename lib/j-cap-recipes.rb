puts "hello"

Dir.glob('lib/capistrano/tasks/*.rb').each { |r| p r; require r }
