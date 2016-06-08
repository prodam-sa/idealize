module Prodam::Idealize::DateHelper
  def formated_date(date, format = '%d/%m/%Y')
    date && date.strftime(format)
  end

  def formated_time(date, format = '%H:%M')
    date && date.strftime(format)
  end
end
