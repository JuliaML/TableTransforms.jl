# meta tables
abstract type Metadata end

struct VarMeta <: Metadata
  data::Vector{Int}
end

struct ConstMeta <: Metadata
  data::Vector{Int}
end

Base.:(==)(a::Metadata, b::Metadata) = a.data == b.data

struct MetaTable{T,M<:Metadata}
  table::T
  meta::M
end

Base.:(==)(a::MetaTable, b::MetaTable) =
  a.table == b.table && a.meta == b.meta

TT.divide(metatable::MetaTable) = metatable.table, metatable.meta
TT.attach(feat, meta::Metadata) = MetaTable(feat, meta)

function TT.applymeta(::TT.TableTransform, meta::VarMeta, prep)
  VarMeta(meta.data .+ 2), nothing
end

function TT.revertmeta(::TT.TableTransform, newmeta::VarMeta, mcache)
  VarMeta(newmeta.data .- 2)
end

TT.applymeta(::TT.TableTransform, meta::ConstMeta, prep) = meta, nothing
TT.revertmeta(::TT.TableTransform, newmeta::ConstMeta, mcache) = newmeta
