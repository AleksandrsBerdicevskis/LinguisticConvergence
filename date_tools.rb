@veryfirstyear = 1998

def daysinyear(year)
    if [2000, 2004, 2008, 2012, 2016, 2020].include?(year)
        days = 366
    else
        days = 365
    end
    return days
end

def daysinyears(year)
    days = 0
    for i in @veryfirstyear..year-1
        days += daysinyear(i)
    end
    days
end

def daysinmonth(month, year)
    if month == 2
        if daysinyear(year) == 366
            days = 29
        else
            days = 28
        end
    else
        days = {1 => 31, 3 => 31, 4 => 30, 5 => 31, 6 => 30, 7 => 31, 8 => 31, 9 => 30, 10 => 31, 11 => 30, 12 => 31}[month]
    end
    
    return days
end

def daysinmonths(month, year)
    days = 0
    for i in 1..month-1
        days += daysinmonth(i, year)
    end
    return days
end

def abs_day(ints)
    year = ints[0].to_i
    month = ints[1].to_i
    day = ints[2].to_i
    absolute_day = daysinyears(year) + daysinmonths(month, year) + day
    return absolute_day
end

def date_to_array(date, sep)
    array = date.split(sep)
    
    return array

end

def absmonth(yearmonth)
    absmonth = yearmonth[0..3].to_i + yearmonth[4..5].to_i
    return absmonth
end