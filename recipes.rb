class GitCommands

  def diff_staging
    `git fetch`
    puts `git diff origin/production origin/staging`
  end
  
  def tag_staging(branch_name)
    verify_working_directory_clean
    
    `git fetch`
    `git branch -f staging origin/staging`
    `git checkout staging`
    `git reset --hard origin/#{branch_name}`
    `git push -f origin staging`
    `git checkout master`
    `git branch -D staging`
  end
  
  def tag_production
    verify_working_directory_clean
    
    `git fetch`
    `git branch -f production origin/production`
    `git checkout production`
    `git reset --hard origin/staging`
    `git push -f origin production`
    `git checkout master`
    `git branch -D production`
  end

  def branch_production(branch_name)
    verify_working_directory_clean
    
    `git fetch`
    `git branch -f production origin/production`
    `git checkout production`
    `git branch #{branch_name}`
    `git checkout #{branch_name}`
    `git push origin #{branch_name}`
  end
  
protected

  def verify_working_directory_clean
    return if `git status` =~ /working directory clean/
    raise "Must have clean working directory"
  end
end


namespace :tag do
  desc <<-DESC
    Update the staging branch to prepare for a staging deploy.
    Defaults to master. Optionally specify a BRANCH=name
  DESC
  
  task :staging do
    branch_name = ENV['BRANCH'] || "master"
    GitCommands.new.tag_staging(branch_name)
  end

  desc "Update the remove production branch to prepare for a release"
  task :production => ['diff:staging'] do
    GitCommands.new.tag_production
  end
end

namespace :diff do
  desc "Show the differences between the staging branch and the production branch"
  task :staging do
    GitCommands.new.diff_staging
  end
end

namespace :branch do
  desc "Branch from production for tweaks or bug fixs. Specify BRANCH=name"
  task :production do
    branch_name = ENV['BRANCH']
    raise "You must specify a branch name using BRANCH=name" unless branch_name
    GitCommands.new.branch_production
  end
end

namespace :deploy do
  desc "Tag and deploy staging"
  task :staging => "tag:staging" do
    `cap staging deploy:long`
  end
end
