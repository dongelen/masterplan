require 'rubygems' 
require 'bundler/setup'


Bundler.require
require_relative 'Plan'
require_relative 'Time'
require_relative 'Numeric'

SolidAssert.enable_assertions


@plan   = YAML.load_file('plan.yaml')	
@period = YAML.load_file('period.yaml')	

plan = Plan.new(@plan, @period)
schedule = plan.make

ics = plan.to_ical

p ics


File.open("output.ics", 'w') { |file| file.write(ics) }


