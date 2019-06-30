# frozen_string_literal: true

require "spec_helper"

RSpec::Matchers.define :be_weather_phenomenon do |modifier, descriptor, phen|
  match do |wp|
    if wp.nil? && phen.nil?
      true
    elsif wp.nil? != phen.nil?
      false
    elsif wp.phenomenon != phen
      false
    elsif wp.modifier != modifier
      false
    else
      wp.descriptor == descriptor
    end
  end
end

describe Metar::Data::WeatherPhenomenon do
  context '.parse' do
    [
      [
        'simple phenomenon', 'BR',
        [nil, nil, 'mist']
      ],
      [
        'descriptor + phenomenon', 'BCFG',
        [nil, 'patches of', 'fog']
      ],
      [
        'thunderstorm and rain', 'TSRA',
        [nil, 'thunderstorm and', 'rain']
      ],
      [
        'intensity + phenomenon', '+RA',
        ['heavy', nil, 'rain']
      ],
      [
        'intensity + proximity + phenomenon', '-VCTSRA',
        ['nearby light', 'thunderstorm and', 'rain']
      ],
      [
        '2 phenomena: SN RA', 'SNRA',
        [nil, nil, 'snow and rain']
      ],
      [
        '2 phenomena: RA DZ', 'RADZ',
        [nil, nil, 'rain and drizzle']
      ],
      [
        'modifier + descriptor + phenomenon', 'VCDRFG',
        ['nearby', 'low drifting', 'fog']
      ],
      [
        'returns nil for unmatched', 'FUBAR',
        [nil, nil, nil]
      ]
    ].each do |docstring, raw, expected|
      example docstring do
        expect(described_class.parse(raw)).to be_weather_phenomenon(*expected)
      end
    end
  end

  context '#to_s' do
    before :all do
      @locale = I18n.locale
      I18n.locale = :it
    end

    after :all do
      I18n.locale = @locale
    end

    [
      [
        'simple phenomenon', :en,
        [nil, nil, 'mist'],
        'mist'
      ],
      [
        'simple phenomenon', :it,
        [nil, nil, 'mist'],
        'foschia'
      ],
      [
        'descriptor + phenomenon', :en,
        [nil, 'patches of', 'fog'],
        'patches of fog'
      ],
      [
        'thunderstorm and rain', :en,
        [nil, 'thunderstorm and', 'rain'],
        'thunderstorm and rain'
      ],
      [
        'modifier + phenomenon', :en,
        ['heavy', nil, 'drizzle'],
        'heavy drizzle'
      ],
      [
        'modifier + descriptor + phenomenon', :en,
        %w[heavy freezing drizzle],
        'heavy freezing drizzle'
      ]
    ].each do |docstring, locale, (modifier, descriptor, phenomenon), expected|
      example docstring + " (#{locale})" do
        I18n.locale = locale
        subject = described_class.new(
          nil,
          phenomenon: phenomenon, modifier: modifier, descriptor: descriptor
        )
        expect(subject.to_s).to eq(expected)
      end
    end
  end
end
