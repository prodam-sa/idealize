module Prodam::Idealize::DateHelper
  def formated_date(date, format = '%d/%m/%Y')
    date && date.strftime(format)
  end

  def formated_time(date, format = '%H:%M')
    date && date.strftime(format)
  end

  def months
    {  1 => 'Janeiro',
       2 => 'Fevereiro',
       3 => 'Março',
       4 => 'Abril',
       5 => 'Maio',
       6 => 'Junho',
       7 => 'Julho',
       8 => 'Agosto',
       9 => 'Setembro',
      10 => 'Outubro',
      11 => 'Novembro',
      12 => 'Dezembro' }
  end
end
