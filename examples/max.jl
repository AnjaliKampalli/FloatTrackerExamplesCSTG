#Correct modified code
using FloatTracker
using BenchmarkTools
using Base.StackTraces: StackFrame

include("MainTracerSum.jl")

config_logger(filename="max", buffersize=1)

@noinline function maximum(lst)
  max_seen = 0.0
  for x in lst
    if ! (x <= max_seen)
      max_seen = x              # swap if new val greater
    end
  end
  max_seen
end

function maximum2(lst)
  foldl(max, lst)
end

println("--- With less than ---")
res = maximum([TrackedFloat16(x) for x in [1, 5, 4, NaN, 4]]).val
println("Result: $(res)")
println()

println("--- With builtin max ---")
res2 = maximum2([TrackedFloat16(x) for x in [1, 5, 4, NaN, 4]]).val
println("Result: $(res2)")

stack_trace_data = FloatTracker.get_stack_traces()
run_main()
# Get the length of the stack_trace_data array and Print the length
len = length(stack_trace_data)
println("Length of stack_trace_data array: $len")

# Print each line from the stack traces to terminal
# for line in stack_trace_data
#     println(line)
# end


