# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/receipts/receipt_printer'

RSpec.describe Receipts::ReceiptPrinter do
  describe '.print' do
    let(:receipt_data) do
      {
        items: [
          { name: 'book', quantity: 1, total_cost_cents: 1249 },
          { name: 'music CD', quantity: 1, total_cost_cents: 1649 }
        ],
        total_sales_taxes_cents: 150,
        total_price_cents: 2898
      }
    end

    it 'prints formatted receipt to stdout' do
      expected_output = <<~OUTPUT.chomp
        1 book: 12.49
        1 music CD: 16.49
        Sales Taxes: 1.50
        Total: 28.98
      OUTPUT

      expect { described_class.print(receipt_data) }.to output("#{expected_output}\n").to_stdout
    end

    context 'with multiple quantities' do
      let(:receipt_data) do
        {
          items: [
            { name: 'chocolate bar', quantity: 3, total_cost_cents: 660 }
          ],
          total_sales_taxes_cents: 60,
          total_price_cents: 660
        }
      end

      it 'displays quantity in output' do
        expected_output = <<~OUTPUT.chomp
          3 chocolate bar: 6.60
          Sales Taxes: 0.60
          Total: 6.60
        OUTPUT

        expect { described_class.print(receipt_data) }.to output("#{expected_output}\n").to_stdout
      end
    end

    context 'with zero taxes' do
      let(:receipt_data) do
        {
          items: [
            { name: 'book', quantity: 1, total_cost_cents: 1000 }
          ],
          total_sales_taxes_cents: 0,
          total_price_cents: 1000
        }
      end

      it 'prints zero tax amount' do
        expected_output = <<~OUTPUT.chomp
          1 book: 10.00
          Sales Taxes: 0.00
          Total: 10.00
        OUTPUT

        expect { described_class.print(receipt_data) }.to output("#{expected_output}\n").to_stdout
      end
    end

    context 'with no items' do
      let(:receipt_data) do
        {
          items: [],
          total_sales_taxes_cents: 0,
          total_price_cents: 0
        }
      end

      it 'prints only totals' do
        expected_output = <<~OUTPUT.chomp
          Sales Taxes: 0.00
          Total: 0.00
        OUTPUT

        expect { described_class.print(receipt_data) }.to output("#{expected_output}\n").to_stdout
      end
    end

    context 'with cents rounding' do
      let(:receipt_data) do
        {
          items: [
            { name: 'imported perfume', quantity: 1, total_cost_cents: 5499 }
          ],
          total_sales_taxes_cents: 749,
          total_price_cents: 5499
        }
      end

      it 'formats prices with two decimal places' do
        expected_output = <<~OUTPUT.chomp
          1 imported perfume: 54.99
          Sales Taxes: 7.49
          Total: 54.99
        OUTPUT

        expect { described_class.print(receipt_data) }.to output("#{expected_output}\n").to_stdout
      end
    end
  end

  describe '.format_price' do
    it 'formats cents to dollars with two decimals' do
      expect(described_class.send(:format_price, 1249)).to eq('12.49')
      expect(described_class.send(:format_price, 1000)).to eq('10.00')
      expect(described_class.send(:format_price, 0)).to eq('0.00')
      expect(described_class.send(:format_price, 5)).to eq('0.05')
      expect(described_class.send(:format_price, 99)).to eq('0.99')
    end
  end
end