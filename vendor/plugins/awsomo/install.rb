# Install hook code here
require 'fileutils'

awsomo_config = File.dirname(__FILE__) + '/../../../config/awsomo.yml'
FileUtils.cp File.dirname(__FILE__) + '/awsomo.yml.tpl', awsomo_config unless File.exist?(awsomo_config)
puts IO.read(File.join(File.dirname(__FILE__), 'README'))