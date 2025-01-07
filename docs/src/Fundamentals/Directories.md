# [Directories](@id DirectoriesIntro)

Directories provide a monadic data structure
for hierarchically-organized information.

## Example

Let's start with an example that
specifies (real-valued) initial conditions of a model:

```@example 1
using EPHS # hide
ic = Dtry(
  :oscillator => Dtry(
    :spring => Dtry(
      :q => Dtry(1.0),
    ),
    :mass => Dtry(
      :p => Dtry(0.0),
    ),
  ),
  :thermal_capacity => Dtry(
    :s => Dtry(16.56)
  ),
)
```

We can then access any subdirectory using its name:

```@example 1
ic.oscillator
```

So, directories are trees
(or [tries](https://en.wikipedia.org/wiki/Trie)),
where the leaves hold values of a given type.
The leaves are primitive subdirectories:

```@example 1
ic.thermal_capacity.s
```

Of course, we can also access the values directly:

```@example 1
ic.thermal_capacity.s[]
```

## Paths

A [`DtryPath`](@ref) is given by a sequence of names,
usually used to indicate the path
from the root (represented by `■`) to a leaf:

```@example 1
path::DtryPath = ■.oscillator.spring.q
ic[path]
```


## Monad structure

A monad is an endofunctor with extra structure.
So, in a category of types (objects) and functions (morphisms),
a monad is basically a type,
which is parametrized by another type,
as is the case for either lists or directories of, say, floating-point numbers.

```@example 1
typeof(ic)
```

Given a category $C$,
an endofunctor ``F \colon C \to C`` is
a [monad](https://en.wikipedia.org/wiki/Monad_(category_theory))
if it is equipped with two operations (natural transformations)
satisfying certain diagrams (algebraic laws).
For any object $T \in C$, we have

* ``\mathrm{unit} \colon T \to FT``
* ``\mathrm{flatten} \colon FFT \to FT``

The first function is the *unit* of the monad
and the second function is the *monad multiplication*.

In Julia,
the unit of the directory monad is implemented by
the constructor `Dtry(value::T)`.
It turns a value of type `T` into a directory of `T`s
that contains just the given value:

```@example 1
T = Int
x::T = 42
dtry::Dtry{T} = Dtry(x)
```

The monad multiplication is implemented by
the function `flatten(::Dtry{Dtry{T})` that returns a `Dtry{T}`.
It takes the values/directories of the outer directory
and grafts them directly onto it,
replacing its original leaves.
To illustrate this,
we define a directory of directories of floating-point numbers
and then flatten it:

```@example 1
nested_dtry = Dtry(
  :osc => Dtry(ic.oscillator), # directory as value!
  :tc => Dtry(ic.thermal_capacity)
)
flatten(nested_dtry)
```

More information about
the Julia implementation of directories
is provided in the [reference](@ref Directories).
