module DateCalculators
  def hours
    self * 3600
  end
  def hour
    hours
  end

  def seconds
    self
  end

  def second
    seconds
  end

  def minute
    minutes
  end
  def minutes
    self * 60
  end

  def day
    days
  end

  def days
    24*3600 * self
  end

  def week
  	weeks
  end

  def weeks
  	days * 7
  end
end

class Fixnum 
	include DateCalculators
end

class Float
	include DateCalculators
end