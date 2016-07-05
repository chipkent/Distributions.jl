doc"""
    Pareto(α,θ)

The *Pareto distribution* with shape `α` and scale `θ` has probability density function

$f(x; \alpha, \theta) = \frac{\alpha \theta^\alpha}{x^{\alpha + 1}}, \quad x \ge \theta$

```julia
Pareto()            # Pareto distribution with unit shape and unit scale, i.e. Pareto(1, 1)
Pareto(a)           # Pareto distribution with shape a and unit scale, i.e. Pareto(a, 1)
Pareto(a, b)        # Pareto distribution with shape a and scale b

params(d)        # Get the parameters, i.e. (a, b)
shape(d)         # Get the shape parameter, i.e. a
scale(d)         # Get the scale parameter, i.e. b
```

External links
 * [Pareto distribution on Wikipedia](http://en.wikipedia.org/wiki/Pareto_distribution)

"""
immutable Pareto{T<:Real} <: ContinuousUnivariateDistribution
    α::T
    θ::T

    function Pareto(α::T, θ::T)
        @check_args(Pareto, α > zero(α) && θ > zero(θ))
        new(α, θ)
    end
end

Pareto{T<:Real}(α::T, θ::T) = Pareto{T}(α, θ)
Pareto(α::Real, θ::Real) = Pareto(promote(α, θ)...)
Pareto(α::Integer, θ::Integer) = Pareto(Float64(α), Float64(θ))
Pareto(α::Real) = Pareto(α, 1.0)
Pareto() = Pareto(1.0, 1.0)

@distr_support Pareto d.θ Inf

#### Conversions
convert{T<:Real}(::Type{Pareto{T}}, α::Real, θ::Real) = Pareto(T(α), T(θ))
convert{T <: Real, S <: Real}(::Type{Pareto{T}}, d::Pareto{S}) = Pareto(T(d.α), T(d.θ))

#### Parameters

shape(d::Pareto) = d.α
scale(d::Pareto) = d.θ

params(d::Pareto) = (d.α, d.θ)


#### Statistics

function mean{T<:Real}(d::Pareto{T})
    (α, θ) = params(d)
    α > 1 ? α * θ / (α - 1) : T(Inf)
end
median(d::Pareto) = ((α, θ) = params(d); θ * 2^(1/α))
mode(d::Pareto) = d.θ

function var{T<:Real}(d::Pareto{T})
    (α, θ) = params(d)
    α > 2 ? (θ^2 * α) / ((α - 1)^2 * (α - 2)) : T(Inf)
end

function skewness{T<:Real}(d::Pareto{T})
    α = shape(d)
    α > 3 ? ((2(1 + α)) / (α - 3)) * sqrt((α - 2) / α) : T(NaN)
end

function kurtosis{T<:Real}(d::Pareto{T})
    α = shape(d)
    α > 4 ? (6(α^3 + α^2 - 6α - 2)) / (α * (α - 3) * (α - 4)) : T(NaN)
end

entropy(d::Pareto) = ((α, θ) = params(d); log(θ / α) + 1 / α + 1)


#### Evaluation

function pdf{T<:Real}(d::Pareto{T}, x::Real)
    (α, θ) = params(d)
    x >= θ ? α * (θ / x)^α * (1/x) : zero(T)
end

function logpdf{T<:Real}(d::Pareto{T}, x::Real)
    (α, θ) = params(d)
    x >= θ ? log(α) + α * log(θ) - (α + 1) * log(x) : -T(Inf)
end

function ccdf{T<:Real}(d::Pareto{T}, x::Real)
    (α, θ) = params(d)
    x >= θ ? (θ / x)^α : one(T)
end

cdf(d::Pareto, x::Real) = 1 - ccdf(d, x)

function logccdf{T<:Real}(d::Pareto{T}, x::Real)
    (α, θ) = params(d)
    x >= θ ? α * log(θ / x) : zero(T)
end

logcdf(d::Pareto, x::Real) = log1p(-ccdf(d, x))

cquantile(d::Pareto, p::Real) = d.θ / p^(1 / d.α)
quantile(d::Pareto, p::Real) = cquantile(d, 1 - p)


#### Sampling

rand(d::Pareto) = d.θ * exp(randexp() / d.α)


## Fitting

function fit_mle{T<:Real}(::Type{Pareto}, x::AbstractArray{T})
    # Based on
    # https://en.wikipedia.org/wiki/Pareto_distribution#Parameter_estimation

    θ = minimum(x)

    n = length(x)
    lθ = log(θ)
    temp1 = zero(T)
    for i=1:n
        temp1 += log(x[i]) - lθ
    end
    α = n/temp1

    return Pareto(α, θ)
end
