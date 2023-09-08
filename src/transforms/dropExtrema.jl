# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    DropExtrema(low, high)
    
Applies the DropExtrema transform to remove rows with values outside the interval [low, high].
The DropExtrema transform drops extreme values in both lower and upper tails.
    
    DropExtrema(col, low, high)
    
Applies the DropExtrema transform to the specified column `col` with interval [low, high].
    
# Examples
```julia
DropExtrema(0.01, 0.99)
DropExtrema(:column_name, 1.0, 10.0)
```
"""
struct DropExtrema{T<:Real} <: TransformsBase.Transform
    low::T
    high::T
    col::Symbol
end

DropExtrema(low::Real, high::Real) = DropExtrema(low, high, :)
DropExtrema(col::Symbol, low::Real, high::Real) = DropExtrema(low, high, col)

function TransformsBase.apply(transform::DropExtrema, X)
    a = quantile(X[!, transform.col], transform.low)
    b = quantile(X[!, transform.col], transform.high)
    filtered_rows = filter(row -> a <= row[!, transform.col] <= b, 1:nrow(X))
    return X[filtered_rows, :], nothing
end