# app/helpers/currency_helper.rb
module CurrencyHelper
  def format_budget(amount)
    # get the user curreny
    currency = current_user&.currency_with_default || 'EUR'

    # show ：€100 or $100
    case currency
    when 'EUR'
      "€#{amount.to_f.round(2)}"
    when 'USD'
      "$#{amount.to_f.round(2)}"
    else
      "#{amount.to_f.round(2)} #{currency}"
    end
  end

  def budget_label
    currency = current_user&.currency_with_default || 'EUR'
    "Budget (#{currency})"
  end
end
