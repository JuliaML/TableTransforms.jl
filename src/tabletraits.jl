# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    features, metadata = split(table)

Divide the `table` into a table with `features` and
a `metadata` object, e.g. geospatial domain.
"""
divide(table) = table, nothing

"""
    table = combine(features, metadata)

Combine a table with `features` and a `metadata`
object into a special type of `table`.
"""
attach(features, ::Nothing) = features