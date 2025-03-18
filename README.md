# Select Tabset Extension For Quarto

This extension provides support for tabsets which are controlled with a `<select />` element.
Such control can be useful for tabsets with many tabs.

This extension is based on quarto's natively supported tabsets.
It is for now only working for `html` output.

## Installing

```bash
quarto add jakoblistabarth/quarto-select-tabset
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

To create a tabset use the `.select-tabset` class in a block, like so:

```qmd
::: {.panel-select}

## Tab 1

Content tab 1

## Tab 2

Content tab 2
:::
```

Additionally, a custom label for the select can be defined via a `option-label` data attribute:

```qmd
::: {.panel-select option-label="Select a city …"}
…
:::
```

## Odd behaviour
When adding code after the last `panel-select` class, the `qmd` will not compile.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).
