module ApplicationHelper
  def week_select(current)
    date = Date.today
    week_options = []

    0.upto(50) do |week_number|
      week_options << ((date - week_number.weeks).beginning_of_week - 1.day ) # GRRR, Sunday is beginning of week.....
    end
    
    select_tag(:start_date, options_from_collection_for_select(week_options, :to_s, :to_s, current))
  end
  
end
