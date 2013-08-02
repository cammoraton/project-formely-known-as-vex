#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
# No idea why, but rake broke completely on my OSX machine unless I explicitly included
# the DSL
require 'rake/dsl_definition'
require 'rake'

Vex::Application.load_tasks
