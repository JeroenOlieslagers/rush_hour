

s_type = Tuple{Tuple{Int64, Int64, Int64}, Tuple{Int64, Int64}, Tuple{Int64}}
ap_type = Tuple{Int, Tuple{Int, Int}, Tuple{Int, Int}}
a_type = Tuple{Tuple{Int, Int}, Tuple{Int, Int}}

thought_type = Tuple{Int, Int, Int, Int}# (bead, type, ii, jj)
or_type = Tuple{Int, thought_type}# depth, subgoal
and_type = Tuple{Int, ap_type}# depth, move

function get_and_or_tree(s::s_type, s_goal::s_type; max_iter=10)
    # keeps track of parents of leaf nodes
    parents_moves = DefaultDict{a_type, Vector{and_type}}([])
    # forward pass (children)
    AND = DefaultDict{and_type, Vector{or_type}}([])
    OR = DefaultDict{or_type, Vector{and_type}}([])
    # ultimate goal moves
    OR_root = (1, (0, 0, 0, 0))
    moves = find_initial_moves(s, s_goal)
    for move in moves
        AND_node = (1, move)
        push!(OR[OR_root], AND_node)
        # Tree with all info
        AND_OR_tree = [AND, OR, parents_moves]
        # Expand tree and recurse
        add_to_tree!(AND_node, thought_type[], AND_OR_tree, s, s_goal, 0; max_iter=max_iter)
    end
    AND, OR, parents_moves = AND_OR_tree
    AND_OR_tree = [Dict(AND), Dict(OR), Dict(parents_moves)]
    return AND_OR_tree
end

function add_to_tree!(prev_AND::and_type, ToT::Vector{thought_type}, AND_OR_tree, s::s_type, s_goal::s_type, recursion_depth::Int; max_iter=100)::Nothing
    AND, OR, parents_moves = AND_OR_tree
    if recursion_depth > max_iter
        throw(DomainError("max_iter depth reached"))
        return nothing
    end
    d, move = prev_AND
    # recurse all children
    subgoals = get_blocking_nodes(move, s, s_goal)
    if isempty(subgoals)
        real_move = (move[2], move[3])
        if prev_AND ∉ parents_moves[real_move]
            push!(parents_moves[real_move], prev_AND)
        end
        # leaf = (d, 0, (0, 0), (0, 0))
        # if leaf ∉ AND[prev_AND]
        #     push!(OR[prev_AND], leaf)
        # end
    end
    for subgoal in subgoals
        OR_node = (d+1, subgoal)
        if OR_node ∉ AND[prev_AND]
            push!(AND[prev_AND], OR_node)
        end
        if subgoal in ToT
            continue
        end
        next_moves = moves_that_achives_subgoal(subgoal, s, move)
        for next_move in next_moves
            AND_node = (d+1, next_move)
            if AND_node ∉ OR[OR_node]
                push!(OR[OR_node], AND_node)
            end
            new_ToT = copy(ToT)
            push!(new_ToT, subgoal)
            # loop over next set of OR nodes
            add_to_tree!(AND_node, new_ToT, AND_OR_tree, s, s_goal, recursion_depth+1; max_iter=max_iter)
        end
    end
    return nothing
end


# p = 3, 6, 13, 16, 17, 21, 22
# p = 23
# p = 25
# s = vector_to_s_type(problems[p][1])
# s = ((2, 0, 0), (1, 0), (3,))
# s = ((1, 0, 0), (3, 0), (2,))
# s_goal = vector_to_s_type(problems[p][2])
# countmap([data[i][p][1] for i in eachindex(data)])


# draw_state(s, s_goal)

# AND, OR, _ = get_and_or_tree(s, s_goal);
# draw_ao_tree(AND, OR)