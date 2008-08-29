require File.dirname(__FILE__) + "/git_commands"

namespace :git do
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
end
