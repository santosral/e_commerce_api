module TimeFrame
  TIME_FRAMES = [ "daily", "weekly", "monthly", "yearly" ].freeze

  class << self
    def dates(time_frame, date: Time.zone.now)
      case time_frame
      when "daily"
        start_date = date.beginning_of_day
        end_date = date.end_of_day
      when "weekly"
        start_date = date.beginning_of_week
        end_date = date.end_of_week
      when "monthly"
        start_date = date.beginning_of_month
        end_date = date.end_of_month
      when "yearly"
        start_date = date.beginning_of_year
        end_date = date.end_of_year
      else
        raise ArgumentError, "Invalid time frame: #{time_frame}"
      end

      { start_date: start_date, end_date: end_date }
    end

    def generate_cron_expression(time_frame)
      case time_frame
      when "daily"
        # Every day at midnight
        "0 0 * * *"
      when "weekly"
        # Every Sunday at midnight
        "0 0 * * 0"
      when "monthly"
        # On the first day of every month at midnight
        "0 0 1 * *"
      when "yearly"
        # On January 1st at midnight
        "0 0 1 1 *"
      else
        raise ArgumentError, "Invalid time frame: #{time_frame}"
      end
    end
  end
end
