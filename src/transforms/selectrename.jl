# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SelectRename(col₁ => newcol₁, col₂ => newcol₂, ..., colₙ => newcolₙ)

The transform that selects columns `col₁`, `col₂`, ..., `colₙ`
and rename them to `newcol₁`, `newcol₂`, ..., `newcolₙ`.

The SelectRename transform is a shortcut for
`Select(col) → Rename(col => newcol)`.

See also: [`Select`](@ref), [`Rename`](@ref).

# Examples

```julia
SelectRename(:a => :x, :c => :y)
SelectRename("a" => "x", "c" => "y")
```
"""
SelectRename(pairs::Pair{Symbol,Symbol}...) = Select(first.(pairs)) → Rename(pairs...)
SelectRename(pairs::Pair...) = SelectRename(_pairsyms.(pairs)...)
