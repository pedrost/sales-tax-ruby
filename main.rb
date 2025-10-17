# frozen_string_literal: true

require_relative 'lib/input/tax_input_parser'
require_relative 'lib/receipts/receipt_printer'
require_relative 'lib/receipts/receipt_operator'
require_relative 'lib/calculators/standard_tax_calculator'

input_file = ARGV[0]

lines = File.readlines(input_file, chomp: true)
items = Input::TaxInputParser.parse!(lines)

standard_calculator = Calculators::StandardTaxCalculator 

receipt_data = Receipts::ReceiptOperator.calculate_receipt_data(items: items, tax_calculator: standard_calculator)
Receipts::ReceiptPrinter.print(receipt_data)
