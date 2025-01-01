
Base.show(io::IO, ::MIME"text/plain", pattern::Pattern{Nothing,Nothing}) =
  print(io, pattern)


function Base.print(io::IO, pattern::Pattern{F,P}) where {F,P}
  println(io, "Junctions:")
  print_dtry(io, pattern.junctions; print_value=print_junction)
  println(io, "\nBoxes:")
  print_dtry(io, pattern.boxes; print_value=print_box)
end


function print_junction(io::IO, junction::Junction, _::String)
  print(io,
    "(" *
    string(junction.quantity.quantity) *
    ", " *
    string(junction.quantity.space) *
    ")"
  )
  if junction.exposed
    if junction.power
      print(io, ", power")
    else
      print(io, ", state")
    end
  end
end


function print_box(io::IO, box::InnerBox, prefix::String)
  if !isnothing(box.filling)
    println(io, typeof(box.filling))
    print(io, prefix)
  end
  print_dtry(io, box.ports; print_value=print_port, prefix)
end


function print_port(io::IO, port::InnerPort, _::String)
  print(io, port.junction)
  if port.power
    print(io, ", power")
  else
    print(io, ", state")
  end
end
