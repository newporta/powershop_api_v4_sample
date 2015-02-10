class ConsumersController < ApplicationController
  WDAY_TO_NAME = {
    0 => "Sun",
    1 => "Mon",
    2 => "Tue",
    3 => "Wed",
    4 => "Thur",
    5 => "Fri",
    6 => "Sat",
  }
  def index
    @consumers = token.get("/api/v4/consumers", params: {filter: "active"}).parsed["consumers"]
  end

  def show
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : ( 2.months.ago.beginning_of_week.to_date - 1.day ) # GRRR, Sunday is beginning of week.....
    @end_date = @start_date + 6.days

    @json_url = request.original_url

    if request.headers["HTTP_ACCEPT"].include?("application/json")
      @consumer = token.get("/api/v4/consumers/#{params[:id]}").parsed["consumer"]
      nsp_id = @consumer["nsp_id"]

      path = "/api/v4/consumers/#{@consumer["id"]}/time_of_use_readings"
      customer_reads = token.get(path, params: {start_date: @start_date, end_date: @end_date}).parsed["time_of_use_readings"]

      path = "/api/v4/nsps/#{nsp_id}/aggregated_time_of_use_readings"
      nsp_reads = token.get(path, params: {start_date: @start_date, end_date: @end_date}).parsed["aggregated_time_of_use_readings"]

      @data = []
      customer_reads.each do |date, readings|
        day = Date.parse(date).wday
        day_data = Array.new(24, 0)
        nsp_readings = nsp_reads[date]
        readings.each_with_index do |reading, index|
          hour_index = (index / 2)
          day_data[hour_index] += reading
          day_data[hour_index] -= nsp_readings[index]
        end

        day_data.each_with_index do |value, hour|
          @data << {day: day, hour: hour, value: value}
        end
      end
      render json: @data.to_json
    end
  end
end
