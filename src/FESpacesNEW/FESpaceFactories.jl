
function FESpace(
  model::DiscreteModel,
  cell_fe::CellFE;
  conformity=nothing,
  labels = get_face_labeling(model),
  dirichlet_tags=Int[],
  dirichlet_masks=nothing,
  constraint=nothing,
  vectortype::Union{Nothing,Type}=nothing)

  @assert num_cells(cell_fe) == num_cells(model) """\n
  The number of cells provided in the `cell_fe` argument ($(cell_fe.num_cells) cells)
  does not match the number of cells ($(num_cells(model)) cells) in the provided DiscreteModel.
  """

  trian = Triangulation(model)

  if vectortype == nothing
    cell_shapefuns, cell_dof_basis = compute_cell_space(cell_fe,trian)
    T = get_dof_value_type(cell_shapefuns,cell_dof_basis)
    _vector_type = Vector{T}
  else
    @assert vectortype <: AbstractVector """\n
    The (optional) argument vectortype has to be <: AbstractVector.
    """
    _vector_type = vectortype
  end

  if conformity in (L2Conformity(),:L2) && dirichlet_tags == Int[]
    F = _DiscontinuousFESpace(_vector_type,trian,cell_fe)
  else
    cell_conformity = CellConformity(cell_fe,conformity)
    F = _ConformingFESpace(
      _vector_type,
      model,
      labels,
      cell_fe,
      cell_conformity,
      dirichlet_tags,
      dirichlet_masks)
  end

  if constraint == nothing
    V = F
  elseif constraint == :zeromean
    dΩ = LebesgueMeasure(trian,cell_fe.max_order)
    V = ZeroMeanFESpace(F,dΩ)
  else
    @unreachable """\n
    The passed option constraint=$constraint is not valid.
    Valid values for constraint: nothing, :zeromean
    """
  end

  V
end

function FESpace(
  model::RestrictedDiscreteModel, cell_fe::CellFE; kwargs...)
  model_portion = model.model
  V_portion = FESpace(model_portion,cell_fe;kwargs...)
  ExtendedFESpace(V_portion,model)
end

function FESpace(
  model::DiscreteModel,
  cell_reffe::AbstractArray{<:ReferenceFE};
  conformity=nothing,
  kwargs...)
  trian = Triangulation(model)
  cell_map = get_cell_map(trian)
  if conformity==nothing
    cell_conformity = nothing
  else
    cell_conformity = CellConformity(cell_reffe,conformity)
  end
  cell_fe = CellFE(cell_map,cell_reffe)
  FESpace(model,cell_fe;conformity=cell_conformity,kwargs...)
end


function FESpace(model::DiscreteModel, reffe::Tuple{Symbol,Any,Any}; kwargs...)
  basis, reffe_args,reffe_kwargs = reffe
  cell_reffe = ReferenceFE(model,basis,reffe_args...;reffe_kwargs...)
  FESpace(model,cell_reffe;kwargs...)
end

function FESpace(model::DiscreteModel, reffe::ReferenceFE; kwargs...)
  cell_reffe = Fill(reffe,num_cells(model))
  FESpace(model,cell_reffe;kwargs...)
end

"""
"""
function TestFESpace(args...;kwargs...)
  FESpace(args...;kwargs...)
end
