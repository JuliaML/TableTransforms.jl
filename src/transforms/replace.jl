# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

struct Replace{K,V} <: Colwise
  oldnew::Dict{K,V}
end

Replace() = throw(ArgumentError("Cannot create a Replace object without arguments."))

Replace(oldnew::Pair...) = Replace(Dict(oldnew))

isrevertible(::Type{<:Replace}) = true

function colcache(transform::Replace, x)
  olds = collect(keys(transform.oldnew))
  Dict(old => findall(isequal(old), x) for old in olds)
end

colapply(transform::Replace, x, c) = 
  replace!(copy(x), transform.oldnew...)

function colrevert(::Replace, x, c)
  allinds = vcat(values(c)...)
  map(1:length(x)) do i
    if i ∈ allinds
      for (old, inds) in c
        i ∈ inds && return old
      end
    end
    return x[i]
  end
end
