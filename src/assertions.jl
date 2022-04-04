# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# assert that all columns of table are Continuous
function assert_continuous(table)
  types = schema(table).scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"
end

function assert_continuous_or_missing(table)
  types = schema(table).scitypes
  @assert all(T <: Union{Missing, Continuous} for T in types) "columns must hold continuous variables"
end
