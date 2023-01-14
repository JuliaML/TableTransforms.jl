# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

#############
# INTERFACE #
#############

"""
    check(assertion, table)

Check if `table` satifies the `assertion`.
"""
function check end

##############
# ASSERTIONS #
##############

"""
    SciTypeAssertion{T}(colspec = AllSpec())

Asserts that the columns in the `colspec` have a scientific type `T`.
"""
struct SciTypeAssertion{T,S<:ColSpec}
  colspec::S
end

SciTypeAssertion{T}(colspec::S) where {T,S<:ColSpec} = 
  SciTypeAssertion{T,S}(colspec)

SciTypeAssertion{T}() where {T} = SciTypeAssertion{T}(AllSpec())

function check(assertion::SciTypeAssertion{T}, table) where {T}
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  snames = choose(assertion.colspec, names)

  for nm in snames
    x = Tables.getcolumn(cols, nm)
    @assert elscitype(x) <: T "The column '$nm' is not of scitype $T"
  end
end
