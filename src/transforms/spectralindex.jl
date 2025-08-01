# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SpectralIndex(name, [bands...])

Compute the spectral index of given `name` from SpectralIndices.jl.
Optionally, specify the column names corresponding to spectral `bands`
as keyword arguments.

## Examples

```julia
# vegetation index
SpectralIndex("NDVI")

# water index
SpectralIndex("NDWI")

# specify R (red) and N (near infra red) columns
SpectralIndex("NDVI", R="col1", N="col4")
```

### Notes

The list of supported indices can be obtained with `spectralindices()`
and the list of spectral bands for a given index can be obtained with
`spectralbands(name)`.
"""
struct SpectralIndex{B} <: StatelessFeatureTransform
  name::String
  bands::B

  function SpectralIndex(name, bands)
    sname = string(name)
    _assert(sname ∈ keys(indices), "$sname not found in SpectralIndices.jl")
    sbands = if isempty(bands)
      nothing
    else
      skeys = string.(keys(bands))
      vkeys = Tuple(indices[sname].bands)
      _assert(skeys ⊆ vkeys, "bands $skeys are not valid for spectral index $sname, please choose from $vkeys")
      svals = string.(values(values(bands)))
      (; zip(Symbol.(skeys), svals)...)
    end
    new{typeof(sbands)}(sname, sbands)
  end
end

SpectralIndex(name; bands...) = SpectralIndex(name, bands)

function applyfeat(transform::SpectralIndex, feat, prep)
  # retrieve spectral index
  iname = transform.name
  index = indices[iname]

  # extract band names from feature table
  cols = Tables.columns(feat)
  names = Tables.columnnames(cols)
  bnames = Symbol.(index.bands)
  tbands = transform.bands
  snames = map(bnames) do b
    if !isnothing(tbands) && b ∈ keys(tbands)
      Symbol(tbands[b])
    else
      b
    end
  end

  # throw helpful error message in case of invalid names
  if !(snames ⊆ names)
    notfound = setdiff(snames, names)
    required = ["$(b.short_name): $(b.long_name)" for b in spectralbands(iname)]
    pprint(names) = "\"" * join(string.(names), "\", \"", "\" and \"") * "\""
    throw(ArgumentError("""columns $(pprint(notfound)) not found in table.

      Please specify valid columns names for the spectral bands as keyword arguments.

      Required bands for $iname:

        $(join(required, "\n    "))

      Available column names: $(pprint(names))
    """))
  end

  # compute index for all locations
  icols = [b => Tables.getcolumn(cols, n) for (b, n) in zip(bnames, snames)]
  ivals = compute(index; icols...)

  # new table with index feature
  newfeat = (; Symbol(iname) => ivals) |> Tables.materializer(feat)

  newfeat, nothing
end

"""
    spectralindices()

List of spectral indices supported by SpectralIndices.jl.
"""
spectralindices() = indices

"""
    spectralbands(name)

List of spectral bands for spectral index of given `name`.
"""
spectralbands(name) = [bands[b] for b in indices[name].bands]
