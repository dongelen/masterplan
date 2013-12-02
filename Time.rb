class Time
  def +(s)
    Time.at (self.to_i + s)
  end 


  def beginning_of_day
  	Time.new(self.year, self.month, self.day,0,0,0)
  end

  def cweek
  	# p "Levert een wat de fuckje, week nummer steeds 1 te laag"
  	self.strftime("%V").to_i
  end
end