require "spec_helper"

describe Metar::VariableWind do
  context '.parse' do
    it 'understands nnn + V + nnn' do
      vw = Metar::VariableWind.parse( '090V180' )

      expect(vw.direction1.value).to eq( 90.0)
      expect(vw.direction2.value).to eq(180.0)
    end

    it 'accepts 360, rounding to 0 - 1' do
      vw = Metar::VariableWind.parse( '360V090' )

      expect(vw.direction1.value).to eq(  0.0)
      expect(vw.direction2.value).to eq( 90.0)
    end


    it 'accepts 360, rounding to 0 - 2' do
      vw = Metar::VariableWind.parse( '090V360' )

      expect(vw.direction1.value).to eq( 90.0)
      expect(vw.direction2.value).to eq(  0.0)
    end

    it 'returns nil for other' do
      vw = Metar::VariableWind.parse( 'XXX' )

      expect(vw).to be_nil
    end
  end

  context '#to_s' do
    it 'renders compatible values as compass directions' do
      vw = Metar::VariableWind.parse( '090V180' )

      expect(vw.to_s).to eq('E - S')
    end
  end
end
