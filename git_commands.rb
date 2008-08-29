class GitCommands
  def diff_staging
    fetch
    puts `git diff origin/production origin/staging`
  end
  
  def tag_staging(branch_name)
    verify_working_directory_clean
    
    fetch
    `git branch -f staging origin/staging`
    `git checkout staging`
    `git reset --hard origin/#{branch_name}`
    `git push -f origin staging`
    `git checkout master`
    `git branch -D staging`
  end
  
  def tag_production
    verify_working_directory_clean
    
    fetch
    `git branch -f production origin/production`
    `git checkout production`
    `git reset --hard origin/staging`
    `git push -f origin production`
    `git checkout master`
    `git branch -D production`
  end

  def branch_production(branch_name)
    verify_working_directory_clean
    
    fetch
    `git branch -f production origin/production`
    `git checkout production`
    `git branch #{branch_name}`
    `git checkout #{branch_name}`
    `git push origin #{branch_name}`
  end
  
private
  
  def fetch
    `git fetch`
  end

  def verify_working_directory_clean
    return if `git status` =~ /working directory clean/
    raise "Must have clean working directory"
  end
end

