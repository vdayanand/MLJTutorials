# This file was generated, do not modify it. # hide
using MLJ, RDatasets, ScientificTypes,
      DataFrames, Statistics, StatsBase

smarket = dataset("ISLR", "Smarket")
@show size(smarket)
@show names(smarket)