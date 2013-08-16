#!/usr/bin/env ruby
# Wraps around a set of rake tasks so we can follow CLI conventions

require 'rake'
require File.expand_path('../../lib/trollop',  __FILE__)

opts = Trollop::options do
  opt :import, "Import data into vex"
  opt :export, "Export data from vex"
  opt :index, "Set up indexes"
  opt :environment, "Environment to use", :default => "production"
  opt :type, "Type of data to import/export", :type => :string
  opt :directory, "Directory to import from/export to", :default => File.expand_path('../../export', __FILE__)
  opt :item, "Item to import/export", :type => :string
  opt :clear, "Clear directory", :default => true
end

#Trollop::die "Nothing to do" if ARGV.empty?
Trollop::die "Nothing to do" if (opts[:import] == false) and (opts[:export] == false) and (opts[:index] == false)
Trollop::die "You can only import or export, not do both" if (opts[:import] == true) and (opts[:export] == true)

app = Rake.application
app.init
app.load_rakefile

# Set our environment variables
ENV["VEX_EXPORT_DIRECTORY"] = opts[:directory]
ENV["VEX_IMPORTEXPORT_TARGET"] = opts[:item]
ENV["RAILS_ENV"] = opts[:environment]

if opts[:index]
  app['db:mongo:index'].invoke
end

if opts[:import]
  unless opts[:type] or opts[:item]
    app['yaml:import'].invoke
  else
    app["yaml:import:#{opts[:type]}"].invoke
  end
end

if opts[:export]
  unless opts[:type] or opts[:item]
    app['yaml:export'].invoke
  else
    app["yaml:export:#{opts[:type]}"].invoke
  end
end
