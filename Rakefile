#!/usr/bin/env rake
require 'resque/tasks'
require File.expand_path('../config/application', __FILE__)
task "resque:setup" => :environment

Minuteman::Application.load_tasks
