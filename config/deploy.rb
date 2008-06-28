require 'pp'

default_run_options[:pty] = true

set :application, "nuniverse"
set :repository,  "git@github.com:Nguma/nuniverse.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/apps/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

set :user,            "deployer"
set :password,        "wossname"
set :scm_passphrase,  "wossname"
set :use_sudo,        true
set :branch,          "master"
set :runner,          nil # "root"

role :app, "specing.net"
role :web, "specing.net"
role :db,  "specing.net", :primary => true

task :echo_vars do
  pp variables.keys.collect { |key| key.to_s }.sort
  pp variables[:default_environment]
end

namespace :deploy do
  task :after_setup do
    sudo "mkdir -p #{shared_path}/assets"
    sudo "mkdir -p #{shared_path}/log"
    sudo "mkdir -p #{shared_path}/config"
    # sudo "mkdir -p #{shared_path}/db/sphinx"
    
    sphinx.install
    image_science.install
    
    # bdb.install
    # bdb.install_bindings
    
    # wordnet.install
    # wordnet.install_bindings
  end
  
  task :after_update do
    # sudo "cp #{release_path}/config/database.example.yml #{release_path}/config/database.yml"
  end
    
  # task :after_cold do
  #   sphinx.index
  #   sphinx.start
  # end
  # 
  # task :after_migrate do
  #   sphinx.configure
  # end
  
  task :after_symlink do
    sudo <<-CMD
      rm -fr #{release_path}/log &&
      ln -nfs #{shared_path}/log #{release_path}/log
    CMD
    
    # sudo <<-CMD
    #   rm -fr #{release_path}/db/sphinx &&
    #   ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx
    # CMD
    
    # sudo <<-CMD
    #   rm -fr #{release_path}/public/assets &&
    #   ln -nfs #{shared_path}/assets #{release_path}/public/assets
    # CMD
    
    # sudo "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    
    sudo "chmod +x #{release_path}/script/spin"
  end
end

namespace :sphinx do
  task :install do
    run <<-CMD
      cd /home/#{user} &&
      echo "Downloading Sphinx 0.9.8rc2" &&
      curl -s -O http://sphinxsearch.com/downloads/sphinx-0.9.8-rc2.tar.gz &&
      tar -zxf sphinx-0.9.8-rc2.tar.gz &&
      cd sphinx-0.9.8-rc2 &&
      echo "Configuring Sphinx" &&
      ./configure > configure.log &&
      echo "Building Sphinx" &&
      make > make.log &&
      echo "Installing Sphinx" &&
      sudo make install > make.install.log &&
      cd .. &&
      rm -rf sphinx-0.9.8-rc2*
    CMD
  end
  
  task :stop do
    sudo "cd #{current_path} && rake thinking_sphinx:stop RAILS_ENV=production"
  end
  
  task :start do
    configure
    sudo "cd #{current_path} && rake thinking_sphinx:start RAILS_ENV=production"
  end
  
  task :restart do
    stop
    start
  end
  
  task :index do
    sudo "cd #{current_path} && rake thinking_sphinx:index RAILS_ENV=production"
  end
  
  task :configure do
    sudo "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=production"
  end
end

namespace :image_science do
  task :install do
    install_free_image
    install_gems
  end
  
  task :install_free_image do
    run <<-CMD
      cd /home/#{user} &&
      curl -O http://internap.dl.sourceforge.net/sourceforge/freeimage/FreeImage3100.zip &&
      unzip FreeImage3100.zip > zip.log &&
      cd FreeImage &&
      make > make.log &&
      sudo make install > make.install.log &&
      cd .. &&
      rm -rf FreeImage*
    CMD
  end
  
  task :install_gems do
    sudo "gem install -y image_science"
  end
end