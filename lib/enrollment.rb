require 'pry'
require_relative 'module_helper'

class Enrollment
  include Helper

  attr_reader :name, :kindergarten_participation

  def initialize(args)
    @name = args[:name]
    @kindergarten_participation = args[:participation]
  end

  def truncate_percentages(hash)
    hash.map do |year,value|
      [year.to_i, truncate(value.to_f)]
    end.to_h
  end

  def kindergarten_participation_by_year
    @kindergarten_participation
  end

  def kindergarten_participation_in_year(year)
    @kindergarten_participation.fetch(year, nil)
  end

  def graduation_rate_by_year
    @high_school_graduation
  end

  def graduation_rate_in_year(year)
    @high_school_graduation.fetch(year, nil)
  end
end
