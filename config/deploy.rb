# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'ngs_teatime'
set :repo_url, 'https://github.com/t-oginogin/ngs_teatime.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :branch, :master

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/ngs_teatime'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
#set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/assets', 'tmp/job_work')

# Default value for default_env is {}
set :default_env, { path: "/home/vagrant/.rbenv/shims:/home/vagrant/.rbenv/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do

  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
