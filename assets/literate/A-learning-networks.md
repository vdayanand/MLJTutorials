<!--This file was generated, do not modify it.-->
## Preliminary steps

Let's generate a `DataFrame` with some dummy regression data, let's also load the good old ridge regressor.

```julia:ex1
using MLJ, DataFrames, Random
@load RidgeRegressor pkg=MultivariateStats

Random.seed!(5) # for reproducibility
x1 = rand(300)
x2 = rand(300)
x3 = rand(300)
y = exp.(x1 - x2 -2x3 + 0.1*rand(300))
X = DataFrame(x1=x1, x2=x2, x3=x3)
first(X, 3) |> pretty
```

Let's also prepare the train and test split which will be useful later on.

```julia:ex2
test, train = partition(eachindex(y), 0.8);
```

## Defining a learning network

In MLJ, a *learning network* is a directed acyclic graph (DAG) whose *nodes* apply trained or untrained operations such as a `predict` or `transform` (trained) or `+`, `vcat` etc. (untrained).
Learning networks can be seen as pipelines on steroids.

Let's consider the following simple DAG:

![](/assets/diagrams/composite1.svg)

It corresponds to a fairly standard regression workflow: the data is standardized, the target is transformed using a Box-Cox transformation, a ridge regression is applied and the result is converted back by inverting the transform.

**Note**: actually  this DAG is simple enough that it could also have been done with a pipeline.

### Sources and nodes

In MLJ a learning network starts at **source** nodes and flows through nodes (`X` and `y`) defining operations/transformations (`W`, `z`, `ẑ`, `ŷ`).
To define the source nodes, use the `source` function, you should specify whether it's a target:

```julia:ex3
Xs = source(X)
ys = source(y, kind=:target)
```

To define an "trained-operation" node, you must simply create a machine wrapping a model and another node (the data) and indicate which operation should be performed (e.g. `transform`):

```julia:ex4
stand = machine(Standardizer(), Xs)
W = transform(stand, Xs)
```

You can `fit!` a trained-operation node at any point, MLJ will fit whatever it needs that is upstream of that node.
In this case, there is just a source node upstream of `W` so fitting `W` will just fit the standardizer:

```julia:ex5
fit!(W, rows=train);
```

If you want to get the transformed data, you can then call the node speciying on which part of the data the operation should be performed:

```julia:ex6
W()             # transforms all data
W(rows=test, )  # transforms only test data
W(X[3:4, :])    # transforms specific data
```

Let's now define the other nodes:

```julia:ex7
box_model = UnivariateBoxCoxTransformer()
box = machine(box_model, ys)
z = transform(box, ys)

ridge_model = RidgeRegressor(lambda=0.1)
ridge = machine(ridge_model, W, z)
ẑ = predict(ridge, W)

ŷ = inverse_transform(box, ẑ)
```

Note that we have not yet done any training, but if we now call `fit!` on `ŷ`, it will fit all nodes upstream of `ŷ` that need to be re-trained:

```julia:ex8
fit!(ŷ, rows=train);
```

Now that `ŷ` has been fitted, you can apply the full graph on test data (or any compatible data). For instance, let's get the `rms` between the ground truth and the predicted values:

```julia:ex9
rms(y[test], ŷ(rows=test))
```

### Modifying hyperparameters

Hyperparameters can be accessed using the dot syntax as usual.
Let's modify the regularisation parameter of the ridge regression:

```julia:ex10
ridge_model.lambda = 5.0;
```

Since the node `ẑ` corresponds to a machine that wraps `ridge_model`, that node has effectively changed and will be retrained:

```julia:ex11
fit!(ŷ, rows=train)
rms(y[test], ŷ(rows=test))
```

## "Arrow" syntax
**Important**: for this to work, you need to be using **Julia ≥ 1.3**:

The syntax to define nodes etc. is a bit verbose. MLJ supports a shorter syntax which abstracts away some of the steps. We will refer to it as the "arrow" syntax as it makes use of the `|>` operator which can be interpreted as "data flow".

Let's start with `W` and `z` (the "first layer"):

```julia:ex12
W = X |> Standardizer()
z = y |> UnivariateBoxCoxTransformer()
```

Note that we feed `X` and `y` directly into models. In the background, MLJ will create source nodes and assumes that the operation is a `transform` given the models are unsupervised.

For a node that corresponds to a supervised model, you can feed a tuple where the first element corresponds to the input (here `W`) and the second corresponds to the target (here `z`), MLJ will assume the operation is a `predict`:

```julia:ex13
ẑ = (W, z) |> RidgeRegressor(lambda=0.1);
```

Finally we need to apply the inverse of the transform encapsulated in the node `z`, for this:

```julia:ex14
ŷ = ẑ |> inverse_transform(z);
```

That's it! You can now fit the network as before:

```julia:ex15
fit!(ŷ, rows=train)
rms(y[test], ŷ(rows=test))
```

To *manually* modify hyperparameters on a node, you can access them like so:

```julia:ex16
ẑ[:lambda] = 5.0;
```

Here remember that `ẑ` is a node with a machine that wraps around a ridge regression with a parameter `lambda` so the syntax above is equivalent to

```julia:ex17
ẑ.machine.model.lambda = 5.0;
```

which is relevant if you want to tune the hyperparameter using a `TunedModel`.

```julia:ex18
fit!(ŷ, rows=train)
rms(y[test], ŷ(rows=test))
```

