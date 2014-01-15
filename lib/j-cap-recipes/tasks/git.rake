namespace :git do
  namespace :release do
    desc 'Add tag on success deploy on production'
    task :tag do
      version_number = fetch(:git_tag_name) { Time.now.to_s.gsub(/[\s\+:]+/, '_') }
      tag_name       = "#{fetch(:stage)}-#{version_number}"
      system("git tag -a -m \"Version #{tag_name} released\" '#{tag_name}'") &&
        (puts "Created tag `#{tag_name}`") &&
          `git push --tags`
    end
  end
end
