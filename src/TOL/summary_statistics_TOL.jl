

function prepare_dataframe(data, problems, rts)
    df = DataFrame(subject=Int[], puzzle=Int[], RT=Int[], s=s_type[], move=a_type[], prev_move=a_type[], all_moves=Vector{a_type}[], d_goal=Int[], Lopt=Int[], features=Matrix{Float64}[], tree=Vector{Dict}[], first_move=Bool[], neighs=Vector{s_type}[])
    d_goals = Dict{s_type, Int}[]
    for prb in ProgressBar(eachindex(problems))
        s = vector_to_s_type(problems[prb][1])
        s_goal = vector_to_s_type(problems[prb][2])
        distances = search(s_goal)
        Lopt = distances[s]
        for subj in eachindex(data)
            s = vector_to_s_type(problems[prb][1])
            subj_data = data[subj][prb]
            subj_rts = rts[subj][prb]
            prev_move = ((0, 0), (0, 0))
            for i in eachindex(subj_data)
                all_moves = get_all_moves(s)
                move = all_moves[findfirst(x -> x[1][1] == subj_data[i][1] && x[2][1] == subj_data[i][2], all_moves)]
                rt = subj_rts[i]
                tree = get_and_or_tree(s, s_goal)
                first_move = i == 1
                neighs = [make_move(s, (move_[1][1], move_[2][1])) for move_ in all_moves]
                features = calculate_features(neighs, s_goal)

                push!(df, (subj, prb, rt, s, move, prev_move, all_moves, distances[s], Lopt, features, tree, first_move, neighs))

                s = make_move(s, (move[1][1], move[2][1]))
                prev_move = move
            end
        end
        push!(d_goals, distances)
    end
    return df, d_goals
end

function calculate_features(neighs::Vector{s_type}, s_goal::s_type)::Matrix{Int}
    features = zeros(Int, length(neighs), 2)
    for i in eachindex(neighs)
        s = neighs[i]
        correct_place = 0
        wrong_place = 0
        for i in 1:3
            for j in 1:4-i
                if s[i][j] != 0 && s[i][j] == s_goal[i][j]
                    correct_place += 1
                elseif s[i][j] != 0 && s_goal[i][j] != 0 && s[i][j] != s_goal[i][j]
                    wrong_place += 1
                end
            end
        end
        features[i, 1] = correct_place
        features[i, 2] = wrong_place
    end
    return features
end

function X_histogram(move, row, d_goals)
    return 1
end

function X_d_goal(move, row, d_goals)
    return row.d_goal
end

function X_n_A(move, row, d_goals)
    return length(row.all_moves)
end

function X_diff(move, row, d_goals)
    return row.Lopt
end

function X_rt(move, row, d_goal)
    return row.RT
end

function X_AO_size(move, row, d_goal)
    return length(row.tree[1]) + length(row.tree[2])
end

function X_first_move(move, row, d_goals)
    return row.first_move
end

function y_d_goal(move, row, d_goals)
    move_idx = findfirst(x->x==move, row.all_moves)
    sampled_s = row.neighs[move_idx]
    d_goal_next = d_goals[row.puzzle][sampled_s]
    return d_goal_next+1
end

function y_p_in_tree(move, row, d_goals)
    AND, OR, parents_moves = row.tree
    return move ∈ keys(parents_moves)
end

function y_p_undo(move, row, d_goals)
    if row.prev_move == ((0, 0), (0, 0))
        return 0
    else
        undo_move = (row.prev_move[2][1], row.prev_move[1][1])
        return (move[1][1], move[2][1]) == undo_move
    end
end

function y_p_same_car(move, row, d_goals)
    if row.prev_move == ((0, 0), (0, 0))
        return 0
    else
        prev_car = row.s[row.prev_move[2][1]][row.prev_move[2][2]]
        curr_car = row.s[move[1][1]][move[1][2]]
        return curr_car == prev_car
    end
end

function y_d_tree(move, row, d_goals)
    AND, OR, parents_moves = row.tree
    if move in keys(parents_moves)
        ds = [or_node[1] for or_node in parents_moves[move]]
        return minimum(ds)
    else
        return 1e9
    end
end

function y_d_tree_diff(move, row, d_goals)
    AND, OR, parents_moves = row.tree
    if isempty(parents_moves)
        return 1e9
    end
    all_unique_depths = sort(unique(reduce(vcat, [[or_node[1] for or_node in parents_moves[move]] for move in keys(parents_moves)])))
    diff_depths = all_unique_depths .- all_unique_depths[1]
    if move in keys(parents_moves)
        # look at depths of all possible OR nodes, find their position in unique depths,
        # and let this index the rank
        ranked_ds = [diff_depths[findfirst(x->x==or_node[1], all_unique_depths)] for or_node in parents_moves[move]]
        return minimum(ranked_ds)
    else
        return 1e9
    end
