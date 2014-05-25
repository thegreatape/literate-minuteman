#!/usr/bin/env rake
require 'resque/tasks'
require File.expand_path('../config/application', __FILE__)
task "resque:setup" => :environment
task default: [:spec, :teaspoon]

Minuteman::Application.load_tasks
