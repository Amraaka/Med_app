# Changelog

All notable changes to the Pediatric Dose Calculator package will be documented in this file.

## [1.0.0] - 2024-12-08

### Added
- Initial release of pediatric dose calculator package
- `PediatricDoseCalculator` class with Young's Rule implementation
- `AdvancedPediatricDoseCalculator` class with multiple calculation methods:
  - Young's Rule (age-based)
  - Clark's Rule (weight-based)
  - Fried's Rule (infants under 2 years)
  - BSA Method (Body Surface Area - most accurate)
- Dose string parsing with support for multiple units (mg, g, ml, mcg)
- Support for Mongolian and English unit formats
- Age-specific warnings for infants and young children
- Comprehensive test suite
- Usage examples

### Features
- Automatic method selection based on available patient data
- Multi-language support (Mongolian/English)
- Safety warnings for different age groups
- Clinical recommendations based on calculation results
- Flexible dose string parsing
