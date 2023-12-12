# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Unitify()

Unitify the table by parsing the unit in the columns names
and applying them. The unit name must be enclosed in square
brackets in the column name, e.g. "colname [m/s]".
"""
struct Unitify <: StatelessFeatureTransform end

isrevertible(::Type{Unitify}) = true

function _unitify(name)
  m = match(r"(.*)\[(.*)\]", string(name))
  if !isnothing(m)
    namestr, unitstr = m.captures
    newname = Symbol(strip(namestr))
    unit = try
      uparse(unitstr)
    catch
      @warn "the unit \"$unitstr\" is not valid"
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
