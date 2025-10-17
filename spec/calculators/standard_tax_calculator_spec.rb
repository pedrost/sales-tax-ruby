# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/calculators/standard_tax_calculator'

RSpec.describe Calculators::StandardTaxCalculator do
  describe '.calculate_tax' do
    context 'with exempt, non-imported item' do
      let(:item) { double('Item', price_cents: 1000, exempt?: true, imported?: false) }

      it 'applies no tax' do
        result = described_class.calculate_tax(item)
        expect(result).to eq(1000)
      end
    end

    context 'with non-exempt, non-imported item' do
      let(:item) { double('Item', price_cents: 1000, exempt?: false, imported?: false) }

      it 'applies 10% basic sales tax rounded up' do
        result = described_class.calculate_tax(item)
        expect(result).to eq(1100) # 1000 + 100 tax
      end

      it 'correctly rounds up fractional cents without using floats' do
        # price_cents = 1212, tax_rate = 15%
        # exact result = 181.8 → should ceil to 182
        item = double('Item', price_cents: 1212, exempt?: false, imported?: true)

        result = described_class.send(:tax, item)

        expect(result).to eq(185) # 182 rounded up to nearest 5 cents
      end
    end

    context 'with exempt, imported item' do
      let(:item) { double('Item', price_cents: 1000, exempt?: true, imported?: true) }

      it 'applies 5% import duty only' do
        result = described_class.calculate_tax(item)
        expect(result).to eq(1050) # 1000 + 50 import duty
      end
    end

    context 'with non-exempt, imported item' do
      let(:item) { double('Item', price_cents: 1000, exempt?: false, imported?: true) }

      it 'applies 15% total tax (10% basic + 5% import)' do
        result = described_class.calculate_tax(item)
        expect(result).to eq(1150) # 1000 + 150 tax
      end
    end

    context 'with rounding required' do
      let(:item) { double('Item', price_cents: 1499, exempt?: false, imported?: false) }

      it 'rounds tax up to nearest 5 cents' do
        # 1499 * 10% = 149.9, rounds up to 150
        # tax 150 + price 1499 = 1649
        result = described_class.calculate_tax(item)
        expect(result).to eq(1649)
      end
    end

    context 'with import duty rounding' do
      let(:item) { double('Item', price_cents: 2799, exempt?: true, imported?: true) }

      it 'rounds import duty up to nearest 5 cents' do
        # 2799 * 5% = 139.95, rounds up to 140
        # tax 140 + price 2799 = 2939
        result = described_class.calculate_tax(item)
        expect(result).to eq(2939)
      end
    end

    context 'with combined tax requiring rounding' do
      let(:item) { double('Item', price_cents: 4750, exempt?: false, imported?: true) }

      it 'rounds combined 15% tax up to nearest 5 cents' do
        # 4750 * 15% = 712.5, rounds up to 715
        # tax 715 + price 4750 = 5465
        result = described_class.calculate_tax(item)
        expect(result).to eq(5465)
      end
    end
  end

  describe '.round_up_to_nearest_five_cents' do
    it 'rounds up to nearest 5 cents' do
      expect(described_class.send(:round_up_to_nearest_five_cents, 712)).to eq(715)
      expect(described_class.send(:round_up_to_nearest_five_cents, 718)).to eq(720)
      expect(described_class.send(:round_up_to_nearest_five_cents, 701)).to eq(705)
    end

    it 'returns value unchanged when already multiple of 5' do
      expect(described_class.send(:round_up_to_nearest_five_cents, 715)).to eq(715)
      expect(described_class.send(:round_up_to_nearest_five_cents, 700)).to eq(700)
      expect(described_class.send(:round_up_to_nearest_five_cents, 0)).to eq(0)
    end

    it 'handles edge cases' do
      expect(described_class.send(:round_up_to_nearest_five_cents, 1)).to eq(5)
      expect(described_class.send(:round_up_to_nearest_five_cents, 4)).to eq(5)
      expect(described_class.send(:round_up_to_nearest_five_cents, 99)).to eq(100)
    end
  end

  describe '.tax' do
    context 'with various tax rate combinations' do
      it 'calculates 0% tax for exempt, non-imported' do
        item = double('Item', price_cents: 1000, exempt?: true, imported?: false)
        expect(described_class.send(:tax, item)).to eq(0)
      end

      it 'calculates 10% tax for non-exempt, non-imported' do
        item = double('Item', price_cents: 1000, exempt?: false, imported?: false)
        expect(described_class.send(:tax, item)).to eq(100)
      end

      it 'calculates 5% tax for exempt, imported' do
        item = double('Item', price_cents: 1000, exempt?: true, imported?: true)
        expect(described_class.send(:tax, item)).to eq(50)
      end

      it 'calculates 15% tax for non-exempt, imported' do
        item = double('Item', price_cents: 1000, exempt?: false, imported?: true)
        expect(described_class.send(:tax, item)).to eq(150)
      end
    end
  end
end