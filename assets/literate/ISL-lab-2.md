<!--This file was generated, do not modify it.-->
## Basic commands

This is a very brief and rough primer if you're new to Julia and wondering how to do simpe things that are relevant for data analysis.

Defining a vector

```julia:ex1
x = [1, 3, 2, 5]
@show x
@show length(x)
```

Operations between vectors

```julia:ex2
y = [4, 5, 6, 1]
z = x .+ y # elementwise operation
```

Defining a matrix

```julia:ex3
X = [1  2; 3 4]
```

You can also do that from a vector

```julia:ex4
X = reshape([1, 2, 3, 4], 2, 2)
```

But you have to be careful that it fills the matrix by column; so if you want to get the same result as before let's just permute the dimensions

```julia:ex5
X = permutedims(reshape([1, 2, 3, 4], 2, 2))
```

Function calls can be split with the `|>` operator so that the above can also be written

```julia:ex6
X = reshape([1,2,3,4], 2, 2) |> permutedims
```

You don't have to do that of course but we will sometimes use it in these tutorials.

There's a wealth of functions available for simple math operations

```julia:ex7
x = 4
@show x^2
@show sqrt(x)
```

Element wise operations on a collection can be done with the dot syntax:

```julia:ex8
sqrt.([4, 9, 16])
```

The packages `Statistics` and `StatsBase` offer a number of useful function for stats:

```julia:ex9
using Statistics, StatsBase
```

**Note**: if you don't have `StatsBase`, you can add it using `using Pkg; Pkg.add("StatsBase")`.
Right, let's now compute some simple statistics:

```julia:ex10
x = randn(1_000) # 500 points iid from a N(0, 1)
μ = mean(x)
σ = std(x)
@show (μ, σ)
```

Indexing data starts at 1, use `:` to indicate the full range

```julia:ex11
X = [1 2; 3 4; 5 6]
@show X[1, 2]
@show X[:, 1]
@show X[1, :]
@show X[[1, 2], [1, 2]]
```

`size` gives dimensions (nrows, ncolumns)

```julia:ex12
size(X)
```

## Loading data

There are many ways to load data in Julia, one convenient one is via the CSV package.

```julia:ex13
using CSV
```

Many datasets are available via the `RDatasets` package

```julia:ex14
using RDatasets
```

And finally the `DataFrames` package allows to manipulate data easily

```julia:ex15
using DataFrames
```

Let's load some data from RDatasets (the full list of datasets is available [here](http://vincentarelbundock.github.io/Rdatasets/datasets.html))

```julia:ex16
auto = dataset("ISLR", "Auto")
first(auto, 3)
```

The `describe` function allows to get an idea for the data:

```julia:ex17
describe(auto, :mean, :median, :std)
```

To retrieve column names, you can use `names`:

```julia:ex18
names(auto)
```

Accesssing columns can be done in different ways:

```julia:ex19
mpg = auto.MPG
mpg = auto[:, 1]
mpg = auto[:, :MPG]
mpg |> mean
```

To get dimensions you can use `size` and `nrow` and `ncol`

```julia:ex20
@show size(auto)
@show nrow(auto)
@show ncol(auto)
```

For more detailed tutorials on basic data wrangling in Julia, consider

* the [learn x in y](https://learnxinyminutes.com/docs/julia/) julia tutorial
* the [`DataFrames.jl` docs](http://juliadata.github.io/DataFrames.jl/latest/)
* the [`StatsBases.jl` docs](https://juliastats.org/StatsBase.jl/latest/)

