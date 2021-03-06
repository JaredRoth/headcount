require_relative 'test_helper'
require_relative '../lib/headcount_analyst'

class HeadcountAnalystTest < Minitest::Test

  dr = DistrictRepository.new
  dr.load_data({:enrollment => {
                  :kindergarten => "./data/Kindergartners in full-day program.csv",
                  :high_school_graduation => "./data/High school graduation rates.csv",
                 },
                 :statewide_testing => {
                   :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
                   :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
                   :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
                   :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
                   :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
                 }
               })
  dr

  @@ha = HeadcountAnalyst.new(dr)

  def test_Kindergarten_participation_average
    assert_equal 0.766, @@ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
  end

  def test_Kindergarten_participation_comparison_year_over_year
    year_over_year = {2007=>0.992, 2006=>1.05, 2005=>0.96, 2004=>1.258, 2008=>0.717, 2009=>0.652, 2010=>0.681, 2011=>0.727, 2012=>0.687, 2013=>0.693, 2014=>0.661}

    assert_equal year_over_year, @@ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
  end

  def test_Kindergarten_participation_comparison_district_vs_district_over_time_period
    district_vs_district = {2007=>0.826, 2006=>0.954, 2005=>1.328, 2004=>1.735, 2008=>0.801, 2009=>0.534, 2010=>0.472, 2011=>0.514, 2012=>0.491, 2013=>0.498, 2014=>0.504}

    assert_equal district_vs_district, @@ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'ADAMS-ARAPAHOE 28J')
  end

  def test_kindergarten_participation_comparison_district_with_multiple_years_vs_district_with_one_year_data
    district_vs_district = {2007=>0.391, 2006=>0.353, 2005=>0.267, 2004=>0.0, 2008=>0.384, 2009=>0.39, 2010=>0.436, 2011=>0.489, 2012=>0.478, 2013=>0.487, 2014=>0.49}

    assert_equal district_vs_district, @@ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
  end


  def test_truncate_any_given_value
    assert_equal 0.432, @@ha.truncate(0.432154)
  end

  def test_kindergarten_participation_variation_compare_to_the_high_school_graduation_variation

    assert_equal 0.548, @@ha.kindergarten_participation_against_high_school_graduation('MONTROSE COUNTY RE-1J')
    assert_equal 0.800, @@ha.kindergarten_participation_against_high_school_graduation('STEAMBOAT SPRINGS RE-2')
  end

  def test_Kindergarten_participation_predict_high_school_graduation_rate_for_district

    assert @@ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
    refute @@ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'MONTROSE COUNTY RE-1J')
    assert @@ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'WELD COUNTY S/D RE-8')
  end

  def test_Kindergarten_participation_predict_high_school_graduation_returns_true_if_above_70_percent_the_district

    refute @@ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'SIERRA GRANDE R-30')
    assert @@ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'PARK (ESTES PARK) R-3')
  end

  def test_Kindergarten_participation_predict_high_school_graduation_returns_false_if_under_70_percent_the_state

    refute @@ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
  end

  def test_kindergarten_participation_accross_several_districts

    districts = ["ACADEMY 20", 'PARK (ESTES PARK) R-3', 'YUMA SCHOOL DISTRICT 1']
    assert @@ha.kindergarten_participation_correlates_with_high_school_graduation(:across => districts)
  end

  ##############################################################################################################################

  def test_finding_top_overall_districts

     assert_equal "SANGRE DE CRISTO RE-22J", @@ha.top_statewide_test_year_over_year_growth(grade: 3).first
     assert_equal 0.071, @@ha.top_statewide_test_year_over_year_growth(grade: 3).last

    assert_equal "OURAY R-1", @@ha.top_statewide_test_year_over_year_growth(grade: 8).first
     assert_equal 0.11, @@ha.top_statewide_test_year_over_year_growth(grade: 8).last
  end

  def test_single_object_results_by_subject

    assert_equal ["WILEY RE-13 JT", 0.3], @@ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :math)
  end

  def test_specific_subject_returns_top_school

    assert_equal ["OURAY R-1", 0.11], @@ha.top_statewide_test_year_over_year_growth(grade: 8)
  end

  def test_state_wide_analysis_returns_top_three_districts

    top_district = [["WILEY RE-13 JT", 0.3], ["SANGRE DE CRISTO RE-22J", 0.071], ["COTOPAXI RE-3", 0.07]]
    assert_equal top_district, @@ha.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math)
  end

  def test_weighting_results_by_subject

    top_performer = @@ha.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
    assert_equal "OURAY R-1", top_performer.first
    assert_equal 0.153, top_performer.last
  end

  def test_insufficient_information_errors

    assert_raises(InsufficientInformationError) do
      @@ha.top_statewide_test_year_over_year_growth(subject: :math)
    end
  end

  def test_top_state_wide_test_returns_UnknownDataError_for_invladid_grade

    assert_raises(UnknownDataError) do
      @@ha.top_statewide_test_year_over_year_growth(grade: 9 )
    end
  end


end
