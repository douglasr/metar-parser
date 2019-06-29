# frozen_string_literal: true

class Metar::Data::DensityAltitude < Metar::Data::Base
  def self.parse(raw)
    feet = raw[/^(\d+)(FT)/, 1]
    height = Metar::Data::Distance.feet(feet)

    new(raw, height: height)
  end

  attr_accessor :height

  def initialize(raw, height:)
    @raw = raw
    @height = height
  end
end
