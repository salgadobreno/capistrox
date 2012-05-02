namespace :dropbox do
  desc "Install dropbox on the server"
  task :install, roles: :app do
    run "cd ~ && wget -O - 'http://www.dropbox.com/download?plat=lnx.x86' | tar xzf -" #install dropbox
    # install dropbox py script utility
    run "mkdir ~/bin"
    run "wget -O ~/bin/dropbox.py 'http://www.dropbox.com/download?dl=packages/dropbox.py'"
    run "chmod 755 ~/bin/dropbox.py"
    # try starting the script to get the url
    while true
      run "~/bin/dropbox.py start"
      input = Capistrano::CLI.ui.ask("r -> retry, c -> continue, s -> status")
      case input
      when "r" then next
      when "s" then run "~/bin/dropbox.py status"
      when "c" then break
      end
    end
    install_service
    sync_exclude
    start
  end
  #after "deploy:install", "dropbox:install"

  desc "Install dropbox service"
  task :install_service do
    template "dropbox_service.erb", "/tmp/dropbox_service"
    run "#{sudo} mv /tmp/dropbox_service /etc/init.d/dropbox"
    run "#{sudo} chmod 755 /etc/init.d/dropbox"
    run "#{sudo} update-rc.d dropbox defaults"
  end

  desc "List unsynced folders"
  task :sync_exclude_list do
    puts "Excluded folders:"
    run "~/bin/dropbox.py exclude list"
  end

  desc "Exclude folders from syncing"
  task :sync_exclude do
    while true
      sync_exclude_list
      puts "All folders:"
      run "#{sudo} ls ~/Dropbox"
      input = Capistrano::CLI.ui.ask("Enter list of folders to exclude from syncing, separated with spaces:\n Press 'f' to finnish")

      case input
      when "f" then break
      else
        run "cd ~/Dropbox && ~/bin/dropbox.py exclude add #{input}" unless input.empty?
      end
    end
  end

  %w[start stop status filestatus running].each do |command|
    desc "#{command} nginx"
    task command do
      run "cd ~/Dropbox && ~/bin/dropbox.py #{command}"
    end
  end

end
