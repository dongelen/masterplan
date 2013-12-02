#!/usr/bin/env ruby

require 'yaml'
require_relative 'Numeric'
require_relative 'Time'

class Plan
	WEEK_DAYS = ["monday", "tuesday", "wednesday", "thursday", "friday"]

	def initialize(plan, period)
		assert plan.is_a? Hash
		assert period.is_a? Hash

		@plan = plan
		@period = period

		validate_weeks 
		validate_period

		@holiday_weeks =  period["period"]["holiday_weeks"]

	end


	##
	# Creates a schedule from a plan and a period
	# It tries to schedule everything on the planned position, except when holiday weeks are encountered
	def make
		p "Volgende versie moet organisator + locatie van de sessie goed laten zien"

		@schedule =[]
		start_date= DateTime.commercial(Date.today.cwyear, @period["period"]["start_week"]).to_time
		start_date = start_date.beginning_of_day

		weeks = @plan["weeks"]
		holiday_weeks_to_skip = 0

		eat_holiday_weeks_for start_date

		p "Start week #{start_date}"
		weeks.each do |week|
			
			week_to_write = start_date + holiday_weeks_to_skip.weeks + (week["number"]-1).weeks
			# Make sure holiday weeks are taken into account

			@holiday_weeks= @holiday_weeks.drop_while do |holiday_week|
				p "Checking  #{week_to_write.cweek} #{holiday_week["week"]}"
				if week_to_write.cweek == holiday_week["week"]
					holiday_weeks_to_skip += 1
					p "Increasing holiday_weeks_to_skip #{holiday_weeks_to_skip}"

					week_to_write = start_date + holiday_weeks_to_skip.weeks + (week["number"]-1).weeks
					true
				else
					false
				end
			end
			p "Going to write to week #{week_to_write}"

			# Plan all sessions in the week
			WEEK_DAYS.each_index do |day_number|
				day = WEEK_DAYS[day_number]
				if week[day] && week[day]["sessions"]
					@schedule = @schedule + 
						plan_day(week_to_write, week[day]["sessions"], day_number) 
				end
			end
		end

		@schedule
	end

	##
	# This method converts a plan to an ical representation
	# returns a string
	def to_ical
		assert @schedule != nil
		schedule=@schedule # Hack for the each loop, @schedule is nil otherwise
	
		RiCal.Calendar do
			schedule.each do |event_to_schedule|
				event do					
					summary event_to_schedule["session"]["title"]
					description event_to_schedule["session"]["description"] if event_to_schedule["session"]["description"]  
					dtstart event_to_schedule["start_date"].with_floating_timezone
					dtend   event_to_schedule["end_date"].with_floating_timezone
				end
			end
		end
	end


	private

	def eat_holiday_weeks_for(date)
		@holiday_weeks=@holiday_weeks.drop_while do |week|
			week["week"] < date.cweek
		end
	end



	def plan_day(week_date, sessions, day_number)
		schedule = []
		sessions.each do |session|
			entry = {
				"start_date"    => week_date + day_number.days + session["start_time"].hours,
				"end_date"      => week_date + day_number.days + session["start_time"].hours + session["length"].minutes,
				"session"       => session
			}
			schedule << entry
		end
		schedule
	end


	def validate_period
		period_validations = {
			"start_week"=>"numeric",
			"holiday_weeks" => "array"
		}

	end

	def validate_weeks
		weeks_validations = {
			"weeks"=>"array"
		}
		

		validator = HashValidator.validate(@plan, weeks_validations)

		raise "Probleem in de file #{validator.errors}" unless validator.valid?
		# raise validator.errors unless validator.valid?		
		# p validator.errors

		@weeks=@plan["weeks"]
		@weeks.each do |week|
			validate_week week
		end
	end

	def validate_week(week)
		sessions_validations = {
			"sessions" => "array"
		}
		week_validations = {
			"number" => "numeric",
		}
		
		validator = HashValidator.validate(week, week_validations)
		raise "Probleem in de definitie van een week #{validator.errors}" unless validator.valid?

		WEEK_DAYS.each do |day| 
			if week[day]
				day_validator = HashValidator.validate(week[day], sessions_validations)
				raise "Probleem in de definitie van een dag #{validator.errors}" unless day_validator.valid?

				validate_sessions week[day]["sessions"]
			end
		end
		p validator.errors
	end

	def validate_sessions (sessions)
		session_validation = {
			"title" => "string",
			"start_time"=>"numeric"
		}
		sessions.each do |session|
			p session
			validator = HashValidator.validate(session, session_validation)
			raise "Probleem in de definitie van een session #{validator.errors}" unless validator.valid?
			p validator.errors
		end
	end

end