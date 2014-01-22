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
end
