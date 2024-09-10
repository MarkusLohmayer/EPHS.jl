
# """
#     ocompose(pattern::Pattern, rs::Dtry{Rhizome})

# Composition operation for the Dtry-multicategory of rhizomes.
# """
# function compose(r::Pattern{F,P}, rs::Dtry{Pattern{}}) where {F,P}
#   # paired :: Dtry{Tuple{Dtry{InnerPort}, Rhizome}}
#   paired = zip(r.boxes, rs)
#   boxes = flatten(mapwithkey(Dtry{Dtry{InnerPort}}, paired) do k, (interface, r′)
#     # k :: DtryVar
#     # interface :: Dtry{InnerPort}
#     # r′ :: Rhizome
#     # We want to create the new collection of boxes

#     # Map nested boxes
#     map(Dtry{InnerPort}, r′.boxes) do b
#       # b :: Dtry{InnerPort}
#       map(InnerPort, b) do p
#         # p :: InnerPort
#         # p.junction :: namespace(b.junctions)
#         jvar = p.junction
#         j = r′.junctions[jvar]
#         if j.exposed == true
#           # If exposed, then use the junction that the port is connected to
#           InnerPort(p.type, interface[jvar].junction)
#         else
#           # Otherwise, attach to a newly added junction from the rhizome `r′`
#           # which is attached at path `k`
#           InnerPort(p.type, k * jvar)
#         end
#       end
#     end
#   end)
#   # Add all unexposed junctions
#   newjunctions = flatten(
#     map(Dtry{Junction}, rs) do r′
#       internal_junctions = filter(j -> !j.exposed, r′.junctions)
#       if isnothing(internal_junctions)
#         Dtrys.node(OrderedDict{Symbol,Dtry{Junction}}())
#       else
#         internal_junctions
#       end
#     end
#   )

#   junctions = merge(r.junctions, newjunctions)

#   Rhizome(boxes, junctions)
# end
