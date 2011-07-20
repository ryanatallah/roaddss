module RecordsHelper

  def ccyf(num, precision = nil) # Currency format
    if precision == nil
      number_to_currency(num, :precision => 0, :unit => @currency_sym, :delimiter => @delimiter, :separator => @separator)
    else
      number_to_currency(num, :precision => precision, :unit => @currency_sym, :delimiter => @delimiter, :separator => @separator)
    end
  end

  def numf(num, precision = nil)
    if precision == nil
      number_with_precision(num, :precision => 0, :delimiter => @delimiter, :separator => @separator)
    else
      number_with_precision(num, :precision => precision, :delimiter => @delimiter, :separator => @separator)
    end
  end

  def current_tab(current_page, current_tab)
    if current_page == current_tab
      return "current"
    else
      return "not-current"
    end
  end
end
