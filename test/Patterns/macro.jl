
@ic rtop(a, b) begin
  X(a)
  Y(a, c.x=b)
end


@ic rX(a) begin
  A(x=a, y=a)
end


@ic rY(a, c.x) begin
  A(x=a, y=a)
  B(t=c.x)
end


r = ocompose(rtop, Dtry(■.X => rX, ■.Y => rY))

@ic Id(a, b) begin
  _(a, b)
end
