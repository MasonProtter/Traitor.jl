module Traitor

# Extract `(normal_argument, trait)` from a function argument expression.
# `normal_argument` is the standard argument expr without the trait.  If no
# trait is present in the expression, return `nothing` for `trait`.
#
# :(x::Int::Big) -> (:(x::Int), :Big)
function extract_arg_trait(ex)
    if isa(ex, Symbol)
        return ex, nothing # argument with no type annotation
    end
    if ex.head == :kw # default values, eg f(x::T::A=1)
        arg, traittype = extract_arg_trait(ex.args[1])
        return Expr(:kw, arg, ex.args[2]), traittype
    end
    @assert ex.head == :(::)
    isfourcolon = isa(ex.args[2],Expr) && ex.args[2].head == :(::) # x::::A syntax
    if isa(ex.args[1], Symbol) && !isfourcolon
        return ex, nothing # argument with normal type annotation
    end
    if isfourcolon
        return ex.args[1], ex.args[2].args[1]
    end
    normalarg = ex.args[1]
    @assert normalarg.head == :(::)
    traittype = ex.args[2]
    return normalarg, traittype
end

#=
macro traitor(ex)
    if ex.head != :function
        error("trait expression must be a function")
    end
    def = ex.args[1]
    body = ex.args[2]
    @assert def.head == :call
end
=#

end # module
