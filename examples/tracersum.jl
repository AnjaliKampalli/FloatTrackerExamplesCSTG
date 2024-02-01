# main.jl

using FloatTracker
using Base.Filesystem
using DataStructures
using GraphViz, FileIO, Cairo
using LinearAlgebra
using FileIO

edges = OrderedDict{Tuple{String, String}, Int}()


function configure_logger()
    config_logger(filename="cleanTracerSum", buffersize=1)
    exclude_stacktrace([:prop])
end

function initialize_edge_dict()
    return OrderedDict{Tuple{String, String}, Int}()
end

function get_stack_traces_data()
    return FloatTracker.get_stack_traces()
end

function parse_stack_trace_data(stack_trace_data)
    # stack_trace_data1 = join(stack_trace_data, "\n")

    lines = split(stack_trace_data, "\n")
    # stack_trace_data = FloatTracker.get_stack_traces()
    # stack_trace_data1 = join(stack_trace_data, "\n")
    # edges = initialize_edge_dict()

    for i in 1:length(lines) - 1
        src = lines[length(lines) - i + 1]
        dst = lines[length(lines) - i]

        if !isempty(src) || !isempty(dst)
            edges[(src, dst)] = get(edges, (src, dst), 0) + 1
        end
    end

    return edges
end

function write_dot_file(edges, dot_filename)
    open(dot_filename, "w") do file
        println(file, "digraph trace {")
        println(file, "node [shape=box];")

        for ((source, dest), count) in edges
            println(file, "  \"$source\" -> \"$dest\" [label=$count];")
        end

        println(file, "}")
    end
end

function generate_filenames(category::AbstractString)
    current_file = split(@__FILE__, ".jl")[1]
    dot_filename = basename(current_file) *category* ".dot"
    ps_filename = basename(current_file) *category* ".ps"
    pdf_filename = basename(current_file) *category* ".pdf"

    return dot_filename, ps_filename, pdf_filename
end

function print_ps_file(dot_filename, ps_filename)
    run(`dot -Tps2 $dot_filename -o $ps_filename`)
end

function print_pdf_file(ps_filename, pdf_filename)
    run(`ps2pdf $ps_filename $pdf_filename`)
end

function run_main()
    configure_logger()

    # example_program()

    my_logs = get_stack_traces_data()

    for (category, logs) in my_logs
        # println("Logs for category: $category")
        logs = get(my_logs, category, String[])
        # println(logs)
        logs = join(logs, "\n")
        edges = parse_stack_trace_data(logs)
        if isempty(edges)
            println("No stack trace data available for category: $category")
        else
            dot_filename, ps_filename, pdf_filename = generate_filenames("$category")

            write_dot_file(edges, dot_filename)
            println("Stack trace saved as $dot_filename")

            print_ps_file(dot_filename, ps_filename)
            println("Stack trace saved as $ps_filename")

            print_pdf_file(ps_filename, pdf_filename)
            println("Stack trace saved as $pdf_filename")

            println("-----")
        end
        empty!(edges)
    end
end

# Uncomment the line below if you want to run main when main.jl is included
run_main()

