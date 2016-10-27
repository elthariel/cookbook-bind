require 'spec_helper'

include Named::Helpers

describe Named::Helpers do
  describe '#generate_zone_serial' do
    it 'returns a String' do
      expect(generate_zone_serial).to be_a(String)
    end

    it 'returns a timestamp' do
      value = generate_zone_serial.to_i
      expect(value).to be_a(Numeric)
      expect(value > 0).to be_truthy
    end

    it 'takes a DateTime parameter' do
      expect { generate_zone_serial(DateTime.now - 50) }.not_to raise_error
    end
  end
end
