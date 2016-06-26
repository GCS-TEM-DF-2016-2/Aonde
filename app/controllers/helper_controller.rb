######################################################################
# Class name: HelperController
# File name: helper_controller.rb
# Description: Contain some methods to help process data in controllers
#######################################################################
module HelperController

  MONTHNAMES_BR = [ nil ] + %w( Janeiro Fevereiro Março Abril Maio Junho
                             Julho Agosto Setembro Outubro Novembro Dezembro )

  # Description: Allocates expenses to months and stores them in a hash.
  # Parameters: expense_of_a_month.
  # Return: expense_of_a_month.
  def self.int_to_month( expense_of_a_month )
    expense_of_a_month.transform_keys! do |month|
      MONTHNAMES_BR[ month ]
    end
    return expense_of_a_month
  end

  # Description: Gets all the expenses of a given public agency, sums them all, 
  # and associates them to a given year.
  # Parameters: id_public_agency, year.
  # Return: expense_year.
  def self.expenses_year( id_public_agency, year )
    expense_year = Expense.where( public_agency_id: id_public_agency,
                                 payment_date: "#{year}-01-01".."#{year}-12-31" )
                   .group( 'MONTH( payment_date )' ).sum( :value )
    expense_year
  end

  # Description: Finds the expenses of a given entity.
  # Parameters: year, id, name_entity, attribute.
  # Return: none.
  def self.find_expenses_entity( year = '2015', id, name_entity, attribute )
    if year.nil?
     year = 2015
    else
      # Nothing to do.
    end
   Expense.joins( name_entity )
      .where( public_agency_id: id, 
              payment_date: "#{year}-01-01".."#{year}-12-31" )
      .select( attribute ).order( 'sum_value DESC' ).group( attribute )
      .sum( :value ).transform_values! {|v| v.to_f}.to_a
  end

  # Description: Creates a date, in hash form, based on parameters provided by
  # the user.
  # Parameters: date.
  # Return: date.
  def self.create_date( date = { from_month: 'Janeiro', end_month: 'Dezembro',
                                from_year: 2009, end_year: 2020 } )
    first_month = month_to_int( date[ :from_month ] )
    last_month = month_to_int( date[ :end_month ] )
    first_date = Date.new( date[ :from_year ].to_i, first_month, 1 )
    last_date = Date.new( date[ :end_year ].to_i, last_month, 1 )

    last_date = last_day_date( last_date )
    date = { begin: first_date, end: last_date }
    return date
  end

  # Description: Returns the index of a given month in the MONTHS_BR array. 
  # Basically, returns the position of a month in the year.
  # Parameters: month.
  # Return: index.
  def self.month_to_int( month )
    index = MONTHNAMES_BR.index( month )
    return index
  end

  # Description: Checks if a given time interval is valid.
  # Parameters: begin_date, end_date
  # Return: validation_status
  def self.date_valid?( begin_date, end_date )
    validation_status = true

    if ( begin_date.year == end_date.year )
      if begin_date.month > end_date.month
        validation_status = false
      else
        # Nothing to do
      end
    elsif begin_date.year > end_date.year
      validation_status = false
    else
      validation_status = true
    end
    return validation_status
  end

  # Description: Gets the last day of month.
  # Parameters: date.
  # Return: last_day.
  def self.last_day_date( date )
    month = date.month
    last_day = 0
    if month == 2
      last_day = leap_year_day( date )
    elsif ( month.odd? && month <= 7 ) || ( month.even? && month >= 8 )
      last_day = 31
    else
      last_day = 30
    end
    return date.change( day: last_day )
  end

  # Description: Checks if the year of a given date is a leap year, and adjust
  # the day accordingly.
  # Parameters: date.
  # Return: day.
  def self.leap_year_day( date )
    day = 0
    if date.leap?
      day = 29
    else
      day = 28
    end
    return day
  end

  private_class_method :leap_year_day,:last_day_date,:date_valid?,:month_to_int

end
