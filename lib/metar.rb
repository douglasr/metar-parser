require 'metar/raw'
require 'metar/station'
require 'metar/parser'
require 'metar/report'
require 'metar/version'

module Metar
  # Base class for all Metar exceptions
  class MetarError < StandardError
  end

  # Raised when an unrecognized value is found
  class ParseError < MetarError
  end
end
