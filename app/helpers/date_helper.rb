module Prodam::Idealize::DateHelper
  def formated_date(date, format = '%d/%m/%Y')
    date && date.strftime(format)
  end
end
