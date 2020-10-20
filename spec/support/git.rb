def git_set_user
 run_command_and_stop 'git config user.email "info@flatironschool.com"'
 run_command_and_stop 'git config user.name "Flatiron School"'
end

def git_init
  run_command_and_stop 'git init'
  git_set_user
end

def git_add(files = '.')
  run_command_and_stop "git add #{files}"
end

def git_commit(msg)
  run_command_and_stop "git commit -m \"#{msg}\""
end
