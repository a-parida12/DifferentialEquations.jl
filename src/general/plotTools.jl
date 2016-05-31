#plot(z, zlim = (should_override ? zlim_override : default(:zlim)))

"""
animate(res::FEMSolution)

Plots an animation of the solution. Requires `fullSave=true` was enabled in the solver.

### Keyword Arguments

* `zlim`: The limits on the z-axis in the simulation. Default nothing.
* `cbar`: Boolean flag which turns on/off the color bar. Default true.
"""
function animate(res::FEMSolution;zlim=nothing,cbar=true)
  Plots.pyplot(reuse=true,size=(750,750))
  if zlim==nothing
    @gif for i=1:size(res.uFull,2)
        surface(res.femMesh.node[:,1],res.femMesh.node[:,2],res.uFull[:,i],cbar=cbar)
    end
  else
    @gif for i=1:size(res.uFull,2)
        surface(res.femMesh.node[:,1],res.femMesh.node[:,2],res.uFull[:,i],zlim=zlim,cbar=cbar)
    end
  end
end

@recipe function f(sol::FEMSolution;plottrue=false)
  plottrue = pop!(d,:plottrue)
  u = Any[]
  for i = 1:size(sol.u,2)
    push!(u,sol.u[:,i])
  end
  if plottrue
    for i = 1:size(sol.u,2)
      push!(u,sol.uTrue[:,i])
    end
  end
  #println(length(u))
  seriestype --> :surface
  layout --> length(u)
  sol.femMesh.node[:,1], sol.femMesh.node[:,2], u
end

#=
@recipe function f(sims1::ConvergenceSimulation,sims_tail::ConvergenceSimulation...)
  u = Any[sims1]
  [push!(u,sim) for sim in sims_tail] #u is a vector of all the sims
  vals = [[x for x in values(sim.errors)] for sim in u] #vals[i] is the vector of vectors
                                                        #'for plot i
  layout --> length(u)
  seriestype --> :path
  label  --> [key for key in keys(sims1.errors)]'
  xguide  --> "Convergence Axis"
  yguide  --> "Error"
  xscale --> :log10
  yscale --> :log10
  sims1.convergenceAxis, vals
end
=#

@recipe function f(sol::SDESolution;plottrue=false)
  if ndims(sol.uFull) > 2
    totaldims = 1
    for i=2:ndims(sol.uFull)
      totaldims *= size(sol.uFull,i)
    end
    #println(totaldims)
    vals = reshape(sol.uFull,size(sol.uFull,1),totaldims)
  else
    vals = sol.uFull
  end
  if plottrue
    if ndims(sol.solFull) > 2
      totaldims = 1
      for i=2:ndims(sol.uFull)
        totaldims *= size(sol.solFull,i)
      end
      vals = [vals reshape(sol.solFull,size(sol.solFull,1),totaldims)]
    else
      vals = [vals sol.solFull]
    end
  end
  plottrue = pop!(d,:plottrue)
  #u = Any[sol.uFull];
  #plottrue && push!(u, sol.solFull);
  seriestype --> :path
  #layout --> length(u)
  sol.tFull, vals
end

@recipe function f(sim::ConvergenceSimulation)
  if ndims(collect(values(sim.errors))[1])>1 #Monte Carlo
    vals = [mean(x,1) for x in values(sim.errors)]'
  else #Deterministic
    vals = [x for x in values(sim.errors)]
  end
  seriestype --> :path
  label  --> [key for key in keys(sim.errors)]'
  xguide  --> "Convergence Axis"
  yguide  --> "Error"
  xscale --> :log10
  yscale --> :log10
  sim.convergenceAxis, vals
end


@recipe function f(mesh::Mesh)
  seriestype --> :surface #:plot_trisurf
  #triangles  --> mesh.elem-1
  mesh.node[:,1], mesh.node[:,2], ones(mesh.node[:,1])
end

# mesh = meshExample_lakemesh()
# PyPlot.plot_trisurf(mesh.node[:,1],mesh.node[:,2],ones(mesh.node[:,2]),triangles=mesh.elem-1)
