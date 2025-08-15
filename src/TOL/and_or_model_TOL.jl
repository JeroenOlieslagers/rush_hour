function propagate_ps(x::Float64, AND_OR_tree)::Dict{and_type, Float64}
    function propagate!(x::Float64, p::Float64, ToT, dict, AND_current::and_type, AND, OR)::Nothing
        γ = x
        # number of children of OR node
        N_or = length(AND[AND_current])
        # Rule 2: OR HEURISTICS
        p_ors = p * ones(N_or) / N_or
        # propagate to AND nodes
        for (n, OR_node) in enumerate(AND[AND_current])
            p_or = p_ors[n]
            # CYCLE PROBABILITY
            if OR_node[2] in ToT || OR_node ∉ keys(OR)
                dict[(OR_node[1], (-20, (-20, -20), (-20, -20)))] += (1-γ)*p_or
                dict[(OR_node[1], (-10, (-10, -10), (-10, -10)))] += γ*p_or
                continue
            end
            push!(ToT, OR_node[2])
            # Rule 1a: don't stop
            pp = (1-γ)*p_or
            # Rule 1b: stop
            dict[(OR_node[1], (-10, (-10, -10), (-10, -10)))] += γ*p_or
            N_and = length(OR[OR_node])
            # Rule 3: AND HEURISTICS
            p_ands = pp * ones(N_and) / N_and
            # propagate to AND nodes
            for (m, AND_next) in enumerate(OR[OR_node])
                p_and = p_ands[m]
                # leaf node
                if AND_next ∉ keys(AND)
                    dict[AND_next] += p_and
                else
                    # train of thought
                    new_ToT = copy(ToT)
                    # recurse
                    propagate!(x, p_and, new_ToT, dict, AND_next, AND, OR)
                end
            end
        end
        return nothing
    end
    AND, OR, parents_moves = AND_OR_tree
    dict = DefaultDict{and_type, Float64}(0.0)
    # keeps track of current train of thought nodes visited
    OR_root = (1, (0, 0, 0, 0))
    dict[(1, (-10, (-10, -10), (-10, -10)))] += x
    p = 1.0 - x
    for AND_node in OR[OR_root]
        p_and = p / length(OR[OR_root])
        if AND_node ∉ keys(AND)
            dict[AND_node] += p_and
        else
            propagate!(x, p_and, thought_type[], dict, AND_node, AND, OR)
        end
    end
    return Dict(dict)
end

function apply_gamma(dict::Dict{and_type, Float64}, γ::Float64)::Dict{and_type, Any}
    # updated dict
    new_dict = Dict{and_type, Any}()
    for (k, v) in dict
        if v > 0
            new_dict[k] = v*(1-γ)^k[1]
        end
    end
    # probability of stopping
    new_dict[(0, (-10, (-10, -10), (-10, -10)))] = 1 - sum(values(new_dict))
    return new_dict
end

function process_dict(all_moves, dict, excl_moves::Vector{a_type})::Vector{Float64}
    # probability distribution over moves
    ps = Vector{Float64}()
    move_dict = Dict{a_type, Any}()
    # add all possible moves
    for move in all_moves
        if move == ((0, 0), (0, 0))
            break
        end
        move_dict[move] = 0.0
    end
    # stopping
    move_dict[((-10, -10), (-10, -10))] = 0.0
    # cycle
    move_dict[((-20, -20), (-20, -20))] = 0.0
    # exclude certain moves (e.g. moving same car)
    p_excl = 0
    for and_node in keys(dict)
        move = and_node[2][2:3]
        if move ∉ excl_moves
            move_dict[move] += dict[and_node]
        else
            p_excl += dict[and_node]
        end
    end
    # If exclusion move is reached, treat as cycle
    move_dict[(-20, -20), (-20, -20)] += p_excl
    # vectorize move probabilities
    for move in all_moves
        if move == ((0, 0), (0, 0))
            break
        end
        push!(ps, move_dict[move])
    end
    # probabilities without cycle
    Z = sum(ps) + move_dict[((-10, -10), (-10, -10))]
    # repeating because of cycle
    if Z > 0
        p_cycle = move_dict[((-20, -20), (-20, -20))]
        # spread proportionally over all other options
        ps += ps * p_cycle/Z
        move_dict[((-10, -10), (-10, -10))] += move_dict[((-10, -10), (-10, -10))] * p_cycle/Z
    else # if only cycles are possible (very rare condition) spread over all
        ps .+= move_dict[((-20, -20), (-20, -20))]/length(ps)
    end
    # spread stopping probability uniformly
    ps .+= move_dict[((-10, -10), (-10, -10))]/length(ps)
    return ps
end

function subject_nll(nlogγ::Float64, data, problems)::Float64
    γ = 10 ^ (-nlogγ)
    nll = 0
    for prb in eachindex(data)
        s = vector_to_s_type(problems[prb][1])
        s_goal = vector_to_s_type(problems[prb][2])
        prev_move = (0, 0)
        for move in data[prb]
            all_moves = get_all_moves(s)
            # excl_move_idx = findfirst(x -> x[2][1] == prev_move[1] && x[1][1] == prev_move[2], all_moves)
            # excl_move_idx = findall(x -> x[1][1] == prev_move[2], all_moves)
            # excl_moves = excl_move_idx !== nothing ? [all_moves[excl_move_idx]] : a_type[]
            excl_moves = [m for m in all_moves if m[1][1] == prev_move[2]]

            tree = get_and_or_tree(s, s_goal)
            dict = propagate_ps(0.0, tree)
            new_dict = apply_gamma(dict, γ)
            ps = process_dict(all_moves, new_dict, excl_moves)
            move_idx = findfirst(x -> x[1][1] == move[1] && x[2][1] == move[2], all_moves)
            nll += -log(ps[move_idx])
            prev_move = move

            s = make_move(s, move)
        end
    end
    return nll
end

function fit_all_subjects(data, problems)
    params = zeros(length(data))
    fitness = zeros(length(data))
    Threads.@threads for i in ProgressBar(eachindex(data))
        f = x -> subject_nll(x, data[i], problems)
        res = optimize(f, 0.0, 10.0)
        params[i] = Optim.minimizer(res)
        fitness[i] = Optim.minimum(res)
    end
    return params, fitness
end


params, fitness = fit_all_subjects(data, problems)