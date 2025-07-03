# rround: Random rounding to base 3 for Stata

`rround` is a Stata command that randomly rounds numeric values up or down to the nearest multiple of 3. Useful for producing rounded, anonymised counts when reporting statistics derived from microdata.

## Features

- Random rounding with 2/3 probability to the nearest multiple of 3, and 1/3 to the second nearest. Values already divisible by 3 remain unchanged.
- Generates new variables with the `_rr` suffix for each input variable.
- Supports consistent rounding across variables and sessions using:
  - `harmonize` option 
  - `using` option with a saved file for persistent rounding behaviour.

## Installation

To install the `rround` command in Stata, run:

```stata
net install rround, from("https://raw.githubusercontent.com/thomasschober/rround/main/")

