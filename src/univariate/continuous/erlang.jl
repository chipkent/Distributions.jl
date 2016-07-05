doc"""
    Erlang(α,θ)

The *Erlang distribution* is a special case of a [`Gamma`](:func:`Gamma`) distribution with integer shape parameter.

```julia
Erlang()       # Erlang distribution with unit shape and unit scale, i.e. Erlang(1, 1)
Erlang(a)      # Erlang distribution with shape parameter a and unit scale, i.e. Erlang(a, 1)
Erlang(a, s)   # Erlang distribution with shape parameter a and scale b
```

External links

* [Erlang distribution on Wikipedia](http://en.wikipedia.org/wiki/Erlang_distribution)

"""

immutable Erlang{T<:Real} <: ContinuousUnivariateDistribution
    α::Int
    θ::T

    function Erlang(α::Real, θ::T)
        @check_args(Erlang, isinteger(α) && α >= zero(α))
        new(α, θ)
    end
end

Erlang{T<:Real}(α::Int, θ::T) = Erlang{T}(α, θ)
Erlang(α::Real) = Erlang(α, 1.0)
Erlang() = Erlang(1.0, 1.0)

@distr_support Erlang 0 Inf

#### Conversions
function convert{T <: Real, S <: Real}(::Type{Erlang{T}}, α::Int, θ::S)
    Erlang(α, T(θ))
end
function convert{T <: Real, S <: Real}(::Type{Erlang{T}}, d::Erlang{S})
    Erlang(d.α, T(d.θ))
end

#### Parameters

shape(d::Erlang) = d.α
scale(d::Erlang) = d.θ
rate(d::Erlang) = inv(d.θ)
params(d::Erlang) = (d.α, d.θ)

#### Statistics

mean(d::Erlang) = d.α * d.θ
var(d::Erlang) = d.α * d.θ^2
skewness(d::Erlang) = 2 / sqrt(d.α)
kurtosis(d::Erlang) = 6 / d.α

function mode(d::Erlang)
    (α, θ) = params(d)
    α >= 1 ? θ * (α - 1) : error("Erlang has no mode when α < 1")
end

function entropy(d::Erlang)
    (α, θ) = params(d)
    α + lgamma(α) + (1 - α) * digamma(α) + log(θ)
end

mgf(d::Erlang, t::Real) = (1 - t * d.θ)^(-d.α)
cf(d::Erlang, t::Real)  = (1 - im * t * d.θ)^(-d.α)


#### Evaluation & Sampling

@_delegate_statsfuns Erlang gamma α θ

rand(d::Erlang) = StatsFuns.RFunctions.gammarand(d.α, d.θ)
