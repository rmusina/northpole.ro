load 'deploy'

DEPLOY_TO = "/home/cristian/northpolero"
 
# must be set for the password promt from git to work
default_run_options[:pty] = true

set :application, "northpolero"
set :user, "cristian"

# this forwards the ssh-key from the computer that initializes the deploy
ssh_options[:forward_agent] = true
#set :use_sudo, false

set :scm, :git
set :repository, "git@github.com:northpole-api/northpole.ro.git"

server "northpole.ro", :app, :primary => true
set :deploy_to, DEPLOY_TO
set :keep_releases, 5

def production_cfg key, value
  run "cd northpolero/current/; ki config -k #{key} -v #{value}"
end

namespace :np do
  task :start, :roles => :app do
    sudo "whoami"
    run "cd northpolero/current/; rvmsudo bundle exec thin -C ~/northpolero/current/config.yml start"
  end

  task :stop, :roles => :app, :on_error => :continue do
    sudo "whoami"
    run "cd northpolero/current/; rvmsudo bundle exec thin stop"
  end
end

namespace :deploy do
  task :config_north_pole, :roles => :app do
    path = File.join(DEPLOY_TO, 'current')
    run "rm -f #{path}/.rvmrc"
    production_cfg 'chdir', path
    production_cfg 'environment', 'production'
    production_cfg 'port', '80'
    production_cfg 'daemonize', 'true'
  end
end

before "deploy", "np:stop"
after "deploy", "deploy:config_north_pole" 
after "deploy:config_north_pole", "np:start"

after "deploy:update", "deploy:cleanup"
