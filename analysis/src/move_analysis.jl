include("plot_graph.jl")
include("rushhour.jl")

subjs = collect(keys(data));
prb = "prb55384_14";
#prb = "prb29414_11";
#prb = "prb29027_16";
board = load_data(prb);
tree, seen, stat, dict, parents, children, solutions = bfs_path_counters(board, traverse_full=true);
tree, seen, stat, dict, all_parents, children, solutions = bfs_path_counters(board, traverse_full=true, all_parents=true);
solution_paths, fake_tree, max_heur = get_solution_paths(solutions, parents, stat);

heurs = [(x,y)->0, red_distance, multi_mag_size_nodes]
heurs_names = ["bfs", "a_star_red_distance", "a_star_multi_mag_size_nodes"]


dfs_nodes, _, _ = dfs(board);
println("dfs")
println(length(dfs_nodes))
println("---------")
for i in eachindex(dfs_nodes)
    g = draw_visited_nodes(dfs_nodes[1:i], parents, all_parents, solutions, solution_paths)
    if i < 10
        save_graph(g, "analysis/figures/animations/move_analysis/human_moves/"*prb*"/dfs/dfs_00"*string(i))
    elseif i < 100
        save_graph(g, "analysis/figures/animations/move_analysis/human_moves/"*prb*"/dfs/dfs_0"*string(i))
    else
        save_graph(g, "analysis/figures/animations/move_analysis/human_moves/"*prb*"/dfs/dfs_"*string(i))
    end
end


for j in eachindex(heurs)
    a_star_nodes, _, _ = a_star(board, h=heurs[j]);
    println(heurs_names[j])
    println(length(a_star_nodes))
    println("---------")
    for i in eachindex(a_star_nodes)
        g = draw_visited_nodes(a_star_nodes[1:i], parents, all_parents, solutions, solution_paths)
        if i < 10
            save_graph(g, "analysis/figures/animations/move_analysis/human_moves/"*prb*"/"*heurs_names[j]*"/"*heurs_names[j]*"_00"*string(i))
        elseif i < 100
            save_graph(g, "analysis/figures/animations/move_analysis/human_moves/"*prb*"/"*heurs_names[j]*"/"*heurs_names[j]*"_0"*string(i))
        else
            save_graph(g, "analysis/figures/animations/move_analysis/human_moves/"*prb*"/"*heurs_names[j]*"/"*heurs_names[j]*"_"*string(i))
        end
    end
end

for subj in subjs
    tot_arrs, tot_move_tuples, tot_states_visited, attempts = analyse_subject(data[subj]);
    if !(prb in keys(tot_states_visited))
        continue
    end
    nodes = tot_states_visited[prb];
    println(split(subj, ":")[1])
    println(length(nodes))
    println("---------")
    for i in eachindex(nodes)
        g = draw_visited_nodes(nodes[1:i], parents, all_parents, solutions, solution_paths)
        if i < 10
            save_graph(g, "analysis/figures/animations/move_analysis/human_moves/"*prb*"/"*split(subj, ":")[1]*"/"*prb*split(subj, ":")[1]*"_00"*string(i))
        elseif i < 100
            save_graph(g, "analysis/figures/animations/move_analysis/human_moves/"*prb*"/"*split(subj, ":")[1]*"/"*prb*split(subj, ":")[1]*"_0"*string(i))
        else
            save_graph(g, "analysis/figures/animations/move_analysis/human_moves/"*prb*"/"*split(subj, ":")[1]*"/"*prb*split(subj, ":")[1]*"_"*string(i))
        end
    end
end