# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/input/tax_input_parser'
require_relative '../../lib/domain/item'

RSpec.describe Input::TaxInputParser do
  describe '.parse_line!' do
    context 'with valid input' do
      it 'parses single quantity item correctly' do
        item = Input::TaxInputParser.parse_line!('1 book at 12.49')
        
        expect(item).to be_a(Item)
        expect(item.quantity).to eq(1)
        expect(item.name).to eq('book')
        expect(item.price_cents).to eq(1249)
      end

      it 'parses multiple quantity items correctly' do
        item = Input::TaxInputParser.parse_line!('3 chocolate bar at 0.85')
        
        expect(item.quantity).to eq(3)
        expect(item.name).to eq('chocolate bar')
        expect(item.price_cents).to eq(85)
      end

      it 'parses single-word item names' do
        item = Input::TaxInputParser.parse_line!('1 book at 12.49')
        
        expect(item.name).to eq('book')
      end

      it 'parses multi-word item names' do
        item = Input::TaxInputParser.parse_line!('1 music CD at 14.99')
        
        expect(item.name).to eq('music CD')
      end

      it 'parses complex item names with multiple words' do
        item = Input::TaxInputParser.parse_line!('3 imported boxes of chocolates at 11.25')
        
        expect(item.quantity).to eq(3)
        expect(item.name).to eq('imported boxes of chocolates')
        expect(item.price_cents).to eq(1125)
      end

      it 'handles prices with two decimal places' do
        item = Input::TaxInputParser.parse_line!('1 item at 12.49')
        
        expect(item.price_cents).to eq(1249)
      end

      it 'handles prices ending in .00' do
        item = Input::TaxInputParser.parse_line!('1 item at 10.00')
        
        expect(item.price_cents).to eq(1000)
      end

      it 'handles single digit prices' do
        item = Input::TaxInputParser.parse_line!('1 candy at 5.00')
        
        expect(item.price_cents).to eq(500)
      end

      it 'handles large quantities' do
        item = Input::TaxInputParser.parse_line!('100 books at 12.49')
        
        expect(item.quantity).to eq(100)
      end

      it 'handles very long item names' do
        item = Input::TaxInputParser.parse_line!('1 super deluxe imported bottle of luxury perfume at 99.99')
        
        expect(item.name).to eq('super deluxe imported bottle of luxury perfume')
        expect(item.price_cents).to eq(9999)
      end

      it 'handles item names with numbers' do
        item = Input::TaxInputParser.parse_line!('1 3-pack of batteries at 5.99')
        
        expect(item.name).to eq('3-pack of batteries')
        expect(item.price_cents).to eq(599)
      end

      it 'handles prices with single decimal digit' do
        item = Input::TaxInputParser.parse_line!('1 item at 5.5')
        
        expect(item.price_cents).to eq(55)
      end

      it 'handles prices without decimals' do
        item = Input::TaxInputParser.parse_line!('1 item at 5')
        
        expect(item.price_cents).to eq(5)
      end
    end

    context 'with invalid input' do

      it 'expects value to be zero on invalid integer' do
        expect(Input::TaxInputParser.parse_line!('1 book at twelve').price_cents).to eql(0)
      end

      it 'raises ArgumentError for missing "at" keyword' do
        expect { Input::TaxInputParser.parse_line!('1 book 12.49') }
          .to raise_error(ArgumentError, /Missing 'at' in line/)
      end

      it 'raises ArgumentError for missing price after "at"' do
        expect { Input::TaxInputParser.parse_line!('1 book at') }
          .to raise_error(ArgumentError, /Missing price in line/)
      end

      it 'raises ArgumentError for missing price and at' do
        expect { Input::TaxInputParser.parse_line!('1 book') }
          .to raise_error(ArgumentError, /Missing 'at' in line/)
      end

      it 'raises ArgumentError for non-integer quantity' do
        expect { Input::TaxInputParser.parse_line!('one book at 12.49') }
          .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for decimal quantity' do
        expect { Input::TaxInputParser.parse_line!('1.5 book at 12.49') }
          .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for negative quantity' do
        expect { Input::TaxInputParser.parse_line!('-1 book at 12.49') }
          .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for zero quantity' do
        expect { Input::TaxInputParser.parse_line!('0 book at 12.49') }
          .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for empty line' do
        expect { Input::TaxInputParser.parse_line!('') }
          .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for whitespace only' do
        expect { Input::TaxInputParser.parse_line!('   ') }
          .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for missing quantity' do
        expect { Input::TaxInputParser.parse_line!('book at 12.49') }
          .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for only quantity' do
        expect { Input::TaxInputParser.parse_line!('5') }
          .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for malformed line with only "at"' do
        expect { Input::TaxInputParser.parse_line!('at') }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '.parse!' do
    context 'with valid input lines' do
      it 'parses multiple valid lines correctly' do
        lines = [
          '2 book at 12.49',
          '1 music CD at 14.99',
          '1 chocolate bar at 0.85'
        ]
        
        items = Input::TaxInputParser.parse!(lines)
        
        expect(items).to be_an(Array)
        expect(items.size).to eq(3)
        expect(items).to all(be_a(Item))
        
        expect(items[0].quantity).to eq(2)
        expect(items[0].name).to eq('book')
        expect(items[0].price_cents).to eq(1249)
        
        expect(items[1].quantity).to eq(1)
        expect(items[1].name).to eq('music CD')
        expect(items[1].price_cents).to eq(1499)
        
        expect(items[2].quantity).to eq(1)
        expect(items[2].name).to eq('chocolate bar')
        expect(items[2].price_cents).to eq(85)
      end

      it 'handles empty array' do
        items = Input::TaxInputParser.parse!([])
        
        expect(items).to eq([])
      end

      it 'preserves order of items' do
        lines = [
          '1 first item at 10.00',
          '2 second item at 20.00',
          '3 third item at 30.00'
        ]
        
        items = Input::TaxInputParser.parse!(lines)
        
        expect(items[0].name).to eq('first item')
        expect(items[1].name).to eq('second item')
        expect(items[2].name).to eq('third item')
      end

      it 'parses all example inputs correctly' do
        # Example 1
        lines1 = [
          '2 book at 12.49',
          '1 music CD at 14.99',
          '1 chocolate bar at 0.85'
        ]
        
        items1 = Input::TaxInputParser.parse!(lines1)
        expect(items1.size).to eq(3)
        
        # Example 2
        lines2 = [
          '1 imported box of chocolates at 10.00',
          '1 imported bottle of perfume at 47.50'
        ]
        
        items2 = Input::TaxInputParser.parse!(lines2)
        expect(items2.size).to eq(2)
        expect(items2[0].name).to include('imported')
        expect(items2[1].name).to include('imported')
        
        # Example 3
        lines3 = [
          '1 imported bottle of perfume at 27.99',
          '1 bottle of perfume at 18.99',
          '1 packet of headache pills at 9.75',
          '3 imported boxes of chocolates at 11.25'
        ]
        
        items3 = Input::TaxInputParser.parse!(lines3)
        expect(items3.size).to eq(4)
        expect(items3[3].quantity).to eq(3)
      end
    end

    context 'with invalid input lines' do
      it 'provides line number in error message for first line' do
        lines = [
          'invalid line',
          '1 book at 12.49'
        ]
        
        expect { Input::TaxInputParser.parse!(lines) }
          .to raise_error(ArgumentError, /Invalid input file at line 1/)
      end

      it 'provides line number in error message for middle line' do
        lines = [
          '1 book at 12.49',
          'invalid line',
          '1 chocolate at 0.85'
        ]
        
        expect { Input::TaxInputParser.parse!(lines) }
          .to raise_error(ArgumentError, /Invalid input file at line 2/)
      end

      it 'provides line number in error message for last line' do
        lines = [
          '1 book at 12.49',
          '1 chocolate at 0.85',
          'invalid line'
        ]
        
        expect { Input::TaxInputParser.parse!(lines) }
          .to raise_error(ArgumentError, /Invalid input file at line 3/)
      end

      it 'includes the problematic line in error message' do
        lines = [
          '1 book at 12.49',
          'this is invalid',
          '1 chocolate at 0.85'
        ]
        
        expect { Input::TaxInputParser.parse!(lines) }
          .to raise_error(ArgumentError, /Line: "this is invalid"/)
      end

      it 'provides detailed error for missing at' do
        lines = [
          '1 book at 12.49',
          '1 chocolate 0.85'
        ]
        
        expect { Input::TaxInputParser.parse!(lines) }
          .to raise_error(ArgumentError) do |error|
            expect(error.message).to include('line 2')
            expect(error.message).to include('Missing \'at\'')
          end
      end

      it 'provides detailed error for invalid quantity' do
        lines = [
          '1 book at 12.49',
          'two chocolates at 0.85'
        ]
        
        expect { Input::TaxInputParser.parse!(lines) }
          .to raise_error(ArgumentError) do |error|
            expect(error.message).to include('line 2')
          end
      end

      it 'handles mixed valid and invalid lines correctly' do
        lines = [
          '1 valid item at 10.00',
          '2 another valid at 20.00',
          'this line is broken',
          '3 would be valid at 30.00'
        ]
        
        expect { Input::TaxInputParser.parse!(lines) }
          .to raise_error(ArgumentError, /Invalid input file at line 3/)
      end
    end
  end
end