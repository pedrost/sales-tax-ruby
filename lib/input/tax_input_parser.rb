# frozen_string_literal: true

require_relative '../domain/item'

module Input
  # This class makes explicit the business rules for parsing string of keywords input into 
  # array of structured Item objects.
  #
  # Parsing rules:
  #   - The first token is treated as the quantity.
  #   - The word "at" separates the item name from its price.
  #   - Prices are converted to integer cents (e.g., 12.49 → 1249) to avoid floating point issues.
  #
  # Example input lines:
  #   "2 imported bottle of perfume at 47.50"
  #   "1 book at 12.49"
  #
  module TaxInputParser

    # @param lines [Array<String>] Input lines from the basket file
    # @return [Array<Item>] List of parsed Item objects
    # @raise [ArgumentError] if any line is invalid
    def self.parse!(lines)
      lines.map.with_index do |line, index|
        parse_line!(line)
      rescue ArgumentError, TypeError, IndexError, FloatDomainError => e
        raise ArgumentError, <<~MSG
          Invalid input file at line #{index + 1}!
          Reason: #{e.message}
          Line: "#{line}"
        MSG
      end
    end

    # @param line [String] Single basket line, e.g., "1 book at 12.49"
    # @return [Item] Parsed item object
    # @raise [ArgumentError] if the line is missing quantity, name, or price
    def self.parse_line!(line)
      raise ArgumentError, "Line cannot be empty" if line.nil? || line.strip.empty?
      tokens = line.split(' ')
      quantity = Integer(tokens.shift)

      at_index = tokens.index('at')
      raise ArgumentError, "Missing 'at' in line: #{line}" unless at_index

      name = tokens[0...at_index].join(' ')
      price_str = tokens[(at_index + 1)..].join(' ')
      raise ArgumentError, "Missing price in line: #{line}" if price_str.empty?

      price_cents = price_str.delete('.').to_i

      Item.new(quantity: quantity, name: name, price_cents: price_cents)
    end
  end

end