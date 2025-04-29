# Run script from the root folder:
# `julia ./test/coverage.jl`
# Result can be viewed e.g. with VSCode plugin Coverage Gutters:
# Command Palette: Coverage Gutters: Display Coverage

using Pkg

Pkg.test("EPHS"; coverage=true)

Pkg.activate("test")

using Coverage

coverage = process_folder()

open("lcov.info", "w") do io
  LCOV.write(io, coverage)
end

Coverage.clean_folder(".")
