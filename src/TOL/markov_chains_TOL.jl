


function get_QR(states, s_goal)
    t = typeof(first(states))
    transient_states = Set{t}()
    absorbing_states = Set{t}()
    for s in states
        if s == s_goal
            push!(absorbing_states, s)
        else
            push!(transient_states, s)
        end
    end
    N_t = length(transient_states)
    N_a = length(absorbing_states)+1
    state_to_idx = Dict{t, Int}()
    for (n, s) in enumerate(transient_states)
        state_to_idx[s] = n
    end
    for (n, s) in enumerate(absorbing_states)
        state_to_idx[s] = -n
    end
    Q = zeros(N_t, N_t)
    R = zeros(N_t, N_a)
    for s in transient_states
        id_from = state_to_idx[s]
        moves = get_all_moves(s)
        N_n = 0
        for move in moves
            m = (move[1][1], move[2][1])
            sp = make_move(s, m)
            id_to = state_to_idx[sp]
            if sp in absorbing_states
                R[id_from, -id_to] += 1
            else
                Q[id_from, id_to] += 1
            end
            N_n += 1
        end
        Q[id_from, :] ./= N_n
        R[id_from, :] ./= N_n
    end
    return Q, R, state_to_idx
end

function get_QR_dict(problems)
    dict = Dict()
    for i in ProgressBar(eachindex(problems))
        prb = problems[i]
        s = vector_to_s_type(prb[1])
        s_goal = vector_to_s_type(prb[2])
        visited = bfs(s)
        Q, R, state_to_idx = get_QR(visited, s_goal)
        dict[i] = [sparse(Q), sparse(R), state_to_idx]
    end
    return dict
end

function get_mc_dict(df, params, dict)
    subjs = unique(df.subject)
    mc_dict = Dict{Int64, Dict{Int64, Vector{Float64}}}()
    for (m, subj) in ProgressBar(enumerate(subjs))
        subj_dict = Dict{Int64, Vector{Float64}}()
        log_gamma, k = params[m, :]
        γ = exp(-log_gamma)
        subj_df = df[df.subject .== subjs[m], :];
        for prb in unique(subj_df.puzzle)
            Q, R, state_to_idx = dict[prb]
            F = apply_gamma(Q, R, γ)
            subj_dict[prb] = F
        end
        mc_dict[subj] = subj_dict
    end
    return mc_dict
end

function apply_gamma(Q::SparseMatrixCSC{Float64, Int64}, R::SparseMatrixCSC{Float64, Int64}, γ::Float64)::Vector{Float64}
    Rp = γ*ones(size(R, 1))
    B = (I - (1-γ)*Q)\Rp
    return B
end

function p_a(ks::Vector{Int}, ns::Vector{s_type}, F::Vector{Float64}, state_to_idx::Dict{s_type, Int64})::Vector{Vector{Float64}}
    m = length(ns)
    p_success = zeros(m)
    for (n, neigh) in enumerate(ns)
        idx = state_to_idx[neigh]
        if idx < 0
            p_success[n] = 1 / m
        else
            p_success[n] = (1 - F[state_to_idx[neigh]]) / m
        end
    end
    p_fail = 1 - sum(p_success)
    if p_fail == 1
        ps = [ones(m) ./ m for k in ks]
    else
        ps = [(p_success .* (1 - (p_fail .^ k))/(1 - p_fail)) .+ (p_fail .^ k/m) for k in ks]
    end
    return ps
end

function df_to_dict(subj_df)
    neighs_dict = DefaultDict{Int64, Vector{Vector{s_type}}}([])
    moves_dict = DefaultDict{Int64, Vector{a_type}}([])
    all_moves_dict = DefaultDict{Int64, Vector{Vector{a_type}}}([])
    s_dict = DefaultDict{Int64, Vector{s_type}}([])
    for row in eachrow(subj_df)
        prb = row.puzzle
        push!(neighs_dict[prb], row.neighs)
        push!(moves_dict[prb], row.move)
        push!(all_moves_dict[prb], row.all_moves)
        push!(s_dict[prb], row.s)
    end
    return Dict(neighs_dict), Dict(moves_dict), Dict(all_moves_dict), Dict(s_dict)
end

function subj_nll_mc(params, neighs_dict::Dict, moves_dict::Dict, all_moves_dict::Dict, dict::Dict, ks::Vector{Int}; return_all=false)#::Float64
    log_gamma = params
    γ = exp(-log_gamma)
    nll = zeros(length(ks))
    for prb in keys(moves_dict)
        neighs = neighs_dict[prb]
        moves = moves_dict[prb]
        all_moves = all_moves_dict[prb]
        Q, R, state_to_idx = dict[prb]
        F = apply_gamma(Q, R, γ)
        for i in eachindex(moves)
            ps = p_a(ks, neighs[i], F, state_to_idx)
            idx = findfirst(x-> x == moves[i], all_moves[i])
            for (n, pps) in enumerate(ps)
                if moves[i] isa Vector
                    for m in moves[i]
                        p = pps[findfirst(x-> x == m, all_moves[i])]
                        nll[n] -= log(p)
                    end
                else
                    p = pps[idx]
                    nll[n] -= log(p)
                end
            end
        end
    end
    if return_all
        return nll
    else
        return minimum(nll)
    end
end


# dict = get_QR_dict(problems)
# mc_dict = get_mc_dict(df, params, dict)

# subj_df = df[df.subject .== 1, :]
# neighs_dict, moves_dict, all_moves_dict, s_dict = df_to_dict(subj_df)

# subj_nll_mc(0.609181, neighs_dict, moves_dict, all_moves_dict, dict, [10000])