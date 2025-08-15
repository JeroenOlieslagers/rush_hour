
function load_tol_data()
    data = Vector{Vector{Tuple{Int, Int}}}[]
    rts = Vector{Vector{Int}}[]
    problems = []
    nn = 0
    for file in readdir("../games/data/tower_of_london/subject_data")
        if file == ".DS_Store" || file == "5fc2c0cfdb80f9025c6b4810_d2.csv" || file == "5eaf76ae6665cc671414ab73_d2.csv"
            continue
        end
        subj_data = CSV.read("../games/data/tower_of_london/subject_data/$file", DataFrame)
        if typeof(subj_data.tol_problem_id[1]) != String15
            continue
        end
        nn += 1
        games = Vector{Tuple{Int, Int}}[]
        subj_rts = Vector{Int}[]
        for i in 0:24
            game_i = subj_data[subj_data.tol_problem_id .== string(i), [:rt, :mouse_click, :current_position]]
            N, _ = size(game_i)
            moves = Tuple{Int, Int}[]
            game_rts = Int[]
            for j in 1:Int(N/2) 
                m_from = parse(Int, split(game_i[2*j - 1, :mouse_click], "_")[3])
                m_to = parse(Int, split(game_i[2*j, :mouse_click], "_")[3])
                if m_from == m_to
                    continue
                end
                push!(moves, (m_from, m_to))
                push!(game_rts, parse(Int, game_i[2*j, :rt]) + parse(Int, game_i[2*j, :rt]))
            end
            push!(games, moves)
            push!(subj_rts, game_rts)
            if nn == 1
                start_pos = [[0,0,0],[0,0],[0]]
                target_pos = [[0,0,0],[0,0],[0]]
                start_pos_ = game_i[1, :current_position]
                target_pos_ = game_i[N, :current_position]
                start_pos[1][1] = parse(Int, start_pos_[3])
                start_pos[1][2] = parse(Int, start_pos_[5])
                start_pos[1][3] = parse(Int, start_pos_[7])
                start_pos[2][1] = parse(Int, start_pos_[11])
                start_pos[2][2] = parse(Int, start_pos_[13])
                start_pos[3][1] = parse(Int, start_pos_[17])

                target_pos[1][1] = parse(Int, target_pos_[3])
                target_pos[1][2] = parse(Int, target_pos_[5])
                target_pos[1][3] = parse(Int, target_pos_[7])
                target_pos[2][1] = parse(Int, target_pos_[11])
                target_pos[2][2] = parse(Int, target_pos_[13])
                target_pos[3][1] = parse(Int, target_pos_[17])
                push!(problems, (start_pos, target_pos))
            end
        end
        push!(data, games)
        push!(rts, subj_rts)
    end
    return problems, data, rts
end

function vector_to_s_type(s)::s_type
    return ((s[1][1], s[1][2], s[1][3]), (s[2][1], s[2][2]), (s[3][1],))
end

function find_initial_moves(s::s_type, s_goal::s_type)::Vector{ap_type}
    moves = ap_type[]
    from = [(0, 0), (0, 0), (0, 0)]
    to = [(0, 0), (0, 0), (0, 0)]
    for i in eachindex(s)
        for j in eachindex(s[i])
            if s[i][j] > 0
                from[s[i][j]] = (i, j)
            end
            if s_goal[i][j] > 0
                to[s_goal[i][j]] = (i, j)
            end
        end
    end
    for i in eachindex(from)
        if from[i] != to[i]
            push!(moves, (1, from[i], to[i]))
        end
    end
    return moves
end

function moves_that_achives_subgoal(subgoal::thought_type, s::s_type, prev_move::ap_type)::Vector{ap_type}
    moves = ap_type[]
    bead, type, ii, jj = subgoal
    # find the bead in s
    for i in eachindex(s)
        for j in eachindex(s[i])
            # move bead to goal position
            if type == 1 && s[i][j] == bead
                push!(moves, (1, (i, j), (ii, jj)))
            end
            # move bead to other peg
            if type == -1 && i != ii && s[i][j] == 0 && (j == 1 || (j > 1 && s[i][j-1] > 0)) && prev_move[3][1] != i  && prev_move[2][1] != i
            # if type == -1 && i != ii && is_top_pos(s, i, j) && prev_move[3][1] != i  && prev_move[2][1] != i
                push!(moves, (-1, (ii, jj), (i, j)))
            end
            if type == -2 && i != ii && is_top_pos(s, i, j)
                push!(moves, (-1, (ii, jj), (i, j)))
            end
        end
    end
    return moves
end

