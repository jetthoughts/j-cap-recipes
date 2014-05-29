namespace :git do
  namespace :release do
    desc 'Add tag on success deploy on production'
    task :tag do
      version_number = fetch(:git_tag_name) { release_timestamp }
      tag_name       = "#{fetch(:stage)}-#{version_number}"
      branch         = fetch(:branch, '')
      branch
      system("git tag -a -m \"Version #{tag_name} released\" '#{tag_name}' #{branch}") &&
        `git push --tags` &&
          (puts "Created tag `#{tag_name}`")
    end
  end

  desc 'Updates repository url'
  task :update_repo_url do
    on release_roles :all do
      within repo_path  do
        with fetch(:git_environmental_variables) do
          execute :git, :remote, 'set-url', 'origin', fetch(:repo_url)
        end
      end
    end
  end
end
