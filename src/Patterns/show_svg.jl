
# TODO draw port/junction names (hover text?)
# Or perhaps keep this minimal and later spend available time on a web frontend


function Base.show(io::IO, ::MIME"image/svg+xml", pattern::Pattern{F,Position}) where {F}
  print(io, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  print_svg(io, pattern)
end


function print_svg(io::IO, pattern::Pattern{F,Position}) where {F}
  scale = 200 # grid to canvas
  padding = 100 # between inner boxes and outer box
  margin = 5 # around outer box

  grid_dims = grid_dimensions(pattern)
  y_min, y_max, x_min, x_max = dims = scale .* grid_dims .+ padding .* (-1, +1, -1, +1)
  width = x_max - x_min
  height = y_max - y_min

  print(io,
    """
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="$(width)px" height="$(height)px"
      viewBox="$(x_min-margin) $(y_min-margin) $(width+2*margin) $(height+2*margin)"
    >
    """
  )
  draw_outer_box(io, x_min, y_min, width, height)
  draw_ports(io, pattern, scale)
  draw_external_ports(io, pattern, scale, grid_dims, dims)
  draw_boxes(io, pattern, scale)
  draw_junctions(io, pattern, scale)
  print(io,
    """
    </svg>
    """
  )
end


"""
Get the dimensions of the outer box on the grid.
Returns `r_min, r_max, c_min, c_max` (minimal/maximal row/column index).
"""
function grid_dimensions(pattern::Pattern{F,Position}) where {F}
  r_min = typemax(Int)
  r_max = typemin(Int)
  c_min = typemax(Int)
  c_max = typemin(Int)

  foreachvalue(pattern.junctions) do junction
    (; r, c) = junction.position
    r_min = min(r, r_min)
    r_max = max(r, r_max)
    c_min = min(c, c_min)
    c_max = max(c, c_max)
  end

  foreachvalue(pattern.boxes) do box
    (; r, c) = box.position
    r_min = min(r, r_min)
    r_max = max(r, r_max)
    c_min = min(c, c_min)
    c_max = max(c, c_max)
  end

  r_min, r_max, c_min, c_max
end


function draw_outer_box(io, x_min, y_min, width, height)
  print(io,
    """
    <rect x="$x_min" y="$y_min" width="$width" height="$height"
      stroke="black" stroke-width="2"
      fill="white"
    />
    """
  )
end


function draw_ports(io, pattern, scale)
  # TODO Could integrate this into `draw_boxes!`
  foreachvalue(pattern.boxes) do box
    foreachvalue(box.ports) do port
      junction = pattern.junctions[port.junction]
      (x1, y1, x2, y2) = scale .* (box.position.c, box.position.r, junction.position.c, junction.position.r)
      print(io,
        """
        <line x1="$x1" y1="$y1" x2="$x2" y2="$y2"
          stroke="black" stroke-width="2"
          stroke-dasharray="$(port.power ? "none" : "8.0,8.0")"
        />
        """
      )
    end
  end
end


function draw_external_ports(io, pattern, scale, grid_dims, dims)
  r_min, r_max, c_min, c_max = grid_dims
  y_min, y_max, x_min, x_max = dims
  foreachvalue(pattern.junctions) do junction
    if junction.exposed
      (x2, y2) = scale .* (junction.position.c, junction.position.r)
      dist_c_min = junction.position.c - c_min
      dist_c_max = c_max - junction.position.c
      dist_r_min = junction.position.r - r_min
      dist_r_max = r_max - junction.position.r
      # TODO improve readability of code
      shortest = min(dist_c_min, dist_c_max, dist_r_min, dist_r_max)
      (x1, y1) =
        shortest == dist_c_min ? (x_min, y2) :
        shortest == dist_c_max ? (x_max, y2) :
        shortest == dist_r_min ? (x2, y_min) : (x2, y_max)
      print(io,
        """
        <line x1="$x1" y1="$y1" x2="$x2" y2="$y2"
          stroke="black" stroke-width="2"
          stroke-dasharray="$(junction.power ? "none" : "8.0,8.0")"
        />
        """
      )
    end
  end
end


function draw_boxes(io, pattern, scale)
  foreach(pattern.boxes) do (box_path, box)
    (x, y) = scale .* (box.position.c, box.position.r)
    color = isnothing(box.filling) ? "white" : fillcolor(box.filling)
    print(io,
      """
      <g transform="translate($x, $y)">
        <circle r="75" stroke="black" stroke-width="2" fill="$color" />
      """
    )
    draw_box_name(io, box_path)
    write(io,
      """
      </g>
      """
    )
  end
end


function draw_junctions(io, pattern, scale)
  foreachvalue(pattern.junctions) do junction
    (x, y) = scale .* (junction.position.c, junction.position.r)
    print(io,
      """
      <circle cx="$x" cy="$y" r="8" fill="black" />
      """
    )
  end
end


# TODO this is a mess and does not really work
# goal: add line breaks to keep longer text inside box
# add ellipsis for very long text (hover text?)
function draw_box_name(io, box_path)
  words = split(string(box_path), '_')
  lines = Vector{Vector{String}}()
  push!(lines, Vector{String}())
  n_line = 1
  len_line = 0
  for word in words
    if len_line != 0 && (len_line + length(word) > 13)
      push!(lines, Vector{String}())
      n_line += 1
      len_line = 0
    end
    push!(lines[n_line], word)
    len_line += length(word) + 1
  end

  dy = [
    [0],
    [-12, 12],
    [-24, 0, 24],
    [-36, -12, 12, 36],
  ]

  for (i, line) in enumerate(lines)
    print(io,
      """<text
          stroke="black"
          text-anchor="middle"
          dominant-baseline="middle"
          dy="$(dy[n_line][i])"
          font-family="JuliaMono"
          font-size="22"
          >$(join(line, ' '))</text>
      """
    )
  end
end