function is_top_pos(s::s_type, ii::Int, jj::Int)::Bool
    highest = 0
    for j in eachindex(s[ii])
        if s[ii][j] != 0
            highest = j
        end
    end
    if highest == length(s[ii])
        return jj == highest
    elseif highest == 0
        return jj == 1
    else
        return jj == highest+1
    end
end

function get_blocking_nodes(move::ap_type, s::s_type, s_goal::s_type)::Vector{thought_type}
    nodes = thought_type[]
    # peg that is being moved from
    ii = move[2][1]
    for j in eachindex(s[ii])
        # which beads are above, blocking the move
        if j > move[2][2] && s[ii][j] != 0
            push!(nodes, (s[ii][j], -2, ii, j))
        end
    end
    # peg that is being moved onto
    ii = move[3][1]
    for j in eachindex(s[ii])
        # which beads are blocking the move
        if j == move[3][2] && s[ii][j] != 0
            push!(nodes, (s[ii][j], -1, ii, j))
        end
        # if move is a placing move, consider beads below
        # which beads must be moved below first
        if move[1] == 1 && move[3][2] > j
            if s[ii][j] != s_goal[ii][j]
                push!(nodes, (s_goal[ii][j], 1, ii, j))
            end
        end
    end
    return unique(nodes)
end

function get_all_moves(s::s_type)::Vector{a_type}
    moves = a_type[]
    avail = Set{Tuple{Int, Int}}()
    from = Tuple{Int, Int}[]
    for i in eachindex(s)
        dummy = (0, 0)
        for j in reverse(eachindex(s[i]))
            if s[i][j] == 0
                dummy = (i, j)
            end
            if s[i][j] != 0
                push!(from, (i, j))
                break
            end
        end
        if dummy != (0, 0)
            push!(avail, dummy)
        end
    end
    for f in from
        for to in avail
            if f[1] != to[1]
                push!(moves, (f, to))
            end
        end
    end
    return moves
end

function make_move(s::s_type, move::Tuple{Int, Int})::s_type
    s_new = []
    bead_no = nothing
    for i in eachindex(s)
        s_new_i = Int[]
        broken = false
        for j in reverse(eachindex(s[i]))
            if i == move[1] && !broken && s[i][j] != 0
                pushfirst!(s_new_i, 0)
                bead_no = s[i][j]
                broken = true
            else
                pushfirst!(s_new_i, s[i][j])
            end
        end
        push!(s_new, s_new_i)
    end
    for j in eachindex(s_new[move[2]])
        if s_new[move[2]][j] == 0
            s_new[move[2]][j] = bead_no
            break
        end
    end
    return tuple([tuple(s_new_i...) for s_new_i in s_new]...)
end

function search(s_goal::s_type; max_iters=10000)
    frontier = s_type[]
    visited = Set{s_type}()
    distances = Dict{s_type, Int}()
    distances[s_goal] = 0
    push!(visited, s_goal)
    push!(frontier, s_goal)
    for _ in 1:max_iters
        if isempty(frontier)
            return distances
        end
        s = popfirst!(frontier)
        d = distances[s]
        all_moves = get_all_moves(s)
        for move in all_moves
            move_ = (move[1][1], move[2][1])
            new_s = make_move(s, move_)
            if new_s ∉ visited
                push!(frontier, new_s)
                push!(visited, new_s)
                distances[new_s] = d + 1
            end
        end
    end
    throw(DomainError("max_iter depth reached"))
end

function bfs(s::s_type; max_iters=10000)
    frontier = s_type[]
    visited = Set{s_type}()
    push!(visited, s)
    push!(frontier, s)
    for _ in 1:max_iters
        if isempty(frontier)
            return visited
        end
        s = popfirst!(frontier)
        all_moves = get_all_moves(s)
        for move in all_moves
            move_ = (move[1][1], move[2][1])
            new_s = make_move(s, move_)
            if new_s ∉ visited
                push!(frontier, new_s)
                push!(visited, new_s)
            end
        end
    end
    throw(DomainError("max_iter depth reached"))
end




# problems = load("../games/data/tower_of_london/problems.jld2")["problems"];
# _, data, rts = load_tol_data();



# s = vector_to_s_type(problems[4][1])
# s_goal = vector_to_s_type(problems[4][2])

# moves = find_initial_moves(s, s_goal)

# subgoals = get_blocking_nodes(moves[2], s, s_goal)

# moves1 = moves_that_achives_subgoal(subgoals[1], s, moves[2])

# subgoals1 = get_blocking_nodes(moves1[1], s, s_goal)

# moves2 = moves_that_achives_subgoal(subgoals1[1], s)

# subgoals2 = get_blocking_nodes(moves2[1], s, s_goal)