# frozen_string_literal: true

class Item
  attr_reader :quantity, :name, :price_cents

  EXEMPT_ITEMS = %w[book chocolate chocolates pills food medicine].freeze

  def initialize(quantity:, name:, price_cents:)
    raise ArgumentError, "Quantity must be positive" if quantity <= 0
    raise ArgumentError, "Price must be non-negative" if price_cents < 0
    raise ArgumentError, "Name cannot be blank" if name.nil? || name.strip.empty?

    @quantity = quantity
    @name = name
    @price_cents = price_cents
  end

  def imported?
    name.include?('imported')
  end

  def exempt?
    EXEMPT_ITEMS.any? { |item| name.include?(item) }
  end
end
