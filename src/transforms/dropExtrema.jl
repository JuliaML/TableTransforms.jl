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
    
"""
function drop_extrema(df::DataFrame, column_name::Symbol, low::Float64, high::Float64)
    a = quantile(df[!, column_name], low)
    b = quantile(df[!, column_name], high)
    
    filtered_df = filter(row -> a <= row[!, column_name] <= b, df)
    
    return filtered_df
end