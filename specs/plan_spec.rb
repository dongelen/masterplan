require_relative '../Plan'

Bundler.require


describe Plan do
	def valid_master_plan
		{
			"weeks" => [{
							"number" => 1,
							"monday" => {
								"sessions" => [{
									"title" => "Kickoff",
									"start_time" => 9.00,
			
								},{
									"title" => "Presentation",
									"start_time" => 15.00,						
								}]
							}
						},
						{
							"number" => 3,
							"monday" => {
								"sessions" => [{
									"title" => "Weekly meeting",
									"start_time" => 10.00,
			
								}]
							},
							"tuesday" => {
								"sessions" => [{
									"title" => "Team presentation",
									"start_time" => 15.00,			
								}]
							}

						}
					]
		}
	end


	def valid_period
		{
			"period" => {
				"start_week" => 35,
				"holiday_weeks" => [
					{
						"week" => 43
					}
				]
			}
		}
	end

	def valid_period_holiday
		{
			"period" => {
				"start_week" => 35,
				"holiday_weeks" => [
					{
						"week" => 34 # irrelevant holiday
					},

					{
						"week" => 37 # exactly in the third week 
					}
				]
			}
		}
	end


	it 'plans' do
		plan = Plan.new(valid_master_plan, valid_period)
		schedule = plan.make

		first_date = schedule.first["start_date"]
		first_date.year.should == 2013
		first_date.month.should == 8
		first_date.hour.should == 9

		second_date = schedule[1]["start_date"]
		second_date.year.should == 2013
		second_date.hour.should == 15
	end

	
	it "plans a second week" do
		plan = Plan.new(valid_master_plan, valid_period)
		schedule = plan.make
		
		third_week_first_date = schedule[2]["start_date"]
		third_week_first_date.year.should == 2013		
		third_week_first_date.month.should == 9
		third_week_first_date.day.should == 9
		third_week_first_date.hour.should == 10.0

		third_week_second_date = schedule[3]["start_date"]
		third_week_second_date.year.should == 2013		
		third_week_second_date.month.should == 9
		third_week_second_date.day.should == 10
		third_week_second_date.hour.should == 15.0
	end

	it "takes holidays into account" do
		plan = Plan.new(valid_master_plan, valid_period_holiday)
		schedule = plan.make

		# first date should not move
		first_date = schedule.first["start_date"]
		first_date.year.should == 2013
		first_date.month.should == 8
		first_date.day.should == 26

		first_date.hour.should == 9


		# Third date should be moved a week
		third_week_first_date = schedule[2]["start_date"]
		third_week_first_date.year.should == 2013		
		third_week_first_date.month.should == 9
		third_week_first_date.day.should == 16
		third_week_first_date.hour.should == 10.0


	end

end