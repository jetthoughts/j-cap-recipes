module JCap
  module Recipes
    module Util
      class << self
        def database_name(env_name, config_contents)
          db_config = YAML.load(config_contents)
          db_config[env_name][:database] || db_config[env_name]['database']
        end
      end
    end
  end
end