end

function y_p_worse(move, row, d_goals)
    move_idx = findfirst(x->x==move, row.all_moves)
    sampled_s = row.neighs[move_idx]
    d_goal_sampled = d_goals[row.puzzle][sampled_s]
    return d_goal_sampled > row.d_goal
end

function y_p_same(move, row, d_goals)
    move_idx = findfirst(x->x==move, row.all_moves)
    sampled_s = row.neighs[move_idx]
    d_goal_sampled = d_goals[row.puzzle][sampled_s]
    return d_goal_sampled == row.d_goal
end

function y_p_better(move, row, d_goals)
    move_idx = findfirst(x->x==move, row.all_moves)
    sampled_s = row.neighs[move_idx]
    d_goal_sampled = d_goals[row.puzzle][sampled_s]
    return d_goal_sampled < row.d_goal
end

function y_p_in_tree_better(move, row, d_goals)
    if y_p_in_tree(move, row, d_goals) == 0
        return 1e9
    else
        return y_p_better(move, row, d_goals)
    end
end


function calculate_summary_statistics(df, df_models, d_goals_prbs, mc_dict, dict; iters=100)
    summary_stats = [X_d_goal, X_n_A, X_diff, X_rt, X_AO_size, X_first_move, y_d_goal, y_p_in_tree, y_p_undo, y_p_same_car, y_d_tree, y_p_worse, y_p_same, y_p_better, y_p_in_tree_better, y_d_tree, y_d_tree_diff]
    N_stats = length(summary_stats)
    models = [random_model, optimal_model, gamma_only_model, gamma_0_model, eureka_model, forward_search, opt_rand_model, hill_climbing_model]
    df_stats = DataFrame(subject=Int[], puzzle=Int[], model=String[], X_d_goal=Int[], X_n_A=Int[], X_diff=Int[], X_rt=Int[], X_AO_size=Int[], X_first_move=Float64[], y_d_goal=Float64[], y_p_in_tree=Float64[], y_p_undo=Float64[], y_p_same_car=Float64[], y_d_tree=Float64[], y_p_worse=Float64[], y_p_same=Float64[], y_p_better=Float64[], y_p_in_tree_better=Float64[], h_d_tree=Int[], h_d_tree_diff=Int[])
    for row in ProgressBar(eachrow(df))
        # subject data
        s = zeros(N_stats)
        for (n, sum_stat) in enumerate(summary_stats)
            s[n] = sum_stat(row.move, row, d_goals_prbs)
        end
        stats = [row.subject, row.puzzle, "data"]
        push!(df_stats, vcat(stats, s))
        # model simulations
        for model in models
            stats = [row.subject, row.puzzle, string(model)]
            if model == optimal_model || model == random_model
                params = 0
            else
                params = df_models[df_models.subject .== row.subject .&& df_models.model .== string(model), :params][1]
            end
            if length(params) == 1
                params = params[1]
            end
            s = zeros(N_stats - 2, iters)
            for i in 1:iters
                if model == forward_search
                    F = mc_dict[row.subject][row.puzzle]
                    state_to_idx = dict[row.puzzle][3]
                    ps = forward_search(params, row, d_goals_prbs, F, state_to_idx)
                else
                    ps = model(params, row, d_goals_prbs)
                end
                move = wsample(row.all_moves, ps)
                for (n, sum_stat) in enumerate(summary_stats)
                    s[n, i] = sum_stat(move, row, d_goals_prbs)
                    if n == N_stats - 2
                        break
                    end
                end
            end
            stats = vcat(stats, [mean(ss[ss .< 1e9]) for ss in eachrow(s)])
            if model == forward_search
                F = mc_dict[row.subject][row.puzzle]
                state_to_idx = dict[row.puzzle][3]
                first_ps = forward_search(params, row, d_goals_prbs, F, state_to_idx)
            else
                first_ps = model(params, row, d_goals_prbs)
            end
            first_move = wsample(row.all_moves, first_ps)
            stats = vcat(stats, [summary_stats[end-1](first_move, row, d_goals_prbs), summary_stats[end](first_move, row, d_goals_prbs)])
            push!(df_stats, stats)
        end
    end
    return df_stats
end

