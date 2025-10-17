# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/domain/item'

RSpec.describe Item do
  describe '#initialize' do
    context 'with valid parameters' do
      it 'creates an item with correct attributes' do
        item = Item.new(quantity: 2, name: 'book', price_cents: 1249)
        
        expect(item.quantity).to eq(2)
        expect(item.name).to eq('book')
        expect(item.price_cents).to eq(1249)
      end

      it 'allows zero price for free items' do
        item = Item.new(quantity: 1, name: 'free sample', price_cents: 0)
        
        expect(item.price_cents).to eq(0)
      end
    end

    context 'with invalid quantity' do
      it 'raises ArgumentError for zero quantity' do
        expect { Item.new(quantity: 0, name: 'book', price_cents: 1249) }
          .to raise_error(ArgumentError, 'Quantity must be positive')
      end

      it 'raises ArgumentError for negative quantity' do
        expect { Item.new(quantity: -1, name: 'book', price_cents: 1249) }
          .to raise_error(ArgumentError, 'Quantity must be positive')
      end
    end

    context 'with invalid price' do
      it 'raises ArgumentError for negative price' do
        expect { Item.new(quantity: 1, name: 'book', price_cents: -100) }
          .to raise_error(ArgumentError, 'Price must be non-negative')
      end
    end

    context 'with invalid name' do
      it 'raises ArgumentError for nil name' do
        expect { Item.new(quantity: 1, name: nil, price_cents: 1249) }
          .to raise_error(ArgumentError, 'Name cannot be blank')
      end

      it 'raises ArgumentError for empty string name' do
        expect { Item.new(quantity: 1, name: '', price_cents: 1249) }
          .to raise_error(ArgumentError, 'Name cannot be blank')
      end

      it 'raises ArgumentError for whitespace-only name' do
        expect { Item.new(quantity: 1, name: '   ', price_cents: 1249) }
          .to raise_error(ArgumentError, 'Name cannot be blank')
      end
    end
  end

  describe '#imported?' do
    context 'when item name contains "imported"' do
      it 'returns true for "imported" at the beginning' do
        item = Item.new(quantity: 1, name: 'imported box of chocolates', price_cents: 1000)
        expect(item.imported?).to be true
      end

      it 'returns true for "imported" in the middle' do
        item = Item.new(quantity: 1, name: 'box of imported chocolates', price_cents: 1000)
        expect(item.imported?).to be true
      end

      it 'returns true for "imported" at the end' do
        item = Item.new(quantity: 1, name: 'chocolates imported', price_cents: 1000)
        expect(item.imported?).to be true
      end
    end

    context 'when item name does not contain "imported"' do
      it 'returns false' do
        item = Item.new(quantity: 1, name: 'box of chocolates', price_cents: 1000)
        expect(item.imported?).to be false
      end
    end

    context 'case sensitivity' do
      it 'is case sensitive for "imported"' do
        item = Item.new(quantity: 1, name: 'IMPORTED chocolates', price_cents: 1000)
        expect(item.imported?).to be false
      end
    end
  end

  describe '#exempt?' do
    context 'books' do
      it 'returns true for items containing "book"' do
        item = Item.new(quantity: 1, name: 'book', price_cents: 1249)
        expect(item.exempt?).to be true
      end

      it 'returns true for compound names with "book"' do
        item = Item.new(quantity: 1, name: 'paperback book', price_cents: 1249)
        expect(item.exempt?).to be true
      end
    end

    context 'food items' do
      it 'returns true for items containing "chocolate"' do
        item = Item.new(quantity: 1, name: 'chocolate bar', price_cents: 85)
        expect(item.exempt?).to be true
      end

      it 'returns true for items containing "chocolates"' do
        item = Item.new(quantity: 1, name: 'box of chocolates', price_cents: 1125)
        expect(item.exempt?).to be true
      end

      it 'returns true for items containing "food"' do
        item = Item.new(quantity: 1, name: 'baby food', price_cents: 299)
        expect(item.exempt?).to be true
      end
    end

    context 'medical products' do
      it 'returns true for items containing "pills"' do
        item = Item.new(quantity: 1, name: 'packet of headache pills', price_cents: 975)
        expect(item.exempt?).to be true
      end

      it 'returns true for items containing "medicine"' do
        item = Item.new(quantity: 1, name: 'bottle of medicine', price_cents: 1000)
        expect(item.exempt?).to be true
      end
    end

    context 'non-exempt items' do
      it 'returns false for music CD' do
        item = Item.new(quantity: 1, name: 'music CD', price_cents: 1499)
        expect(item.exempt?).to be false
      end

      it 'returns false for perfume' do
        item = Item.new(quantity: 1, name: 'bottle of perfume', price_cents: 4750)
        expect(item.exempt?).to be false
      end

      it 'returns false for general items' do
        item = Item.new(quantity: 1, name: 'laptop', price_cents: 100000)
        expect(item.exempt?).to be false
      end
    end

    context 'imported exempt items' do
      it 'correctly identifies exempt status regardless of import status' do
        item = Item.new(quantity: 1, name: 'imported box of chocolates', price_cents: 1000)
        
        expect(item.exempt?).to be true
        expect(item.imported?).to be true
      end
    end
  end
end