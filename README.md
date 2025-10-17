# 🧾 Overview

A clean, object-oriented Ruby application for the **Sales Tax problem**, emphasizing separation of concerns and precision using **integer cents**.

## 📋 Requirements
- Ruby 3.4.7
- Bunlder 2.6.9

## ▶️ Running

```bash
ruby main.rb input/example0.txt
```

## 🧪 Testing

Install rspec first with:
```bash
bundle install
```

Then run:
```bash
rspec
```

---

## 💡 Design Decisions

### Cents-Based Arithmetic
Uses integer cents (1249 = $12.49) to avoid floating-point precision errors common in financial calculations.

### Thread-Safe by Design
- **Stateless modules** with no shared mutable state
- **Pure functions** - same input always produces same output
- Safe for concurrent threads without synchronization

### Separation of Concerns
- **`ReceiptOperator`** - Business logic (tax calculations, totals)
- **`ReceiptPrinter`** - Presentation layer (formatting, output)
- **`StandardTaxCalculator`** - Tax rules encapsulation (rates, rounding)
- **`TaxInputParser`** - Input parsing and validation

Each module has a single, well-defined responsibility.

---

## 🔍 Possible Enhancements

- Add structured logging for business metrics (revenue, exempt items, import tracking)
- Implement stricter input validation with detailed error messages
- Add support for multiple tax jurisdictions

## 📤 Example Output

**Input:**
```
1 book at 12.49
1 music CD at 14.99
1 chocolate bar at 0.85
```

**Output:**
```
1 book: 12.49
1 music CD: 16.49
1 chocolate bar: 0.85
Sales Taxes: 1.50
Total: 29.83
```
