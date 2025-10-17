# frozen_string_literal: true

module Calculators
  # StandardTax is responsible for calculating the basic tax rate and import duty rate
  # for items accoriding to the business rules:
  #   - Basic sales tax: 10% on all goods except exempt items
  #   - Import duty: 5% on all imported goods, no exemptions
  #   - Taxes are rounded up to the nearest 0.05 (5 cents)
  module StandardTaxCalculator
    BASIC_TAX_RATE   = 10                # 10%
    IMPORT_DUTY_RATE = 5                 # 5%
    PERCENT_BASE     = 100               # 100%
    ROUNDING_UNIT    = 5                 # rounding to nearest 5 cents
    BASIS_POINTS     = 10_000            # 1 basis point = 0.01%

    # @param item [Item]
    # @return [Integer] price in cents including taxes
    def self.calculate_tax(item)
      item.price_cents + tax(item)
    end

    private

    # @param item [Item]
    # @return [Integer] tax amount in cents
    def self.tax(item)
      tax_rate = 0
      tax_rate += BASIC_TAX_RATE unless item.exempt?
      tax_rate += IMPORT_DUTY_RATE if item.imported?

      # 1212 cents
      # tax_rate_basis_points = 1500 basis points 
      tax_rate_basis_points = tax_rate * PERCENT_BASE
      # → 1212 * 1500 = 1,818,000
      # → (1,818,000 + 9,999) / 10,000 = 182
      raw_tax = (item.price_cents * tax_rate_basis_points + BASIS_POINTS - 1) / BASIS_POINTS

      round_up_to_nearest_five_cents(raw_tax)
    end

    # Rounds a value in cents up to the nearest multiple of 5.
    #
    # This is used to comply with the sales tax rounding rules:
    # - Sales tax is rounded up to the nearest 0.05
    #
    # @param amount_cents [Integer] The amount in cents to round
    # @return [Integer] The amount rounded up to the nearest 5 cents
    #
    # @examples
    #   round_up_to_nearest_five_cents(712) # => 715
    #   round_up_to_nearest_five_cents(718) # => 720
    #   round_up_to_nearest_five_cents(715) # => 715
    def self.round_up_to_nearest_five_cents(amount_cents)
      remainder = amount_cents % ROUNDING_UNIT

      # If the amount is already a multiple of the rounding unit, return it as is
      return amount_cents if remainder.zero?

      # Otherwise, add the difference to reach the next multiple of rounding_unit
      amount_cents + (ROUNDING_UNIT - remainder)
    end

  end
end