
const NETCDF_LOCK = ReentrantLock()

function append_function_name(exp::Expr,suffix)
    args =
        if exp.head == :call
            [Symbol(string(exp.args[1],suffix)), exp.args[2:end]...]
        else
            append_function_name.(exp.args,suffix)
        end
    return Expr(exp.head,args...)
end
append_function_name(exp,suffix) = exp

macro with_lock(exp)
    @assert exp.head == :function

    sig = exp.args[1]
    body_nolock = exp.args[2]

    sig_nolock = append_function_name(sig,"_nolock")
    body = quote
        lock(NETCDF_LOCK) do
            $body_nolock
        end
    end

    return Expr(:block,
                Expr(:function,sig,body),
                Expr(:function,sig_nolock,body_nolock)
                ) |> esc
end
