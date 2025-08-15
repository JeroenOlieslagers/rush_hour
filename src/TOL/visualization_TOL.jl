

function create_move_icon(and_node)
    return "$(and_node[2][2][1])→$(and_node[2][3][1])"
end

function draw_ao_tree(AND, OR)
    graph = """digraph{graph [pad="0.2",nodesep="0.15",ranksep="0.3"];layout="dot";"""
    for and in keys(AND)
        graph *= """ "$(and)" [fixedsize=shape,shape=diamond,style=filled,fillcolor="#DBDBDB",label="$(create_move_icon(and))",height=.5,width=.5,fontsize=14];"""
        for or in AND[and]
            if or[2][1] != 0
                graph *= """ "$(and)"->"$(or)"[constraint="true"];"""
                if or ∉ keys(OR)
                    graph *= """ "$(or)"[fontname="Helvetica",fixedsize=shape,style=filled,fillcolor="#E05B53",width=0.6,margin=0,label="$(or[2][1])",fontsize=20,shape="circle"];"""
                end
            end
        end
    end
    for or in keys(OR)
        graph *= """ "$(or)"[fontname="Helvetica",fixedsize=shape,style=filled,fillcolor=white,width=0.6,margin=0,label="$(or[2][1])",fontsize=20,shape="circle"];"""
        for and in OR[or]
            graph *= """ "$(or)"->"$(and)"[constraint="true"];"""
            if and ∉ keys(AND)
                graph *= """ "$(and)" [fixedsize=shape,shape=diamond,style=filled,fillcolor="#86D584",label="$(create_move_icon(and))",height=.5,width=.5,fontsize=14];"""
            end
        end
    end
    graph *= "}"
    return GraphViz.Graph(graph)
end

function plot_tower(s, sp)
    xs, ys, colors, labels = Int[], Int[], Symbol[], String[]
    color_map = Dict(1 => :red, 2 => :blue, 3 => :green)
    for (peg_idx, peg) in enumerate(s)
        for (slot_idx, bead) in enumerate(peg)
            if bead != 0
                push!(xs, peg_idx)
                push!(ys, slot_idx)
                push!(colors, color_map[bead])
                push!(labels, string(bead))
            end
        end
    end
    # Draw pegs
    for x in 1:3
        plot!(sp=sp, [x, x], [0.5, 3 - x + 1.5], lw=2, lc=:black)
    end
    # Draw beads
    scatter!(sp=sp, xs, ys, markersize=25, c=colors, shape=:circle)
    for (x, y, label) in zip(xs, ys, labels)
        annotate!(x, y, text(label, :white, 12, :center), sp=sp)
    end
end

function draw_state(s, s_goal)
    p = plot(; layout=grid(1, 2), size=(372, 200), xlim=(0.5, 3.5), ylim=(0.5, 3.5),
    xticks=(1:3, ["P$peg" for peg in 1:3]),
    yticks=nothing,
    legend=false, grid=false, aspect_ratio=1)
    plot_tower(s, 1)
    plot_tower(s_goal, 2)
    return p
end


