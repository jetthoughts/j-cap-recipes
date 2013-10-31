rake_files_pattern =  File.expand_path("./j-cap-recipes/tasks/*.rake", File.dirname(__FILE__))
Dir.glob(rake_files_pattern).each { |r| import r }
