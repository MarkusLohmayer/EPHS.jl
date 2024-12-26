
function Base.show(io::IO, ::MIME"text/plain", pattern::Pattern{Nothing,Nothing})
  println(io, "Junctions:")
  print_dtry(io, pattern.junctions; print_value=print_junction)
  println(io, "\nBoxes:")
  print_dtry(io, pattern.boxes; print_value=print_box)
end


function print_junction(io::IO, t::Tuple{Junction,Nothing}, _::String)
  junction, _ = t
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


function print_box(io::IO, t::Tuple{InnerBox{Nothing},Nothing}, prefix::String)
  box, _ = t
  print_dtry(io, box.ports; prefix, print_value=print_port)
end


function print_port(io::IO, port::InnerPort, _::String)
  print(io, port.junction)
  if port.power
    print(io, ", power")
  else
    print(io, ", state")
  end
end
