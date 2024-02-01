using Printf

const MAXEDGE = 20.0

struct Edge
    source::String
    dest::String
end

function Edge(source::String, dest::String)
    return Edge(source, dest)
end

Base.:(<)(a::Edge, b::Edge) = a.source != b.source ? a.source < b.source : a.dest < b.dest

function read_edges(edges, nodes, fileName)
    node1, node2, label = "", "", 0
    open(fileName) do file
        while !eof(file)
            line = readline(file)
            if occursin("label", line)
                m = match(r"\"([^\"]+)\" -> \"([^\"]+)\" \[label=(\d+)\]", line)
                if m !== nothing
                    node1, node2, label = m.captures
                    edges[Edge(node1, node2)] = parse(Int, label)
                    push!(nodes, node1)
                    push!(nodes, node2)
                end
            end
        end
    end
end


function print_dot_file(DOTFILENAME, nodes1, nodes2, edges1, edges2, max_edge)
    open(DOTFILENAME, "w") do f
        write(f, "digraph trace {\nnode [shape=box];\n")

        for node in setdiff(nodes1, nodes2)
            write(f, "  \"$node\" [color = green]\n")
        end

        for node in setdiff(nodes2, nodes1)
            write(f, "  \"$node\" [color = red]\n")
        end

        # Merge edges from both graphs
        all_edges = merge(edges1, edges2)

        for (edge, label) in all_edges
            label1 = get(edges1, edge, 0)
            label2 = get(edges2, edge, 0)
            merged_label = label1 - label2

            if haskey(edges1, edge)
                # Edge present in the first graph
                if merged_label > 0
                    write(f, "  \"$(edge.source)\" -> \"$(edge.dest)\" [label=$merged_label] [color=green];\n")
                elseif merged_label < 0
                    write(f, "  \"$(edge.source)\" -> \"$(edge.dest)\" [label=$merged_label] [color=red];\n")
                else
                    write(f, "  \"$(edge.source)\" -> \"$(edge.dest)\" [label=$merged_label] [color=gray];\n")
                end
            else
                # Edge only present in the second graph
                write(f, "  \"$(edge.source)\" -> \"$(edge.dest)\" [label=$merged_label] [color=red];\n")
            end
        end

        write(f, "}")
    end
end

function find_max_edge(edges1, edges2)
    max_edge = 1.0
    for (edge, label1) in edges1
        max_edge = max(max_edge, log(abs(label1 - get(edges2, edge, 0))))
    end
    for (edge, label) in edges2
        max_edge = max(max_edge, log(abs(label - get(edges1, edge, 0))))
    end
    return max_edge
end

function print_ps_file(DOTFILENAME, PSFILENAME)
    run(`dot -Tps2 $DOTFILENAME -o $PSFILENAME`)
end

function print_pdf_file(PSFILENAME, PDFFILENAME)
    run(`ps2pdf $PSFILENAME $PDFFILENAME`)
end

function main()
    println("Starting main function...")

    if length(ARGS) < 3
        println("Usage: graphDiff file1.dot file2.dot output")
        return 1
    end

    DOTFILENAME = string(ARGS[end], ".dot")
    PSFILENAME = string(ARGS[end], ".ps")
    PDFFILENAME = string(ARGS[end], ".pdf")

    edges1, nodes1 = Dict{Edge, Int}(), Set{String}()
    edges2, nodes2 = Dict{Edge, Int}(), Set{String}()

    read_edges(edges1, nodes1, ARGS[1])
    read_edges(edges2, nodes2, ARGS[2])

    max_edge = find_max_edge(edges1, edges2)

    print_dot_file(DOTFILENAME, nodes1, nodes2, edges1, edges2, max_edge)
    print_ps_file(DOTFILENAME, PSFILENAME)
    print_pdf_file(PSFILENAME, PDFFILENAME)

    println("Finished main function.")
    return 0
end

@time main()
