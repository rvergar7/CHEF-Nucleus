#
# Cookbook:: install_ma
# Recipe:: default
# Author:: Raphael Vergara (McAfee)
#
# Copyright:: 2020, The Authors, All Rights Reserved.

# Get the temp directory irrespective of OS
require 'tmpdir'
temp = Dir.tmpdir()

# set the installation directory where we will store the files
installer_directory = "#{temp}/McAfee/ma"
extract_directory = "#{installer_directory}/extract"

# Get the OS Platform
os_platform = "#{node['platform']}"

# Clean up, just in case something has been left over, we want to delete before & after
directory "#{installer_directory}" do
 recursive true
 action :delete
end

# Create a McAfee folder to store files
directory "#{installer_directory}" do
  action :create
  recursive true
end

# Set the installation source and options based on OS Platform
if os_platform == "windows"
    
   # Set the installation source
   installer_source = "FramePkg.exe"
   installer_options = "/INSTALL=AGENT /SILENT"
   
   # Move the file into the directory we created
   cookbook_file "#{installer_directory}/#{installer_source}" do
    source "#{installer_source}"
    action :create
   end
   
   # Install McAfee Agent
   windows_package "McAfee Agent" do
     source            "#{installer_directory}/#{installer_source}"
     options           "#{installer_options}"
     installer_type    :custom
     action            :install
   end
   
elsif os_platform == "centos"

  # Set the installation source
  installer_source = "agentPackages"
  installer_options = "-i"
  
  # Move the file into the directory we created
  cookbook_file "#{installer_directory}/#{installer_source}" do
    mode "755"
    source "#{installer_source}"
    action :create
  end
  
  # Install McAfee Agent
  bash 'mcafee_agent' do
    cwd   "#{installer_directory}"
    code <<-EOH
      unzip #{installer_source} -d #{extract_directory}
      cd #{extract_directory}
      ./install.sh #{installer_options}
      EOH
  end
    
end

# Clean up
directory "#{installer_directory}" do
  recursive true
  action :delete
end
