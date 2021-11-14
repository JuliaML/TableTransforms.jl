# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

""" 
    Rename(Dict(:col₁ => :newcol₁, :col₂ => :newcol₂, ..., :col₁ => :newcolₙ))

Tha transform that renames `col₁` to `newcol₁`, `col₂` to `newcol₂`, ...
""" 
struct Rename3 <: Stateless
    names::Dict{Symbol,Symbol}
end

function apply(transform::Rename3, table)
    new_table = (;)

    for col_name in Tables.columnnames(table)
        col_value = Tables.getcolumn(table, col_name)

        # if the current name is to be changed, retrive the new name
        #and push a col with it, else push the col with the old name
        if col_name in keys(transform.names)
            new_name = transform.names[col_name]
            new_table = push!!(new_table, new_name => col_value)
        else
            new_table = push!!(new_table, col_name => col_value)
        end
    end

    𝒯  = table |> Tables.materializer(table)
    𝒯, nothing
end

function revert(transform::Rename3, table)
    # reversing the key-value pairs
    new_names = Dict()
    for (new, old) in transform.names
        new_names[old] = new
    end
    # normal apply operation, but on a revered Dict 
    reversed_transform = Rename3(new_names)
    apply(reversed_transform, table) |> first
end
