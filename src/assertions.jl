# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

abstract type Assertion end

"""
    SciTypeAssertion{T}(colspec)

Asserts that the columns in the `colspec` have a scientific type `T`.
"""
struct SciTypeAssertion{T,S<:ColSpec} <: Assertion
  colspec::S

  function SciTypeAssertion{T}(colspec::S) where {T,S}
    new{T,S}(colspec)
  end
end

function (assertion::SciTypeAssertion{T})(table) where {T}
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(assertion.colspec, names)
  for name in snames
    coltype = Tables.columntype(table, name)
    @assert scitype(coltype) <: T
  end
end

# assert that all columns of table are Continuous
function assert_continuous(table)
  types = schema(table).scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"
end

# assert that column is categorical
function assert_categorical(x)
  @assert elscitype(x) <: Finite "The selected column must be categorical."
end
