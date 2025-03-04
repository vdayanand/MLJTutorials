# This file was generated, do not modify it.

using HTTP, CSV, MLJ, StatsBase, PyPlot
req = HTTP.get("https://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data")
data = CSV.read(req.body,
                header=["Class", "Alcool", "Malic acid",
                        "Ash", "Alcalinity of ash", "Magnesium",
                        "Total phenols", "Flavanoids",
                        "Nonflavanoid phenols", "Proanthcyanins",
                        "Color intensity", "Hue",
                        "OD280/OD315 of diluted wines", "Proline"])
# the target is the Class column, everything else is a feature
y, X = unpack(data, ==(:Class), colname->true);

scitype(y)

yc = coerce(y, OrderedFactor);

scitype(X)

sch = schema(X)
println(rpad(" Name", 28), "| Scitype")
println("-"^45)
for (name, scitype) in zip(sch.names, sch.scitypes)
    println(rpad("$name", 30), scitype)
end

X[1:5, :Proline]

Xc = coerce(X, :Proline=>Continuous, :Magnesium=>Continuous);

describe(Xc, :mean, :std)

@load KNNClassifier pkg="NearestNeighbors"
@load MultinomialClassifier pkg="MLJLinearModels";

@pipeline KnnPipe(std=Standardizer(), clf=KNNClassifier()) is_probabilistic=true
@pipeline MnPipe(std=Standardizer(), clf=MultinomialClassifier()) is_probabilistic=true

train, test = partition(eachindex(yc), 0.8, shuffle=true, rng=111)
Xtrain = selectrows(Xc, train)
Xtest = selectrows(Xc, test)
ytrain = selectrows(yc, train)
ytest = selectrows(yc, test);

knn = machine(KnnPipe(), Xtrain, ytrain)
multi = machine(MnPipe(), Xtrain, ytrain)

opts = (resampling=Holdout(fraction_train=0.9), measure=cross_entropy)
res = evaluate!(knn; opts...)
round(res.measurement[1], sigdigits=3)

res = evaluate!(multi; opts...)
round(res.measurement[1], sigdigits=3)

mcr_k = misclassification_rate(predict_mode(knn, Xtrain), ytrain)
mcr_m = misclassification_rate(predict_mode(multi, Xtrain), ytrain)
println(rpad("KNN mcr:", 10), round(mcr_k, sigdigits=3))
println(rpad("MNC mcr:", 10), round(mcr_m, sigdigits=3))

# @pipeline PCAPipe(std=Standardizer(), t=PCA(maxoutdim=2))
# pca = machine(PCAPipe(), Xtrain)
# fit!(pca, Xtrain)
# W = transform(pca, Xtrain)

@load PCA

pca = Xc |> Standardizer() |> PCA(maxoutdim=2)
fit!(pca)
W = pca(rows=train);

x1 = W.x1
x2 = W.x2

mask_1 = ytrain .== 1
mask_2 = ytrain .== 2
mask_3 = ytrain .== 3

figure(figsize=(8, 6))
plot(x1[mask_1], x2[mask_1], linestyle="none", marker="o", color="red")
plot(x1[mask_2], x2[mask_2], linestyle="none", marker="o", color="blue")
plot(x1[mask_3], x2[mask_3], linestyle="none", marker="o", color="magenta")

xlabel("PCA dimension 1", fontsize=14)
ylabel("PCA dimension 2", fontsize=14)
legend(["Class 1", "Class 2", "Class 3"], fontsize=12)
xticks(fontsize=12)
yticks(fontsize=12)

savefig("assets/EX-wine-pca.svg") # hide

perf_k = misclassification_rate(predict_mode(knn, Xtest), ytest)
perf_m = misclassification_rate(predict_mode(multi, Xtest), ytest)
println(rpad("KNN mcr:", 10), round(perf_k, sigdigits=3))
println(rpad("MNC mcr:", 10), round(perf_m, sigdigits=3))

