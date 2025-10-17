# frozen_string_literal: true

module Receipts
  module ReceiptOperator
    # Processes all items with a given tax calculator.
    #
    # @param items [Array<Item>] list of items
    # @param tax_calculator [Object] responds to #calculate(item)
    # @return [Hash] receipt summary
    def self.calculate_receipt_data(items:, tax_calculator:)
      items_with_tax = items.map do |item|
        taxed_price_cents = tax_calculator.calculate_tax(item)
        total_cost_cents = taxed_price_cents * item.quantity
        tax_amount_cents = (taxed_price_cents - item.price_cents) * item.quantity

        {
          name: item.name,
          quantity: item.quantity,
          total_cost_cents: total_cost_cents,
          tax_amount_cents: tax_amount_cents
        }
      end

      total_sales_taxes_cents = items_with_tax.sum { |i| i[:tax_amount_cents] }
      total_price_cents = items_with_tax.sum { |i| i[:total_cost_cents] }

      {
        items: items_with_tax,
        total_sales_taxes_cents: total_sales_taxes_cents,
        total_price_cents: total_price_cents
      }
    end
  end
end
