# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Unitify()

Add units to columns of the table using bracket syntax.
A column named `col [unit]` will be renamed to a unitful
column `col` with a valid `unit` from Unitful.jl.

In the case that the `unit` is not recognized by Unitful.jl, 
no units are added. Empty brackets are also allowed to represent
columns without units, e.g. `col []`.
"""
struct Unitify <: StatelessFeatureTransform end

isrevertible(::Type{Unitify}) = true

function _unitify(name)
  m = match(r"(.*)\[(.*)\]", string(name))
  if !isnothing(m)
    namestr, unitstr = m.captures
    newname = Symbol(strip(namestr))
    unit = if !isempty(unitstr)
      try
        uparse(unitstr)
      catch
        @warn "The unit \"$unitstr\" is not valid"
        NoUnits
      end
    else
      NoUnits
    end
    newname, unit
  else
    name, NoUnits
  end
end

function applyfeat(::Unitify, feat, prep)
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)

  pairs = map(names) do name
    x = Tables.getcolumn(cols, name)
    newname, unit = _unitify(name)
    newname => x * unit
  end

  newfeat = (; pairs...) |> Tables.materializer(feat)
  newfeat, names
end

function revertfeat(::Unitify, newfeat, fcache)
  cols = Tables.columns(newfeat)
  names = Tables.columnnames(cols)

  onames = fcache
  ocolumns = map(names) do name
    x = Tables.getcolumn(cols, name)
    ustrip.(x)
  end

  𝒯 = (; zip(onames, ocolumns)...)
  𝒯 |> Tables.materializer(newfeat)
end
