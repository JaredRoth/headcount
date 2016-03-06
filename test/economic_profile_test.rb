require_relative 'test_helper'
require_relative '../lib/economic_profile'
require_relative '../lib/district_repository'

class EconomicProfileTest < Minitest::Test
  def setup
    data = {:median_household_income => {[2014, 2015] => 50000, [2013, 2014] => 60000},
                :children_in_poverty => {2012 => 0.1845},
                :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
                :title_i => {2015 => 0.543},
                :name => "ACADEMY 20"
               }
        @ep = EconomicProfile.new(data)
  end

  def test_can_create_object_from_imported_data
    skip
    epr = EconomicProfileRepository.new
    epr.load_data({
                    :statewide_testing => {
                      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
                      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
                      :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
                      :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
                      :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
                    }
                  })

    assert_equal 181, epr.count
    assert epr.find_by_name("ACADEMY 20")

    result = epr.find_by_name("ACADEMY 20")

    assert_equal 1, result.median_household_income_in_year(2015)
    assert_equal 1, result.median_household_income_average
    assert_equal 1, result.children_in_poverty_in_year(2012)
    assert_equal 1, result.free_or_reduced_price_lunch_percentage_in_year(2014)
    assert_equal 1, result.free_or_reduced_price_lunch_number_in_year(2014)
    assert_equal 1, result.title_i_in_year(2015)
  end

  def test_economic_profile_provides_name_for_district
    assert_equal "ACADEMY 20", @ep.name
  end

  def test_median_household_income_in_year_returns_UnknownDataError

    assert_raises UnknownDataError do
      @ep.median_household_income_in_year(2030)
    end
  end

  def test_median_household_income_average_returns_UnknownDataError
    skip
    assert_raises UnknownDataError do
      @ep.median_household_income_average(2030)
    end
  end

  def test_children_in_poverty_in_year_returns_UnknownRaceError
    skip
    assert_raises UnknownDataError do
      @ep.children_in_poverty_in_year(2030)
    end
  end

  def test_lunch_percentage_returns_UnknownDataError
    skip
    assert_raises UnknownDataError do
      @ep.free_or_reduced_price_lunch_percentage_in_year(2030)
    end
  end

  def test_lunch_number_returns_UnknownDataError
    skip
    assert_raises UnknownDataError do
      @ep.free_or_reduced_price_lunch_number_in_year(2030)
    end
  end

  def test_title_i_in_year_returns_UnknownDataError
    skip
    assert_raises UnknownDataError do
      @ep.title_i_in_year(2030)
    end
  end

  def test_median_household_income_in_year_calculates_properly
    assert_equal 50000, @ep.median_household_income_in_year(2015)
  end

  def test_median_household_income_average_calculates_properly
    skip
    assert_equal 55000, @ep.median_household_income_average
  end

  def test_children_in_poverty_in_year_calculates_properly
    skip
    assert_equal 0.184, @ep.children_in_poverty_in_year(2012)
  end

  def test_lunch_percentage_calculates_properly
    skip
    assert_equal 0.023, @ep.free_or_reduced_price_lunch_percentage_in_year(2014)
  end

  def test_lunch_number_calculates_properly
    skip
    assert_equal 100, @ep.free_or_reduced_price_lunch_number_in_year(2014)
  end

  def test_number_of_free_lunches
    skip
  end

  def test_number_of_reduced_price_lunches
    skip
  end

  def test_number_of_ineligable_for_free_lunches
    skip
  end

  def test_title_i_in_year_calculates_properly
    skip
    assert_equal 0.543, @ep.title_i_in_year(2015)
  end
end
