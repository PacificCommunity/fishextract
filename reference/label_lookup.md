# Look up display labels for known ACE grouping columns

Internal helper returning a named lookup vector for columns with
package-defined display names, or `NULL` if `var_name` has no lookup (in
which case callers should fall back to default labelling).

## Usage

``` r
label_lookup(var_name, abbreviate_flags = FALSE)
```

## Arguments

- var_name:

  String. Column name, e.g. `"GEAR_CODE"`.

- abbreviate_flags:

  Logical. Abbreviates the flag names (useful for plotting purposes).

## Value

A named character vector, or `NULL`.
