
function get_and_or_tree(s::s_type; max_iter=100)
    # keeps track of current train of thought nodes visited
    train_of_thought = Vector{thought_type}()
    # keeps track of parents of leaf nodes
    parents_moves = DefaultDict{a_type, Vector{and_type}}([])
    # forward pass (children)
    AND = DefaultDict{and_type, Vector{or_type}}([])
    OR = DefaultDict{or_type, Vector{and_type}}([])
    # initialize process
    arr = board_to_arr(s)
    s_free, s_fixed = s
    # ultimate goal move
    m_init = 6 - (s_free[1]+1)
    root_move = (Int8(1), Int8(m_init))
    first_thought = MVector{5, Int8}(1, m_init, 0, 0, 0)
    push!(train_of_thought, first_thought)
    # Root OR
    OR_root = (Int8(1), first_thought)
    # Root AND
    AND_root = (Int8(1), root_move)
    push!(OR[OR_root], AND_root)
    # Get first child nodes
    blocked_cars = zeros(blocked_cars_type)
    move_amounts = zeros(move_amounts_type)
    blocking_nodes = zeros(Int8, 4, 5)
    get_blocking_nodes!(blocking_nodes, blocked_cars, move_amounts, s, arr, root_move)
    # all possible moves from start position
    moves = @MVector([(Int8(0), Int8(0)) for _ in 1:(4*9)])
    possible_moves!(moves, s, arr)
    # Tree with all info
    AND_OR_tree = [AND_root, AND, OR, parents_moves]#, idv_AND, idv_OR , parents_AND, parents_OR]
    # Expand tree and recurse
    add_to_tree!(AND_root, blocking_nodes, blocked_cars, move_amounts, train_of_thought, moves, AND_OR_tree, s, arr, Int8(0); max_iter=max_iter)
    AND_root, AND, OR, parents_moves = AND_OR_tree
    AND_OR_tree = [AND_root, Dict(AND), Dict(OR), Dict(parents_moves)]
    return AND_OR_tree
end

function add_to_tree!(prev_AND::and_type, blocking_nodes::blocking_nodes_type, blocked_cars::blocked_cars_type, move_amounts::move_amounts_type, train_of_thought::Vector{thought_type}, moves::moves_type, AND_OR_tree, s::s_type, arr::arr_type, recursion_depth::Int8; max_iter=100)::Nothing
    AND_root, AND, OR, parents_moves = AND_OR_tree
    if recursion_depth > max_iter
        throw(DomainError("max_iter depth reached"))
        return nothing
    end
    d, move = prev_AND
    # recurse all children
    for node in eachrow(blocking_nodes)
        if node[1] == 0
            break
        end
        or_node = (d+1, node)
        if or_node ∉ AND[prev_AND]
            push!(AND[prev_AND], or_node)
        end
        if node in train_of_thought
            continue
        end
        # loop over next set of OR nodes
        for j in 2:lastindex(node)
            if node[j] == 0
                break
            end
            next_move = (node[1], node[j])

            new_blocking_nodes = copy(blocking_nodes)
            get_blocking_nodes!(new_blocking_nodes, blocked_cars, move_amounts, s, arr, next_move)
            # move is impossible
            if new_blocking_nodes[1, 1] == -1
                continue
            end

            and_node = (Int8(d+1), next_move)
            if and_node ∉ OR[or_node]
                push!(OR[or_node], and_node)
            end

            if new_blocking_nodes[1, 1] == 0
                leaf = (d+1, zeros(thought_type))
                if leaf ∉ AND[and_node]
                    push!(AND[and_node], leaf)
                end
                if and_node ∉ parents_moves[next_move]
                    push!(parents_moves[next_move], and_node)
                end
                continue
            end
            # we copy because we dont want the same nodes in a chain,
            # but across same chain (at different depths) we can have the same node repeat
            new_train_of_thought = copy(train_of_thought)
            push!(new_train_of_thought, node)
            add_to_tree!(and_node, new_blocking_nodes, blocked_cars, move_amounts, new_train_of_thought, moves, AND_OR_tree, s, arr, Int8(recursion_depth + 1); max_iter=max_iter)
        end
    end
    return nothing
end

function get_blocking_nodes!(blocking_nodes::blocking_nodes_type, blocked_cars::blocked_cars_type, move_amounts::move_amounts_type, s::s_type, arr::arr_type, move::a_type)::Nothing
    fill!(blocking_nodes, 0)
    # get all blocking cars
    move_blocked_by!(blocked_cars, move, s, arr)
    for i in eachindex(blocked_cars)
        # Get all OR nodes of next layer
        id2 = blocked_cars[i]
        if id2 == 0
            break
        end
        unblocking_moves!(move_amounts, move, id2, s)
        # If no possible moves, end iteration for this move
        if sum(move_amounts) == 0
            fill!(blocking_nodes, -1)
            break
        end
        # new ao state
        blocking_nodes[i, 1] = id2
        for j in eachindex(move_amounts)
            blocking_nodes[i, j+1] = move_amounts[j]
        end
    end
    return nothing
end
