namespace :airbrake do
  desc <<-DESC
            Notify Airbrake of the deployment by running the notification on the REMOTE machine.
              - Run remotely so we use remote API keys, environment, etc.
  DESC
  task :deploy do
    rails_env = fetch(:rails_env, "production")
    airbrake_env = fetch(:airbrake_env, fetch(:rails_env, "production"))
    local_user = ENV['USER'] || ENV['USERNAME']

    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          notify_command = [:rake, 'environment airbrake:deploy', "TO=#{airbrake_env}", "REVISION=#{fetch(:current_revision)}",
                            "REPO='#{fetch(:repo_url)}' USER=#{AirbrakeCapistrano::shellescape(local_user)}"]
          notify_command << "API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']
          execute *notify_command
        end
      end
    end
  end
end

module AirbrakeCapistrano
  def self.shellescape(str)
    str = str.to_s

    # An empty argument will be skipped, so return empty quotes.
    return "''" if str.empty?

    str = str.dup

    # Treat multibyte characters as is.  It is caller's responsibility
    # to encode the string in the right encoding for the shell
    # environment.
    str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")

    # A LF cannot be escaped with a backslash because a backslash + LF
    # combo is regarded as line continuation and simply ignored.
    str.gsub!(/\n/, "'\n'")

    return str
  end
end

