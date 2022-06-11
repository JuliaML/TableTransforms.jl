# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

# assert that all columns of table are Continuous
function assert_continuous(table)
  types = schema(table).scitypes
  @assert all(T <: Continuous for T in types) "columns must hold continuous variables"
end

# assert that column is categorical
function assert_categorical(x)
  T = elscitype(x)
  @assert T <: Finite "The selected column must be cetegorical."
end
