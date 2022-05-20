using Tables
using CategoricalArrays
#using Parameters
import Base.@kwdef


#-----todo the things that I should work on is the constructor
"""
Return a copy of the table with specified levels for categorical columns
x = (;a = categorical(repeat(["yes"], 5)), b = categorical([1,2,4,2,8],ordered=false), c =categorical([1,2,1,2,1]))
#allowing only changing the order of the column 
Levels(:a => ["yes,"no"], :c => [1,2,4], :d = ["a","b","c"], ordered = [:a,:c,:b])
# no ready for this: https://github.com/JuliaData/CategoricalArrays.jl/issues/294
"""
@kwdef struct Levels{K} <: Stateless
    levelspec::K
    ordered::AbstractVector{Symbol}; #@assert all(in.(ordered,Ref(levelspec))) 
end

Levels(pairs::Pair{K}...; ordered::AbstractVector{K}) where {K <: Symbol}=
    Levels(NamedTuple(pairs), ordered)

Levels(pairs::Pair{K}...; ordered::AbstractVector{K}) where {K <: AbstractString} =
    Levels(NamedTuple(Symbol(k) => v for (k,v) in pairs), Symbol.(ordered))

Levels(pairs::Pair{K}...) where {K <: Symbol} =
    Levels(NamedTuple(pairs),Symbol[])

Levels(pairs::Pair{K}...) where {K <: AbstractString} =
    Levels(NamedTuple(Symbol(k) => v for (k,v) in pairs),Symbol[])



isrevertible(transform::Levels) = true
# handle three cases
#1. when the col is already a categorical array and wanna change levels and order
categorify(func::AbstractVector, x::CategoricalVector,ordered::Bool) = levels(x) , categorical(x,levels = func,ordered=ordered) 
#2. when the col is normal array and want to change to categorical array
categorify(func::AbstractVector, x::AbstractVector,ordered::Bool) = Array , categorical(x,levels = func,ordered=ordered) 
#3. when the col is not need for change 
categorify(func::Base.Callable, x::AbstractVector,ordered::Bool) = ordered ? (levels(x), categorical(x, ordered=true)) : (func , func(x))


function apply(transform::Levels,table)
    cols = Tables.columns(table)
    names = Tables.columnnames(cols)
    levels = transform.levelspec
    caches = []
    ncols = map(names) do nm
        x = Tables.getcolumn(cols, nm)
        cat_level = get(levels, nm, identity)
        ordered = in(nm,transform.ordered)
        cache, new_x = categorify(cat_level, x,ordered)
        push!(caches, cache)
        new_x
    end
    
    𝒯 = (; zip(names, ncols)...)
    newtable = 𝒯 |> Tables.materializer(table)
    
    return newtable, caches
end

function revert(transform::Levels, newtable, caches)
    @assert isrevertible(transform)

    cols = Tables.columns(newtable)
    names = Tables.columnnames(cols)

    ocols = map(zip(caches, names)) do (func, nm)
        x = Tables.getcolumn(cols, nm)
        #ordered = in(nm, transform.ordered) ## no work for identity func 
        last(categorify(func,x,false))
        #func == identity ? categorify(func,x,false) : categorify(func,x,false)
    end
    
    𝒯 = (; zip(names, ocols)...)
    𝒯 |> Tables.materializer(newtable)
end



x = (;a = categorical(repeat(["yes"], 5)), b = categorical([1,2,4,2,8],ordered=false), c =categorical([1,2,1,2,1]), d= [1,23,5,7,7])

#test 1
#begin 
#    func1 = Levels(:a => ["yes","no"], :c => [1,2,4],ordered= [:a,:c])
#    func2 = Levels("a" => ["yes","no"], "c" => [1,2,4],ordered= ["a","c"])
#
#    new_x1,cache1 = apply(func1, x)
#    ori_x1 = revert(func1,new_x1,cache1)
#    new_x1,cache1 = apply(func2, x)
#    ori_x1 = revert(func2,new_x1,cache1)
#
#    @show levels(new_x1.a) 
#    @show levels(new_x1.b)
#    @show isordered(new_x1.a)
#    @show levels(ori_x1.a)
#    @show levels(ori_x1.b)
#    @show isordered(ori_x1.a)
#end
#
#begin
#    func3 = Levels(:a => ["yes","no"], :c => [1,2,4])
#    new_x2, cache2 = apply(func3, x)
#    ori_x2 = revert(func3,new_x2,cache2)
#    @show levels(new_x2.a)
#    @show isordered(new_x2.a)
#
#    @show levels(ori_x2.a)
#    @show isordered(ori_x2.a)
#    @show Tables.columntable(new_x2)
#    #@show Tables.columntable(ori_x3)
#end
#
#begin 
#    func4 = Levels(:a => ["yes","no"], :c => [1,2,4], :d => [1,23,5,7] ,ordered = [:a,:b,:c])
#    new_x3, cache3 = apply(func4, x)
#    ori_x3 = revert(func4,new_x3,cache3)
#    @show cache3
#    @show levels(new_x3.b)
#    @show isordered(new_x3.b)
#    @show levels(ori_x3.b)
#    @show isordered(ori_x3.b)
#    @show Tables.columntable(new_x3)
#    @show Tables.columntable(ori_x3)
#end