function bin_stats(df_stats, independent_var::Symbol; nbins=10, subject_level=false)
    input_column_names = propertynames(df_stats)[4:end]
    output_column_names = Symbol[]
    for n in input_column_names
        push!(output_column_names, Symbol("mean_"*string(n)))
        push!(output_column_names, Symbol("std_"*string(n)))
    end
    final_column_names = Symbol[]
    for n in input_column_names
        push!(final_column_names, Symbol("m_"*string(n)))
        push!(final_column_names, Symbol("sem_"*string(n)))
    end
    binned_stats_subj = []
    for subj in unique(df_stats.subject)
        df_subj = df_stats[df_stats.subject .== subj, :]
        transform!(df_subj, independent_var => (x -> add_bin_number(x; nbins=nbins)) => :bin_number)
        gdf_subj = groupby(df_subj, [:bin_number, :model])
        dummy = combine(gdf_subj, input_column_names => calculate_mean_sem_1 => output_column_names)
        dummy[!, :subject] .= subj
        push!(binned_stats_subj, dummy)
    end
    binned_stats_subj_ = vcat(binned_stats_subj...)
    if subject_level
        return binned_stats_subj_
    end
    gdf_binned_stats = groupby(binned_stats_subj_, [:model, :bin_number])
    return combine(gdf_binned_stats, output_column_names => calculate_mean_sem_2 => final_column_names)
end

function add_bin_number(d_goal; nbins=10)
    bin_n = zeros(Int64, length(d_goal))
    bins = quantile(d_goal, 0:(1/nbins):1)
    if nbins == 2
        bins = [0, 0.5, 1.0]
    end
    for i in 1:nbins
        if i < nbins
            idxs = d_goal .>= bins[i] .&& d_goal .< bins[i+1]
        else
            idxs = d_goal .>= bins[i] .&& d_goal .<= bins[i+1]
        end
        bin_n[idxs] .= i
    end
    return bin_n
end

function calculate_mean_sem_1(cols...)
    ls = []
    for col in cols
        push!(ls, mean(col[col .< 1e9]), sem(col[col .< 1e9]))
    end
    return [Tuple(ls)]
end

function calculate_mean_sem_2(cols...)
    ls = []
    for i in 1:Int(length(cols)/2)
        m = cols[2*i - 1]
        s = cols[2*i]
        push!(ls, mean(m), 1.96*sqrt(sem(m)^2 + mean(s .^ 2)/length(s)))
    end
    return [Tuple(ls)]
end

function normalize_hist_counts(df, v1, v2, idv, lims)
    df[!, :norm_counts] = zeros(Float64, size(df, 1))
    for a in unique(df[!, v1])
        for b in unique(df[!, v2])
            dummy = df[df[!, v1] .== a .&& df[!, v2] .== b, :].hist_counts
            df[df[!, v1] .== a .&& df[!, v2] .== b, :norm_counts] .= dummy ./ sum(dummy)
            for d in lims
                df_ = df[df[!, v1] .== a .&& df[!, v2] .== b, :]
                if d ∉ df_[!, idv]
                    push!(df, [a, b, d, 0, 0])
                end
            end
        end
    end
    return df
end

problems = load("../games/data/tower_of_london/problems.jld2")["problems"];
_, data, rts = load_tol_data();

df, d_goals_prbs = prepare_dataframe(data, problems, rts);

# df_ = df[df.subject .∈ Ref(1:30), :]

df_models, ps, params_forward = fit_all_models(df, d_goals_prbs)
@save "data/processed_data/df_models_TOL.jld2" df_models
@save "data/processed_data/ps_TOL.jld2" ps

df_modelss = load("data/processed_data/df_models_TOL.jld2")["df_models"]
ps = load("data/processed_data/ps_TOL.jld2")["ps"]

df_models[!, :params] = ps

dict = get_QR_dict(problems)
mc_dict = get_mc_dict(df, params_forward, dict)


df_stats = calculate_summary_statistics(df, df_models, d_goals_prbs, mc_dict, dict)

@save "data/processed_data/df_stats_TOL.jld2" df_stats
df_statss = load("data/processed_data/df_stats_TOL.jld2")["df_stats"]


binned_stats = bin_stats(df_stats, :X_d_goal; nbins=5)

sort!(binned_stats, :bin_number)

df1 = binned_stats[binned_stats.model .== "data", :]
df2 = binned_stats[binned_stats.model .== "gamma_only_model", :]
df3 = binned_stats[binned_stats.model .== "random_model", :]
plot(df1.m_X_d_goal, df1.m_y_p_undo, ribbon=df1.sem_y_p_undo)
plot!(df2.m_X_d_goal, df2.m_y_p_undo, ribbon=df1.sem_y_p_undo)
plot!(df3.m_X_d_goal, df3.m_y_p_undo, ribbon=df1.sem_y_p_undo)

fig6AD(binned_stats)
fig6EF(df_stats)
fig6GI(binned_stats)