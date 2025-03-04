# This file was generated, do not modify it.

using MLJ, RDatasets, ScientificTypes, PrettyPrinting

@load LinearRegressor pkg=MLJLinearModels
@load RidgeRegressor pkg=MLJLinearModels
@load LassoRegressor pkg=MLJLinearModels

hitters = dataset("ISLR", "Hitters")
@show size(hitters)
names(hitters) |> pprint

y, X = unpack(hitters, ==(:Salary), col->true);

no_miss = .!ismissing.(y)
y = collect(skipmissing(y))
X = X[no_miss, :]
train, test = partition(eachindex(y), 0.5, shuffle=true, rng=424);

Xc = coerce(X, autotype(X, rules=(:discrete_to_continuous,)))
scitype(Xc)

@pipeline RegPipe(std = Standardizer(),
                  hot = OneHotEncoder(),
                  reg = LinearRegressor())

model = RegPipe()
pipe  = machine(model, Xc, y)
fit!(pipe, rows=train)
ŷ = predict(pipe, rows=test)
round(rms(ŷ, y[test])^2, sigdigits=4)

pipe.model.reg = RidgeRegressor()
fit!(pipe, rows=train)
ŷ = predict(pipe, rows=test)
round(rms(ŷ, y[test])^2, sigdigits=4)

r  = range(model, :(reg.lambda), lower=1e-2, upper=100_000, scale=:log10)
tm = TunedModel(model=model, ranges=r, tuning=Grid(resolution=50),
                resampling=CV(nfolds=3, rng=4141), measure=rms)
mtm = machine(tm, Xc, y)
fit!(mtm, rows=train)

best_mdl = fitted_params(mtm).best_model
round(best_mdl.reg.lambda, sigdigits=4)

ŷ = predict(mtm, rows=test)
round(rms(ŷ, y[test])^2, sigdigits=4)

mtm.model.model.reg = LassoRegressor()
mtm.model.ranges = range(model, :(reg.lambda), lower=500, upper=100_000, scale=:log10)
fit!(mtm, rows=train)

best_mdl = fitted_params(mtm).best_model
round(best_mdl.reg.lambda, sigdigits=4)

ŷ = predict(mtm, rows=test)
round(rms(ŷ, y[test])^2, sigdigits=4)

coefs = mtm.fitresult.fitresult.machine.fitresult
round.(coefs, sigdigits=2)

sum(coefs .≈ 0) / length(coefs)

@load ElasticNetRegressor pkg=MLJLinearModels

mtm.model.model.reg = ElasticNetRegressor()
mtm.model.ranges = [range(model, :(reg.lambda), lower=0.1, upper=100, scale=:log10),
                    range(model, :(reg.gamma),  lower=500, upper=10_000, scale=:log10)]
mtm.model.tuning = Grid(resolution=10)
fit!(mtm, rows=train)

best_mdl = fitted_params(mtm).best_model
@show round(best_mdl.reg.lambda, sigdigits=4)
@show round(best_mdl.reg.gamma, sigdigits=4)

ŷ = predict(mtm, rows=test)
round(rms(ŷ, y[test])^2, sigdigits=4)

