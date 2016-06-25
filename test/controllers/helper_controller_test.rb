#####################################################################
# Class name: HelperControllerTest.
# File name: helper_controller_test.rb.
# Description: Test class that contains all functional tests for
# helper controller.
#####################################################################

require 'test_helper'

class HelperControllerTest < ActiveSupport::TestCase
  test 'change the last day to 31 in months odd' do
    date_odd = Date.new( 2015, 7, 1 )

    date_odd = HelperController.send( :last_day_date,date_odd )
    date_expected = Date.new( 2015, 7, 31 )
    assert_equal( date_expected, date_odd )
  end

  test 'change the last day to 31 in months even' do
    date_even = Date.new( 2015, 8, 1 )

    date_even = HelperController.send( :last_day_date,date_even )
    date_expected = Date.new( 2015, 8, 31 )
    assert_equal( date_expected, date_even )
  end

  test 'change the last day to 30 in month' do
    date = Date.new( 2015, 9, 1 )

    date = HelperController.send( :last_day_date,date )
    date_expected = Date.new( 2015, 9, 30 )
    assert_equal( date_expected, date )
  end

  test 'change the last day to 28 in February month' do
    date_february = Date.new( 2015, 2, 1 )

    date_february = HelperController.send( :last_day_date,date_february )
    date_expected = Date.new( 2015, 2, 28 )
    assert_equal( date_expected, date_february )
  end

  test 'the last day value of a leap year' do
    date_leap = Date.new( 2012, 2, 1 )
    day_leap = HelperController.send( :leap_year_day,date_leap )
    expected_last_day = 29
    assert_equal( expected_last_day, day_leap )
  end

  test 'the last day value of a not leap year' do
    date_not_leap = Date.new( 2013, 2, 1 )
    day_not_leap = HelperController.send( :leap_year_day,date_not_leap )
    expected_last_day = 28
    assert_equal( expected_last_day, day_not_leap )
  end

  test 'create the dates hash with begin and end months' do
    param_date = { from_month: 'Janeiro', end_month: 'Novembro',
                   from_year: 2014, end_year: 2015 }
    date = HelperController.send( :create_date,param_date )
    expect_dates = { begin: Date.new( 2014, 01, 01 ), end: Date.new( 2015, 11, 30 ) }
    assert_equal( expect_dates, date )
  end

  test 'create the dates hash without params' do
    date = HelperController.send( :create_date )
    expect_dates = { begin: Date.new( 2009, 01, 01 ), end: Date.new( 2020, 12, 31 ) }
    assert_equal( expect_dates, date )
  end

  test 'valid input date' do
    begin_date = Date.new( 2014, 2, 2 )
    end_date = Date.new( 2015, 2, 2 )
    assert( HelperController.send( :date_valid?,begin_date, end_date ) )
  end

  test 'invalid date with month differentes' do
    begin_date = Date.new( 2015, 3, 2 )
    end_date = Date.new( 2015, 2, 2 )
    assert_not( HelperController.send( :date_valid?,begin_date, end_date ) )
  end

  test 'invalid date with year differentes' do
    begin_date = Date.new( 2015, 3, 2 )
    end_date = Date.new( 2014, 2, 2 )
    assert_not( HelperController.send( :date_valid?,begin_date, end_date ) )
  end

  test 'Change int to name of month' do
    array = { 01 => 100, 03 => 100, 04 => 100, 10 => 100 }
    array_expect = {"Janeiro"=>100, "Março"=>100, "Abril"=>100, "Outubro"=>100}
    array_month = HelperController.send( :int_to_month,array )
    assert_equal( array_expect, array_month )
  end
 end
