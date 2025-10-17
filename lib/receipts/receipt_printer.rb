# frozen_string_literal: true

module Receipts
  # The ReceiptPrinter is responsible solely for formatting and printing
  # receipt data that has already been computed by the ReceiptOperator.
  module ReceiptPrinter
    # Prints a formatted receipt to STDOUT.
    #
    # @param receipt_data [Hash]
    #   A hash containing all computed receipt information:
    #     - :items [Array<Hash>] each with :name, :quantity, :total_cost_cents
    #     - :total_sales_taxes_cents [Integer]
    #     - :total_price_cents [Integer]
    #
    # @example
    #   printer = Receipts::ReceiptPrinter.new
    #   printer.print(receipt_data)
    def self.print(receipt_data)
      lines = receipt_data[:items].map do |item|
        "#{item[:quantity]} #{item[:name]}: #{format_price(item[:total_cost_cents])}"
      end

      lines << "Sales Taxes: #{format_price(receipt_data[:total_sales_taxes_cents])}"
      lines << "Total: #{format_price(receipt_data[:total_price_cents])}"

      puts lines.join("\n")
    end

    private

    # Formats a price in cents into a string with two decimal places.
    #
    # @param cents [Integer] price amount in cents
    # @return [String] formatted price (e.g. "24.98")
    def self.format_price(cents)
      format('%.2f', cents.to_f / 100)
    end
  end
end
