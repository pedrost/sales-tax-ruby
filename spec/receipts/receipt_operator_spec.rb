# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/receipts/receipt_operator'

RSpec.describe Receipts::ReceiptOperator do
  describe '.calculate_receipt_data' do
    let(:tax_calculator) { double('TaxCalculator') }
    let(:item) { double('Item', name: 'book', quantity: 1, price_cents: 1000) }

    context 'with a single item' do
      it 'calculates total cost and tax for one item' do
        allow(tax_calculator).to receive(:calculate_tax).with(item).and_return(1050)

        result = described_class.calculate_receipt_data(
          items: [item],
          tax_calculator: tax_calculator
        )

        expect(result[:items].first[:name]).to eq('book')
        expect(result[:items].first[:quantity]).to eq(1)
        expect(result[:items].first[:total_cost_cents]).to eq(1050)
        expect(result[:items].first[:tax_amount_cents]).to eq(50)
        expect(result[:total_sales_taxes_cents]).to eq(50)
        expect(result[:total_price_cents]).to eq(1050)
      end
    end

    context 'with multiple items' do
      let(:item1) { double('Item', name: 'book', quantity: 2, price_cents: 1000) }
      let(:item2) { double('Item', name: 'music CD', quantity: 1, price_cents: 1500) }

      it 'calculates totals across all items' do
        allow(tax_calculator).to receive(:calculate_tax).with(item1).and_return(1000)
        allow(tax_calculator).to receive(:calculate_tax).with(item2).and_return(1650)

        result = described_class.calculate_receipt_data(
          items: [item1, item2],
          tax_calculator: tax_calculator
        )

        expect(result[:items].size).to eq(2)
        expect(result[:items][0][:total_cost_cents]).to eq(2000)
        expect(result[:items][0][:tax_amount_cents]).to eq(0)
        expect(result[:items][1][:total_cost_cents]).to eq(1650)
        expect(result[:items][1][:tax_amount_cents]).to eq(150)
        expect(result[:total_sales_taxes_cents]).to eq(150)
        expect(result[:total_price_cents]).to eq(3650)
      end
    end

    context 'with quantity greater than 1' do
      let(:item) { double('Item', name: 'chocolate bar', quantity: 3, price_cents: 200) }

      it 'multiplies tax and cost by quantity' do
        allow(tax_calculator).to receive(:calculate_tax).with(item).and_return(220)

        result = described_class.calculate_receipt_data(
          items: [item],
          tax_calculator: tax_calculator
        )

        expect(result[:items].first[:total_cost_cents]).to eq(660)
        expect(result[:items].first[:tax_amount_cents]).to eq(60)
      end
    end

    context 'with no items' do
      it 'returns zero totals' do
        result = described_class.calculate_receipt_data(
          items: [],
          tax_calculator: tax_calculator
        )

        expect(result[:items]).to be_empty
        expect(result[:total_sales_taxes_cents]).to eq(0)
        expect(result[:total_price_cents]).to eq(0)
      end
    end

    context 'with no tax applied' do
      let(:item) { double('Item', name: 'book', quantity: 1, price_cents: 1000) }

      it 'returns zero tax amount' do
        allow(tax_calculator).to receive(:calculate_tax).with(item).and_return(1000)

        result = described_class.calculate_receipt_data(
          items: [item],
          tax_calculator: tax_calculator
        )

        expect(result[:items].first[:tax_amount_cents]).to eq(0)
        expect(result[:total_sales_taxes_cents]).to eq(0)
        expect(result[:total_price_cents]).to eq(1000)
      end
    end
  end
end