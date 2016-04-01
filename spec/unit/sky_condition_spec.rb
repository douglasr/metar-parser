# encoding: utf-8
require "spec_helper"

RSpec::Matchers.define :be_sky_condition do |quantity, height, type|
  match do |sk|
    if    sk.nil? && quantity == :expect_nil
      true
    elsif sk.nil? && quantity != :expect_nil
      false
    elsif sk.quantity != quantity
      false
    elsif sk.height.is_a?(Metar::Distance) && sk.height.value != height
      false
    elsif sk.type != type
      false
    else
      true
    end
  end
end

describe Metar::SkyCondition do
  context '.parse' do
    [
      ['understands clear skies codes', 'NSC',      [nil,            nil,            nil]],
      ['quantity + height',             'BKN12',    ['broken',    365.76,            nil]],
      ['quantity + height + type',      'BKN12CB',  ['broken',    365.76, 'cumulonimbus']],
      ['quantity + ///',                'BKN///',   ['broken',       nil,            nil]],
      ['quantity + height + ///',       'FEW038///',['few',      1158.24,            nil]],
      ['cumulonimbus only',             'CB',       [nil,            nil, 'cumulonimbus']], # seems non-standard, but occurs
      ['returns nil for unmatched',     'FUBAR',    [:expect_nil,    nil,            nil]],
    ].each do |docstring, raw, expected|
      example docstring do
        expect(Metar::SkyCondition.parse(raw)).to be_sky_condition(*expected)
      end
    end
  end

  context '.to_summary' do
    [
      ['all values nil',  [nil,      nil, nil           ], :en,      'clear skies'        ],
      ['quantity',        ['broken', nil, nil           ], :en,      'broken cloud'       ],
      ['quantity',        ['broken', nil, nil           ], :'en-US', 'broken clouds'      ],
      ['quantity + type', ['broken', nil, 'cumulonimbus'], :en,      'broken cumulonimbus'],
      ['quantity + type', ['broken', nil, 'cumulonimbus'], :'en-US', 'broken cumulonimbus clouds'],
    ].each do |docstring, (quantity, height, type), locale, expected|
      before { @old_locale = I18n.locale }
      after  { I18n.locale = @old_locale }

      example "#{docstring} - #{locale}" do
        condition = Metar::SkyCondition.new(quantity, height, type)
        I18n.locale = locale
        expect(condition.to_summary).to eq(expected)
      end
    end
  end

  context '.to_s' do
    [
      ['all values nil',  [nil,      nil, nil],            'clear skies'               ],
      ['quantity',        ['broken', 360, nil],            'broken cloud at 360'       ],
      ['quantity + type', ['broken', 360, 'cumulonimbus'], 'broken cumulonimbus at 360'],
    ].each do |docstring, (quantity, height, type), expected|
      example docstring do
        condition = Metar::SkyCondition.new(quantity, height, type)
        expect(condition.to_s).to eq(expected)
      end
    end
  end
end

