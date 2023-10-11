# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SciTypeAssertion{T}(selector = AllSelector())

Asserts that the elements of the columns in the `selector` have a scientific type `T`.
"""
struct SciTypeAssertion{T<:SciType,S<:ColumnSelector}
  selector::S
end

SciTypeAssertion{T}(selector::S) where {T,S<:ColumnSelector} = SciTypeAssertion{T,S}(selector)

SciTypeAssertion{T}() where {T} = SciTypeAssertion{T}(AllSelector())

function (assertion::SciTypeAssertion{T})(table) where {T}
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = assertion.selector(names)

  for nm in snames
    x = Tables.getcolumn(cols, nm)
    @assert elscitype(x) <: T "the elements of the column '$nm' are not of scientific type $T"
  end
end

"""
    ColumnTypeAssertion{T}(selector = AllSelector())

Asserts that the columns in the `selector` have a type `T`.
"""
struct ColumnTypeAssertion{T,S<:ColumnSelector}
  selector::S
end

ColumnTypeAssertion{T}(selector::S) where {T,S<:ColumnSelector} = ColumnTypeAssertion{T,S}(selector)

ColumnTypeAssertion{T}() where {T} = ColumnTypeAssertion{T}(AllSelector())

function (assertion::ColumnTypeAssertion{T})(table) where {T}
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = assertion.selector(names)

  for nm in snames
    x = Tables.getcolumn(cols, nm)
    @assert typeof(x) <: T "the column '$nm' is not of type $T"
  end
end
