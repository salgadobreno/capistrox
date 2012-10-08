Note: This is probably very raw yet/a shameless hack, looked for something that did that in the internets but found nothing so I rushed a solution to do what I wanted to do...

Using Dropbox as your GIT server: http://blog.rogeriopvl.com/archives/using-git-with-dropbox/

You should probably set an own folder for your deploys so that you don't annoy your server with useless syncing.

In your deploy.rb, recipes/dropbox.rb or in a file being loaded by it, add the template method:

def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

Load the recipes in your deploy.rb

load "config/recipes/dropbox"

Configure...

#..
server 'your-server-ip', :web, :app, :db, :primary => true

set :repository, "file:///home/#{user}/Dropbox/server/YOURAPP.git"
set :local_repository, 'file:///home/#{local_user}/Dropbox/server/YOURAPP.git'
#..

**NOTE: it's probably easier to just install dropbox by hand**

Run: cap dropbox:install to install Dropbox
It will run, then call dropbox:install_service, then dropbox:sync_exclude and then dropbox:start

dropbox:install will install dropbox and download dropbox.py utility to it, then it will try 'dropbox.py start' and ask if you want to retry, see dropbox status or continue

This is because it seems the first time you try to start it, it just warns you that the server isn't linked to Dropbox, then starts outputing the link you have to follow to link it


dropbox:install_service will copy the dropbox service template to your /etc/init.d, chmod and update-rc.d

**WARNING: Dropbox may overload your server CPU at first by trying to sync everything, it's important that you tell it to ignore all folders but the one you use for deploy(prefferably before it downloads millions of stuff to your server). I once had also had to Google how to limit a process's CPU usage because this happened and SSH would even get unresponsive(lol)**
dropbox:sync_exclude is another interactive task that will ask you which folders you don't want the Dropbox to sync on the server, you type the names and then enter 'f' to finnish.

Then there's dropbox:start, dropbox:stop, dropbox:status which control the service

And there's also dropbox:filestatus, it's utility from dropbox.py which tells you the status of the syncing for each folder, so you can know when to fire your cap deploy!


/rushedreadme
