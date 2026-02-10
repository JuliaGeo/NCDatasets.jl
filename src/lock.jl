
const NETCDF_LOCK = ReentrantLock()

macro with_lock(exp)
    @assert exp.head == :function

    sig = exp.args[1]
    body_nolock = exp.args[2]

    body = quote
        lock(NETCDF_LOCK) do
            $body_nolock
        end
    end

    return Expr(:function,sig,body) |> esc
end
