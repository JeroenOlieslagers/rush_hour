
fig2A(problems)
fig2C(problems)
fig2D(df)

fig4_tol(binned_stats)
fig4(binned_stats_rh)

fig5(df_stats)

fig6AD(binned_stats)
fig6EF(df_stats)
fig6GI(binned_stats)

fig7(df_models)


fig_ext2(df)
fig_ext3(df)
fig_ext4(df, d_goals_prbs)

fig_ext6(binned_stats)
fig_ext7(df_stats)
fig_ext8(binned_stats)

TOL_COLOR = :blue
RH_COLOR = :red

# MAIN TEXT FIGURES

function fig2A(problems)
    p = 13
    s = vector_to_s_type(problems[p][1])
    s_goal = vector_to_s_type(problems[p][2])
    draw_state(s, s_goal)
end

function fig2C(problems)
    p = 13
    s = vector_to_s_type(problems[p][1])
    s_goal = vector_to_s_type(problems[p][2])
    AND, OR, _ = get_and_or_tree(s, s_goal)
    draw_ao_tree(AND, OR)
end

# ls = []
# for p in 1:25
#     s = vector_to_s_type(problems[p][1])
#     push!(ls, d_goals_prbs[p][s])
# end

function fig2D(df)
    plot(size=(350, 400), layout=grid(2, 2), grid=false, dpi=300, xflip=false,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=3Plots.mm, top_margin=0Plots.mm, bottom_margin=0Plots.mm, left_margin=0Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, link=:y)

    xticks = [[0, 5, 10, 15], [0, 10, 20, 30], [0, 10, 20, 30], [0, 10, 20, 30]]
    yticks = [[0, 3, 6, 9], [], [0, 3, 6, 9], []]
    titles = ["Length 3", "Length 4", "Length 6", "Length 7"]
    ylabels = ["Distance to goal" "" "Distance to goal" ""]
    xlabels = ["Move number" "Move number" "Move number" "Move number"]

    for (n, prb) in enumerate([1, 3, 9, 5])
        for subj in unique(df.subject)
            df_subj = df[df.subject .== subj .&& df.puzzle .== prb, :]
            plot!(vcat(df_subj.d_goal, 0), sp=n, label=nothing, c=:black, alpha=0.05, xticks=xticks[n], yticks=yticks[n], xlim=(0, Inf), ylim=(0, 9), ylabel=ylabels[n], xlabel=xlabels[n], title=titles[n])
        end
    end
    display(plot!())
end

function fig4(binned_stats)
    models = ["data", "random_model", "random_model"]
    DVs = ["y_p_in_tree", "y_p_in_tree", "y_d_tree"]
    IDV = "X_d_goal"
    d = length(DVs)
    l = @layout [grid(1, d); a{0.001h}];
    plot(size=(600, 250), grid=false, layout=l, dpi=300, xflip=true,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=2Plots.mm, top_margin=1Plots.mm, bottom_margin=7Plots.mm, left_margin=7Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, xlim=(0, 8));

    ylabels = ["Prop. sensible \nactions (human)" "Prop. sensible \nactions (all)" "Average depth \n of sensible action"];
    ytickss = [[0.7, 0.8, 0.9, 1.0], [0.3, 0.4, 0.5, 0.6, 0.7], [1.0, 1.5, 2.0]]
    ylimss = [(0.65, 1.02), (0.2, 0.75), (0.8, 2.3)]

    for i in 1:d
        df_model = binned_stats[binned_stats.model .== models[i], :]
        sort!(df_model, :bin_number)
        ylabel = ylabels[i]
        title = ""
        yticks = ytickss[i]
        ylims = ylimss[i]
        sp = i
        plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], yerr=df_model[:, "sem_"*DVs[i]], sp=sp, c=:black, msw=1.4, label=nothing, xflip=true, linewidth=1, markershape=:none, ms=4, title=title, ylabel=ylabel, yticks=yticks, ylims=ylims)
    end
    plot!(xlabel="Distance to goal", showaxis=false, grid=false, sp=d + 1, top_margin=-15Plots.mm, bottom_margin=7Plots.mm)
    display(plot!())
end

function fig4_joint(binned_stats, binned_stats_rh)
    models = ["data", "random_model", "random_model"]
    DVs = ["y_p_in_tree", "y_p_in_tree", "y_d_tree"]
    IDV = "X_d_goal"
    d = length(DVs)
    # l = @layout [grid(2, d); a{0.001h}];
    l = @layout [grid(2, d)];
    plot(size=(372*2 - 50*2, 400), grid=false, layout=l, dpi=300, xflip=true,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=2Plots.mm, top_margin=1Plots.mm, bottom_margin=7Plots.mm, left_margin=7Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, background_color_legend=nothing, foreground_color_legend=nothing, legend=:topleft);

    ylabels = ["Prop. sensible \nactions (human)" "Prop. sensible \nactions (all)" "Average depth \n of sensible action"];
    # ytickss = [[0.7, 0.8, 0.9, 1.0], [0.2, 0.4, 0.6], [1.0, 2.0, 3.0, 4.0, 5.0]]
    # ylimss = [(0.68, 1.02), (0.15, 0.7), (0.8, 5.3)]

    ytickss = [[0.7, 0.8, 0.9, 1.0], [0.3, 0.4, 0.5, 0.6, 0.7], [1.0, 1.5, 2.0]]
    ylimss = [(0.65, 1.02), (0.2, 0.75), (0.8, 2.3)]

    ytickss_rh = [[0.8, 0.9, 1.0], [0.2, 0.4, 0.6], [2.0, 3.0, 4.0, 5.0]]
    ylimss_rh = [(0.75, 1.0), (0.15, 0.7), (2, 5.3)]

    for i in 1:d
        df_model = binned_stats[binned_stats.model .== models[i], :]
        df_model_rh = binned_stats_rh[binned_stats_rh.model .== models[i], :]
        sort!(df_model, :bin_number)
        sort!(df_model_rh, :bin_number)
        ylabel = ylabels[i]
        title = ""
        yticks = ytickss[i]
        ylims = ylimss[i]
        sp = i
        plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], yerr=df_model[:, "sem_"*DVs[i]], sp=sp, c=:black, msw=1.4, label=nothing, xflip=true, linewidth=1, markershape=:none, ms=4, title=title, ylabel=ylabel, yticks=yticks, ylims=ylims, xlims=(0, 8), xlabel="Distance to goal")
        # plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], yerr=df_model[:, "sem_"*DVs[i]], sp=sp, c=TOL_COLOR, markercolor=TOL_COLOR, msc=TOL_COLOR, msw=1.4, label=nothing, xflip=true, linewidth=1, markershape=:none, ms=4)
        plot!(df_model_rh[:, "m_"*IDV], df_model_rh[:, "m_"*DVs[i]], yerr=df_model_rh[:, "sem_"*DVs[i]], sp=sp+3, c=:black, msw=1.4, label=nothing, xflip=true, linewidth=1, markershape=:none, ms=4, title=title, ylabel=ylabel, yticks=ytickss_rh[i], ylims=ylimss_rh[i], xlims=(0, 16), xlabel="Distance to goal")
        # plot!(df_model_rh[:, "m_"*IDV], df_model_rh[:, "m_"*DVs[i]], yerr=df_model_rh[:, "sem_"*DVs[i]], sp=sp, c=RH_COLOR, markercolor=RH_COLOR, msc=RH_COLOR, msw=1.4, label=nothing, xflip=true, linewidth=1, markershape=:none, ms=4, title=title, ylabel=ylabel, yticks=yticks, ylims=ylims)
    end
    # plot!([], [], sp=1, linewidth=3, c=TOL_COLOR, label="TOL")
    # plot!([], [], sp=1, linewidth=3, c=RH_COLOR, label="RH")
    #plot!(xlabel="Distance to goal", showaxis=false, grid=false, sp=2*d + 1, top_margin=-15Plots.mm, bottom_margin=7Plots.mm)
    display(plot!())
end

function fig5(df_stats)
    plot(layout=grid(1, 3), grid=false, legend=nothing, size=(600, 250), dpi=300,
            legendfont=font(12, "helvetica"), 
            xtickfont=font(10, "helvetica"), 
            ytickfont=font(10, "helvetica"), 
            titlefont=font(12, "helvetica"), 
            guidefont=font(12, "helvetica"), 
            right_margin=2Plots.mm, top_margin=0Plots.mm, bottom_margin=7Plots.mm, left_margin=4Plots.mm, 
            fontfamily="helvetica", tick_direction=:out)

    # We only care about the participants' data
    df_ = df_stats[df_stats.model .== "data", :]
    # Bin by whether move is first move or not
    binned_stats = bin_stats(df_, :X_first_move; nbins=2)
    sort!(binned_stats, :bin_number, rev=true)
    rts = binned_stats[binned_stats.model .== "data", :m_X_rt] ./ 1000
    rts_err = binned_stats[binned_stats.model .== "data", :sem_X_rt] ./ 1000
    bar!(["First\naction", "Other\nactions"], rts, bar_width=0.5, color=nothing, sp=1, yerr=rts_err, grid=false, label=nothing, ylabel="Response time (s)", xlim=(0, 2), yscale=:log10, fillrange=0.7, yminorticks=true, ylim=(0.7, 8), yticks=([1, 5], ["1", "5"]))
    # This is to get individual participant data
    binned_stats = bin_stats(df_, :X_first_move; nbins=2, subject_level=true)
    rts1 = binned_stats[binned_stats.bin_number .== 1, :mean_X_rt] ./ 1000
    rts2 = binned_stats[binned_stats.bin_number .== 2, :mean_X_rt] ./ 1000
    for i in unique(df_.subject)
        plot!(["First\naction", "Other\nactions"], [rts2[i], rts1[i]], sp=1, label=nothing, c=:black, alpha=0.05)
    end
    # Bin by distance to goal for non-first moves
    binned_stats = bin_stats(df_[df_.X_first_move .== 0, :], :X_d_goal; nbins=5)
    sort!(binned_stats, :bin_number)
    plot!(binned_stats[:, :m_X_d_goal], binned_stats[:, :m_X_rt], sp=2, yerr=binned_stats[:, :sem_X_rt], label=nothing, ylim=(1000, 3000), yticks=[1000, 2000, 3000], msw=1.4, ms=4, linewidth=1, markershape=:none, c=:black, xflip=true, xlabel="Distance to goal", ylabel="Response time (ms)", xlim=(0, 8), yminorticks=true)
    # Bin by depth in tree for sensible moves
    binned_stats = bin_stats(df_[df_.y_p_in_tree .== 1, :], :y_d_tree; nbins=2)
    sort!(binned_stats, :bin_number)
    plot!(binned_stats[:, :m_y_d_tree], binned_stats[:, :m_X_rt], sp=3, yerr=binned_stats[:, :sem_X_rt], label=nothing, ylim=(1350, 2500), yticks=[1500, 2000, 2500], msw=1.4, ms=4, linewidth=1, markershape=:none, c=:black, xflip=true, xlabel="Depth in tree", ylabel="Response time (ms)", xlim=(0, 3), yminorticks=true)
    display(plot!())
end

function fig5_joint(df_stats, df_stats_rh)
    plot(layout=grid(2, 3), grid=false, size=(372*2 - 50*2, 450), dpi=300,
            legendfont=font(12, "helvetica"), 
            xtickfont=font(10, "helvetica"), 
            ytickfont=font(10, "helvetica"), 
            titlefont=font(12, "helvetica"), 
            guidefont=font(12, "helvetica"), 
            right_margin=2Plots.mm, top_margin=0Plots.mm, bottom_margin=7Plots.mm, left_margin=4Plots.mm, 
            fontfamily="helvetica", tick_direction=:out, background_color_legend=nothing, foreground_color_legend=nothing, legend=:topleft)

    # We only care about the participants' data
    df_ = df_stats[df_stats.model .== "data", :]
    df__rh = df_stats_rh[df_stats_rh.model .== "data", :]
    # Bin by whether move is first move or not
    binned_stats = bin_stats(df_, :X_first_move; nbins=2)
    binned_stats_rh = bin_stats(df__rh, :X_first_move; nbins=2)
    sort!(binned_stats, :bin_number, rev=true)
    sort!(binned_stats_rh, :bin_number, rev=true)
    rts = binned_stats[binned_stats.model .== "data", :m_X_rt] ./ 1000
    rts_rh = binned_stats_rh[binned_stats_rh.model .== "data", :m_X_rt] ./ 1000
    rts_err = binned_stats[binned_stats.model .== "data", :sem_X_rt] ./ 1000
    rts_err_rh = binned_stats_rh[binned_stats_rh.model .== "data", :sem_X_rt] ./ 1000
    bar!(["First\naction", "Other\nactions"], rts, bar_width=0.5, color=nothing, sp=1, yerr=rts_err, grid=false, label=nothing, ylabel="Response time (s)", xlim=(0, 2), yscale=:log10, fillrange=0.7, yminorticks=true, ylim=(0.7, 8), yticks=([1, 5], ["1", "5"]))
    # bar!(["First\naction", "Other\nactions"], rts, bar_width=0.5, fillcolor=nothing, title="TOL", linecolor=TOL_COLOR, markercolor=TOL_COLOR, msc=TOL_COLOR, sp=1, yerr=rts_err, grid=false, label=nothing, ylabel="Response time (s)", xlim=(0, 2), yscale=:log10, fillrange=0.7, yminorticks=true, ylim=(0.7, 22), yticks=([1, 10], ["1", "10"]))
    bar!(["First\naction", "Other\nactions"], rts_rh, bar_width=0.5, color=nothing, sp=4, yerr=rts_err_rh, grid=false, label=nothing, ylabel="Response time (s)", xlim=(0, 2), yscale=:log10, fillrange=0.9, yminorticks=true, yticks=([1, 10], ["1", "10"]))
    # bar!(["First\naction", "Other\nactions"], rts_rh, bar_width=0.5, fillcolor=nothing, title="RH", linecolor=RH_COLOR, markercolor=RH_COLOR, msc=RH_COLOR, sp=4, yerr=rts_err_rh, grid=false, label=nothing, xlim=(0, 2), yscale=:log10, fillrange=0.7, yminorticks=true, ylim=(0.7, 22), yticks=([1, 10], ["1", "10"]))
    # This is to get individual participant data
    binned_stats = bin_stats(df_, :X_first_move; nbins=2, subject_level=true)
    binned_stats_rh = bin_stats(df__rh, :X_first_move; nbins=2, subject_level=true)
    rts1 = binned_stats[binned_stats.bin_number .== 1, :mean_X_rt] ./ 1000
    rts1_rh = binned_stats_rh[binned_stats_rh.bin_number .== 1, :mean_X_rt] ./ 1000
    rts2 = binned_stats[binned_stats.bin_number .== 2, :mean_X_rt] ./ 1000
    rts2_rh = binned_stats_rh[binned_stats_rh.bin_number .== 2, :mean_X_rt] ./ 1000
    for i in eachindex(rts1)
        plot!(["First\naction", "Other\nactions"], [rts2[i], rts1[i]], sp=1, label=nothing, c=:black, alpha=0.05)
    end
    for i in eachindex(rts1_rh)
        plot!(["First\naction", "Other\nactions"], [rts2_rh[i], rts1_rh[i]], sp=4, label=nothing, c=:black, alpha=0.05)
    end
    # Bin by distance to goal for non-first moves
    binned_stats = bin_stats(df_[df_.X_first_move .== 0, :], :X_d_goal; nbins=5)
    binned_stats_rh = bin_stats(df__rh[df__rh.X_first_move .== 0, :], :X_d_goal; nbins=10)
    sort!(binned_stats, :bin_number)
    sort!(binned_stats_rh, :bin_number)
    plot!(binned_stats[:, :m_X_d_goal], binned_stats[:, :m_X_rt], sp=2, yerr=binned_stats[:, :sem_X_rt], label=nothing, ylim=(1000, 3000), yticks=[1000, 2000, 3000], msw=1.4, ms=4, linewidth=1, markershape=:none, c=:black, xflip=true, xlabel="Distance to goal", ylabel="Response time (ms)", xlim=(0, 8), yminorticks=true)
    # plot!(binned_stats[:, :m_X_d_goal], binned_stats[:, :m_X_rt], sp=2, yerr=binned_stats[:, :sem_X_rt], label=nothing, msw=1.4, ms=4, linewidth=1, markershape=:none, c=TOL_COLOR, markercolor=TOL_COLOR, msc=TOL_COLOR, xflip=true, xlabel="Distance to goal", ylabel="Response time (ms)", yminorticks=true)
    plot!(binned_stats_rh[:, :m_X_d_goal], binned_stats_rh[:, :m_X_rt], sp=5, yerr=binned_stats_rh[:, :sem_X_rt], label=nothing, ylim=(800, 2400), yticks=[1000, 1500, 2000], msw=1.4, ms=4, linewidth=1, markershape=:none, c=:black, xflip=true, xlabel="Distance to goal", ylabel="Response time (ms)", xlim=(0, 16), yminorticks=true)
    # plot!(binned_stats_rh[:, :m_X_d_goal], binned_stats_rh[:, :m_X_rt], sp=5, yerr=binned_stats_rh[:, :sem_X_rt], label=nothing, ylim=(800, 3000), yticks=[1000, 2000, 3000], msw=1.4, ms=4, linewidth=1, markershape=:none, c=RH_COLOR, markercolor=RH_COLOR, msc=RH_COLOR, xflip=true, xlabel="Distance to goal", ylabel="Response time (ms)", xlim=(0, 16), yminorticks=true)
    #plot!([], [], sp=3, linewidth=3, c=TOL_COLOR, label="TOL")
    #plot!([], [], sp=3, linewidth=3, c=RH_COLOR, label="RH")
    # Bin by depth in tree for sensible moves
    binned_stats = bin_stats(df_[df_.y_p_in_tree .== 1, :], :y_d_tree; nbins=2)
    binned_stats_rh = bin_stats(df__rh[df__rh.y_p_in_tree .== 1, :], :y_d_tree; nbins=7)
    sort!(binned_stats, :bin_number)
    sort!(binned_stats_rh, :bin_number)
    plot!(binned_stats[:, :m_y_d_tree], binned_stats[:, :m_X_rt], sp=3, yerr=binned_stats[:, :sem_X_rt], label=nothing, ylim=(1350, 2500), yticks=[1500, 2000, 2500], msw=1.4, ms=4, linewidth=1, markershape=:none, c=:black, xflip=true, xlabel="Depth in tree", ylabel="Response time (ms)", xlim=(0, 3), yminorticks=true)
    # plot!(binned_stats[:, :m_y_d_tree], binned_stats[:, :m_X_rt], sp=3, yerr=binned_stats[:, :sem_X_rt], label=nothing, msw=1.4, ms=4, linewidth=1, markershape=:none, c=TOL_COLOR, markercolor=TOL_COLOR, msc=TOL_COLOR, xflip=true, xlabel="Depth in tree", ylabel="Response time (ms)", yminorticks=true)
    plot!(binned_stats_rh[:, :m_y_d_tree], binned_stats_rh[:, :m_X_rt], sp=6, yerr=binned_stats_rh[:, :sem_X_rt], label=nothing, ylim=(1350, 2550), yticks=[1500, 2000, 2500], msw=1.4, ms=4, linewidth=1, markershape=:none, c=:black, xflip=true, xlabel="Depth in tree", ylabel="Response time (ms)", xlim=(1.5, 6.7), yminorticks=true)
    # plot!(binned_stats_rh[:, :m_y_d_tree], binned_stats_rh[:, :m_X_rt], sp=6, yerr=binned_stats_rh[:, :sem_X_rt], label=nothing, ylim=(1350, 2550), yticks=[1500, 2000, 2500], msw=1.4, ms=4, linewidth=1, markershape=:none, c=RH_COLOR, markercolor=RH_COLOR, msc=RH_COLOR, xflip=true, xlabel="Depth in tree", ylabel="Response time (ms)", xlim=(0, 6.7), yminorticks=true)
    display(plot!())
end

function fig6AD(binned_stats)
    models = ["random_model", "gamma_only_model"] 
    DVs = ["y_p_in_tree", "y_d_tree", "y_p_undo", "y_p_same_car"]
    IDV = "X_d_goal"
    MM = length(models)
    d = length(DVs)
    l = @layout [grid(1, d); a{0.001h}];
    plot(size=(744, 220), grid=false, layout=l, dpi=300, xflip=true,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=0Plots.mm, top_margin=1Plots.mm, bottom_margin=7Plots.mm, left_margin=5Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, xlim=(0, 8));

    ylabels = ["Prop. sensible" "Depth in tree" "Prop. undos" "Prop. same car"];
    ytickss = [[0.4, 0.6, 0.8, 1.0], [1.0, 1.5, 2.0], ([0.0, 0.1, 0.2, 0.3], ["0", "0.1", "0.2", "0.3"]), ([0.0, 0.1, 0.2, 0.3, 0.4], ["0", "0.1", "0.2", "0.3", "0.4"])]
    ylimss = [(0.25, 1.0), (0.8, 2.3), (-Inf, 0.36), (0, 0.48)]
    order = [1, 3]

    for i in 1:d
        for j in 1:MM
            df_data = binned_stats[binned_stats.model .== "data", :]
            df_model = binned_stats[binned_stats.model .== models[j], :]
            sort!(df_data, :bin_number)
            sort!(df_model, :bin_number)
            ylabel = ylabels[i]
            title = ""
            yticks = ytickss[i]
            ylims = ylimss[i]
            sp = i
            o = order[j]

            plot!(df_data[:, "m_"*IDV], df_data[:, "m_"*DVs[i]], yerr=df_data[:, "sem_"*DVs[i]], sp=sp, c=:white, msw=1.4, label=nothing, xflip=true, linewidth=1, markershape=:none, ms=4, ylabel=ylabel, yticks=yticks)
            plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], ribbon=df_model[:, "sem_"*DVs[i]], sp=sp, label=nothing, c=palette(:default)[o], l=nothing, ylabel=ylabel, title=title, yticks=yticks, ylims=ylims)
            plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], ribbon=df_model[:, "sem_"*DVs[i]], sp=sp, label=nothing, c=palette(:default)[o], l=nothing, ylabel=ylabel, title=title, yticks=yticks, ylims=ylims)
        end
    end
    plot!(xlabel="Distance to goal", showaxis=false, grid=false, sp=d + 1, top_margin=-15Plots.mm, bottom_margin=7Plots.mm)
    display(plot!())
end

function fig6AD_joint(binned_stats, binned_stats_rh)
    models = ["random_model", "gamma_only_model"] 
    DVs = ["y_p_in_tree", "y_d_tree", "y_p_undo", "y_p_same_car"]
    IDV = "X_d_goal"
    MM = length(models)
    d = length(DVs)
    # l = @layout [grid(2, d); a{0.001h}];
    l = @layout [grid(2, d)];
    plot(size=(372*2 - 50*2, 420), grid=false, layout=l, dpi=300, xflip=true,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=6Plots.mm, top_margin=1Plots.mm, bottom_margin=7Plots.mm, left_margin=1Plots.mm, 
        fontfamily="helvetica", tick_direction=:out);

    ylabels = ["Prop. sensible" "Depth in tree" "Prop. undos" "Prop. same car"];
    ytickss = [[0.4, 0.6, 0.8, 1.0], [1.0, 1.5, 2.0], ([0.0, 0.1, 0.2, 0.3], ["0", "0.1", "0.2", "0.3"]), ([0.0, 0.1, 0.2, 0.3, 0.4], ["0", "0.1", "0.2", "0.3", "0.4"])]
    ylimss = [(0.25, 1.0), (0.8, 2.3), (0, 0.36), (0, 0.48)]

    ytickss_rh = [[0.4, 0.6, 0.8, 1.0], [2.0, 3.0, 4.0, 5.0], ([0.0, 0.1, 0.2], ["0", "0.1", "0.2"]), ([0.0, 0.1, 0.2, 0.3], ["0", "0.1", "0.2", "0.3"])]
    ylimss_rh = [(0.25, 1.0), (2, 5.3), (0, 0.2), (0, 0.3)]
    order = [1, 3]

    for i in 1:d
        for j in 1:MM
            df_data = binned_stats[binned_stats.model .== "data", :]
            df_model = binned_stats[binned_stats.model .== models[j], :]
            df_data_rh = binned_stats_rh[binned_stats_rh.model .== "data", :]
            df_model_rh = binned_stats_rh[binned_stats_rh.model .== models[j], :]
            sort!(df_data, :bin_number)
            sort!(df_model, :bin_number)
            sort!(df_data_rh, :bin_number)
            sort!(df_model_rh, :bin_number)
            ylabel = ylabels[i]
            title = ""
            yticks = ytickss[i]
            ylims = ylimss[i]
            yticks_rh = ytickss_rh[i]
            ylims_rh = ylimss_rh[i]
            sp = i
            o = order[j]

            plot!(df_data[:, "m_"*IDV], df_data[:, "m_"*DVs[i]], yerr=df_data[:, "sem_"*DVs[i]], sp=sp, c=:white, msw=1.4, label=nothing, xflip=true, linewidth=1, markershape=:none, ms=4, ylabel=ylabel, yticks=yticks, xlabel="Distance to goal", xlim=(0, 8))
            plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], ribbon=df_model[:, "sem_"*DVs[i]], sp=sp, label=nothing, c=palette(:default)[o], ylabel=ylabel, title=title, yticks=yticks, ylims=ylims, linewidth=3)
            plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], ribbon=df_model[:, "sem_"*DVs[i]], sp=sp, label=nothing, c=palette(:default)[o], ylabel=ylabel, title=title, yticks=yticks, ylims=ylims, linewidth=3)

            plot!(df_data_rh[:, "m_"*IDV], df_data_rh[:, "m_"*DVs[i]], yerr=df_data_rh[:, "sem_"*DVs[i]], sp=4 + sp, c=:white, msw=1.4, label=nothing, xflip=true, linewidth=1, markershape=:none, ms=4, ylabel=ylabel, yticks=yticks_rh, xlabel="Distance to goal", xlim=(0, 16))
            plot!(df_model_rh[:, "m_"*IDV], df_model_rh[:, "m_"*DVs[i]], ribbon=df_model_rh[:, "sem_"*DVs[i]], sp=4 + sp, label=nothing, c=palette(:default)[o], ylabel=ylabel, title=title, yticks=yticks_rh, ylims=ylims_rh, linewidth=3)
            plot!(df_model_rh[:, "m_"*IDV], df_model_rh[:, "m_"*DVs[i]], ribbon=df_model_rh[:, "sem_"*DVs[i]], sp=4 + sp, label=nothing, c=palette(:default)[o], ylabel=ylabel, title=title, yticks=yticks_rh, ylims=ylims_rh, linewidth=3)
        end
    end
    #plot!(xlabel="Distance to goal", showaxis=false, grid=false, sp=d + 1, top_margin=-15Plots.mm, bottom_margin=7Plots.mm)
    display(plot!())
end

function fig6EF(df_stats)
    models = ["random_model", "gamma_only_model"]
    Vs = [:h_d_tree, :h_d_tree_diff]
    lims = [1:3, 0:2]
    MM = length(models)
    d = length(Vs)
    l = @layout [grid(1, d)];
    plot(size=(298, 200), grid=false, layout=l, dpi=300, xflip=false,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=0Plots.mm, top_margin=0Plots.mm, bottom_margin=1Plots.mm, left_margin=0Plots.mm, 
        fontfamily="helvetica", tick_direction=:out);

    xlabels = ["Depth" "Delta depth"]
    order = [1, 3]
    ytickss = [([0.0, 0.2, 0.4, 0.6], ["0", "0.2", "0.4", "0.6"]), ([0.0, 0.2, 0.4, 0.6, 0.8], ["0", "0.2", "0.4", "0.6", "0.8"])]
    xtickss = [[1, 2, 3], [0, 1, 2]]
    for i in 1:d
        r = Vs[i]
        df_ = df_stats[df_stats.h_d_tree .< 1000, :]
        gdf = groupby(df_, [:subject, :model, r])
        count_df = combine(gdf, r => length => :hist_counts)
    
        count_df_norm = normalize_hist_counts(count_df, "subject", "model", r, lims[i])
    
        diff_gdf = groupby(count_df_norm, [:model, r])
        diff_df = combine(diff_gdf, :norm_counts => (x -> [(mean(x), sem(x))]) => [:hist_mean, :hist_sem])

        df_data = diff_df[diff_df.model .== "data", :]
        xlabel = xlabels[i]
        ylabel = i == 1 ? "Proportion" : ""
        title = ""
        yticks = ytickss[i]
        xticks = xtickss[i]
        bar!(df_data[:, r], df_data[:, :hist_mean], yerr=1.96*df_data[:, :hist_sem], sp=i, c=:white, msw=1.4, label=nothing, linewidth=1.4, markershape=:none, ms=0, title=title, ylabel=ylabel, xticks=xticks, yticks=yticks, linecolor=:black, markercolor=:gray, xlabel=xlabel, left_margin=i==1 ? 0Plots.mm : -4Plots.mm)
        for j in 1:MM
            df_model = diff_df[diff_df.model .== models[j], :]
            sort!(df_model, r)
            o = order[j]
            plot!(df_model[:, r], df_model[:, :hist_mean], ribbon=1.96*df_model[:, :hist_sem], sp=i, label=nothing, c=palette(:default)[o])#, l=nothing)
            plot!(df_model[:, r], df_model[:, :hist_mean], ribbon=1.96*df_model[:, :hist_sem], sp=i, label=nothing, c=palette(:default)[o])#, l=nothing)
        end
    end
    display(plot!())
end

function fig6EF_joint(df_stats, df_stats_rh)
    models = ["random_model", "gamma_only_model"]
    Vs = [:h_d_tree, :h_d_tree_diff]
    lims = [1:3, 0:2]
    lims_rh = [2:11, 1:9]
    MM = length(models)
    d = length(Vs)
    l = @layout [grid(1, 2*d)];
    plot(size=(372*2, 200), grid=false, layout=l, dpi=300, xflip=false,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=0Plots.mm, top_margin=0Plots.mm, bottom_margin=6Plots.mm, left_margin=3Plots.mm, 
        fontfamily="helvetica", tick_direction=:out);

    xlabels = ["Depth" "Delta depth"]
    order = [1, 3]
    ytickss = [([0.0, 0.2, 0.4, 0.6], ["0", "0.2", "0.4", "0.6"]), ([0.0, 0.2, 0.4, 0.6, 0.8], ["0", "0.2", "0.4", "0.6", "0.8"])]
    xtickss = [[1, 2, 3], [0, 1, 2]]
    ytickss_rh = [([0.0, 0.1, 0.2], ["0", "0.1", "0.2"]), ([0.0, 0.2, 0.4], ["0", "0.2", "0.4"])]
    xtickss_rh = [[2, 4, 6, 8, 10], [0, 2, 4, 6, 8]]
    for i in 1:d
        r = Vs[i]
        df_ = df_stats[df_stats.h_d_tree .< 1000, :]
        gdf = groupby(df_, [:subject, :model, r])
        count_df = combine(gdf, r => length => :hist_counts)
        count_df_norm = normalize_hist_counts(count_df, "subject", "model", r, lims[i])
        diff_gdf = groupby(count_df_norm, [:model, r])
        diff_df = combine(diff_gdf, :norm_counts => (x -> [(mean(x), sem(x))]) => [:hist_mean, :hist_sem])

        df_ = df_stats_rh[df_stats_rh.h_d_tree .< 1000, :]
        gdf = groupby(df_, [:subject, :model, r])
        count_df = combine(gdf, r => length => :hist_counts)
        count_df_norm = normalize_hist_counts(count_df, "subject", "model", r, lims_rh[i])
        diff_gdf = groupby(count_df_norm, [:model, r])
        diff_df_rh = combine(diff_gdf, :norm_counts => (x -> [(mean(x), sem(x))]) => [:hist_mean, :hist_sem])

        df_data = diff_df[diff_df.model .== "data", :]
        df_data_rh = diff_df_rh[diff_df_rh.model .== "data", :]
        xlabel = xlabels[i]
        ylabel = "Proportion"
        title = ""
        yticks = ytickss[i]
        xticks = xtickss[i]
        yticks_rh = ytickss_rh[i]
        xticks_rh = xtickss_rh[i]
        bar!(df_data[:, r], df_data[:, :hist_mean], yerr=1.96*df_data[:, :hist_sem], sp=i, c=:white, msw=1.4, label=nothing, linewidth=1.4, markershape=:none, ms=0, title=title, ylabel=ylabel, xticks=xticks, yticks=yticks, linecolor=:black, markercolor=:gray, xlabel=xlabel)#, left_margin=i==1 ? 0Plots.mm : -4Plots.mm)
        bar!(df_data_rh[:, r], df_data_rh[:, :hist_mean], yerr=1.96*df_data_rh[:, :hist_sem], sp=i+2, c=:white, msw=1.4, label=nothing, linewidth=1.4, markershape=:none, ms=0, title=title, ylabel=ylabel, xticks=xticks_rh, yticks=yticks_rh, linecolor=:gray, markercolor=:gray, xlabel=xlabel)#, left_margin=i==1 ? 0Plots.mm : -4Plots.mm)
        for j in 1:MM
            df_model = diff_df[diff_df.model .== models[j], :]
            df_model_rh = diff_df_rh[diff_df_rh.model .== models[j], :]
            sort!(df_model, r)
            sort!(df_model_rh, r)
            o = order[j]
            plot!(df_model[:, r], df_model[:, :hist_mean], ribbon=1.96*df_model[:, :hist_sem], sp=i, label=nothing, c=palette(:default)[o], linewidth=3)#, l=nothing)
            plot!(df_model[:, r], df_model[:, :hist_mean], ribbon=1.96*df_model[:, :hist_sem], sp=i, label=nothing, c=palette(:default)[o], linewidth=3)#, l=nothing)
            plot!(df_model_rh[:, r], df_model_rh[:, :hist_mean], ribbon=1.96*df_model_rh[:, :hist_sem], sp=2+i, label=nothing, c=palette(:default)[o], linewidth=3)
            plot!(df_model_rh[:, r], df_model_rh[:, :hist_mean], ribbon=1.96*df_model_rh[:, :hist_sem], sp=2+i, label=nothing, c=palette(:default)[o], linewidth=3)
        end
    end
    display(plot!())
end

function fig6GI(binned_stats)
    models = ["data", "random_model", "gamma_only_model"]
    DVs = ["m_y_p_worse", "m_y_p_same", "m_y_p_better"]
    IDV = "m_X_d_goal"
    MM = length(models)
    d = length(DVs)
    l = @layout [a{0.001h}; grid(1, MM); a{0.001h}];
    plot(size=(446, 200), grid=false, layout=l, dpi=300, xflip=true, link=:both,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=0Plots.mm, top_margin=1Plots.mm, bottom_margin=4Plots.mm, left_margin=0Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, xlim=(0, 8), ylim=(0, 1), yticks=nothing)

    labels = ["Worse   " "Same   " "Better   "]
    bar!([0 0 0], c=[palette(:default)[1] palette(:default)[2] palette(:default)[3]], labels=labels, legend_columns=length(labels), linewidth=0, sp=1, showaxis=false, grid=false, background_color_legend=nothing, foreground_color_legend=nothing, legend=:top, top_margin=-2Plots.mm);
    titles = ["Participants" "Random" "AND-OR"];
    xlabels = ["" "" ""]
    ylabels = ["Proportion" "" ""]
    yticks = [([0, 0.2, 0.4, 0.6, 0.8, 1], ["0", "0.2", "0.4", "0.6", "0.8", "1"]) for _ in 1:MM]
    xticks = [[0, 2, 4, 6, 8] for _ in 1:MM]
    for i in 1:MM
        df_ = binned_stats[binned_stats.model .== models[i], :]
        areaplot!(df_[:, IDV], [df_[:, DVs[1]] + df_[:, DVs[2]] + df_[:, DVs[3]], df_[:, DVs[2]] + df_[:, DVs[3]], df_[:, DVs[3]]], sp=i+1, xflip=true, label=nothing, xlabel=xlabels[i], ylabel=ylabels[i], title=titles[i], yticks=yticks[i], xticks=xticks[i], left_margin=i==1 ? 2Plots.mm : -1Plots.mm)    
    end
    plot!(xlabel="Distance to goal", showaxis=false, grid=false, sp=MM+2, top_margin=-12Plots.mm)
    display(plot!())
end

function fig6GI_joint(binned_stats, binned_stats_rh)
    models = ["data", "random_model", "gamma_only_model"]
    DVs = ["m_y_p_worse", "m_y_p_same", "m_y_p_better"]
    IDV = "m_X_d_goal"
    MM = length(models)
    d = length(DVs)
    l = @layout [grid(2, MM); a{0.001h}];
    plot(size=(372*2 - 50*2, 400), grid=false, layout=l, dpi=300, xflip=true, link=:both,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=2Plots.mm, top_margin=1Plots.mm, bottom_margin=4Plots.mm, left_margin=2Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, ylim=(0, 1), yticks=nothing)

    labels = ["Worse   " "Same   " "Better   "]
    colors = [palette(:default)[2] palette(:default)[6] palette(:default)[16]]
    titles = ["Participants" "Random" "AND-OR"];
    xlabels = ["Distance to goal" "Distance to goal" "Distance to goal"]
    ylabels = ["Proportion" "" ""]
    yticks = [([0, 0.2, 0.4, 0.6, 0.8, 1], ["0", "0.2", "0.4", "0.6", "0.8", "1"]) for _ in 1:MM]
    xticks = [[0, 2, 4, 6, 8] for _ in 1:MM]
    xticks_rh = [[0, 5, 10, 15] for _ in 1:MM]
    for i in 1:MM
        df_ = binned_stats[binned_stats.model .== models[i], :]
        df__rh = binned_stats_rh[binned_stats_rh.model .== models[i], :]
        areaplot!(df_[:, IDV], [df_[:, DVs[1]] + df_[:, DVs[2]] + df_[:, DVs[3]], df_[:, DVs[2]] + df_[:, DVs[3]], df_[:, DVs[3]]], seriescolor=colors, sp=i, xflip=true, label=nothing, xlabel=xlabels[i], ylabel=ylabels[i], title=titles[i], yticks=yticks[i], xticks=xticks[i], xlims=(0, 8))#, left_margin=i==1 ? 2Plots.mm : -1Plots.mm)    
        areaplot!(df__rh[:, IDV] .- 1, [df__rh[:, DVs[1]] + df__rh[:, DVs[2]] + df__rh[:, DVs[3]], df__rh[:, DVs[2]] + df__rh[:, DVs[3]], df__rh[:, DVs[3]]], seriescolor=colors, sp=3+i, xflip=true, label=nothing, xlabel=xlabels[i], ylabel=ylabels[i], yticks=yticks[i], xticks=xticks_rh[i], xlims=(0, 16))#, left_margin=i==1 ? 2Plots.mm : -1Plots.mm)    
    end
    bar!([0 0 0], c=colors, labels=labels, legend_columns=length(labels), linewidth=0, sp=2*MM+1, showaxis=false, grid=false, background_color_legend=nothing, foreground_color_legend=nothing, legend=:top, top_margin=-2Plots.mm);
    #plot!(xlabel="Distance to goal", showaxis=false, grid=false, sp=MM+2, top_margin=-12Plots.mm)
    display(plot!())
end

function fig7(df_models; iters=1000)
    plot(size=(372, 200), grid=false, dpi=300,
        legendfont=font(9, "helvetica"), 
        xtickfont=font(8, "helvetica"), 
        ytickfont=font(8, "helvetica"), 
        titlefont=font(9, "helvetica"), 
        guidefont=font(9, "helvetica"), 
        right_margin=1Plots.mm, top_margin=0Plots.mm, bottom_margin=2Plots.mm, left_margin=0Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, background_color_legend=nothing, foreground_color_legend=nothing)

    base_cv_nlls = df_models[df_models.model .== "gamma_only_model", :cv_nll]
    models = ["gamma_only_model", "gamma_0_model", "forward_search", "eureka_model", "opt_rand_model", "hill_climbing_model", "random_model"]
    N = length(models)
    means = zeros(N)
    err = zeros(N, 2)
    n = 0
    for model in models
        n += 1
        cv_nlls = df_models[df_models.model .== model, :cv_nll]
        M = length(cv_nlls)
        total = zeros(iters)
        for i in 1:iters
            subsampled_idxs = rand(1:M, M)
            total[i] = sum(cv_nlls[subsampled_idxs] - base_cv_nlls[subsampled_idxs])
        end
        means[n] = mean(total)
        err[n, :] = [mean(total) - quantile(total, 0.025), quantile(total, 0.975) - mean(total)]
    end
    names = ["AND-OR tree", "AND-OR tree (gamma=0)", "Forward search", "Eureka", "Optimal-random", "Hill-climbing", "Random"];
    bar!(names, means, yerr=(err[:, 1], err[:, 2]), xflip=true, label=nothing, xlim=(0, N), ylim=(0, 60000), bar_width=0.8, permute=(:x, :y), yticks=([0, 10, 20, 30, 40, 50]*1000, [0, 10, 20, 30, 40, 50]), markersize=5, linewidth=1.4, ylabel="Delta NLL (x1000)", c=:transparent)
    display(plot!())
end

function fig7_joint(df_models, df_models_rh; iters=1000)
    l = @layout [grid(1, 2); a{0.001h}];
    plot(size=(372, 200), layout=l, grid=false, dpi=300,
        legendfont=font(9, "helvetica"), 
        xtickfont=font(8, "helvetica"), 
        ytickfont=font(8, "helvetica"), 
        titlefont=font(9, "helvetica"), 
        guidefont=font(9, "helvetica"), 
        right_margin=1Plots.mm, top_margin=0Plots.mm, bottom_margin=2Plots.mm, left_margin=0Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, background_color_legend=nothing, foreground_color_legend=nothing)

    base_cv_nlls = df_models[df_models.model .== "gamma_only_model", :cv_nll]
    base_cv_nlls_rh = df_models_rh[df_models_rh.model .== "gamma_only_model", :cv_nll]
    models = ["gamma_only_model", "gamma_0_model", "forward_search", "eureka_model", "opt_rand_model", "hill_climbing_model", "random_model"]
    N = length(models)
    means = zeros(N)
    err = zeros(N, 2)
    means_rh = zeros(N)
    err_rh = zeros(N, 2)
    n = 0
    for model in models
        n += 1
        cv_nlls = df_models[df_models.model .== model, :cv_nll]
        cv_nlls_rh = df_models_rh[df_models_rh.model .== model, :cv_nll]
        M = length(cv_nlls)
        M_rh = length(cv_nlls_rh)
        total = zeros(iters)
        total_rh = zeros(iters)
        for i in 1:iters
            subsampled_idxs = rand(1:M, M)
            total[i] = sum(cv_nlls[subsampled_idxs] - base_cv_nlls[subsampled_idxs])
            subsampled_idxs_rh = rand(1:M_rh, M_rh)
            total_rh[i] = sum(cv_nlls_rh[subsampled_idxs_rh] - base_cv_nlls_rh[subsampled_idxs_rh])
        end
        means[n] = mean(total)
        err[n, :] = [mean(total) - quantile(total, 0.025), quantile(total, 0.975) - mean(total)]
        means_rh[n] = mean(total_rh)
        err_rh[n, :] = [mean(total_rh) - quantile(total_rh, 0.025), quantile(total_rh, 0.975) - mean(total_rh)]
    end
    names = ["AND-OR tree", "AND-OR tree (g=0)", "Forward search", "Eureka", "Optimal-random", "Hill-climbing", "Random"];
    bar!(names, means, sp=1, yerr=(err[:, 1], err[:, 2]), title="TOL", xflip=true, label=nothing, xlim=(0, N), ylim=(0, 60000), bar_width=0.8, permute=(:x, :y), yticks=([0, 20, 40, 60]*1000, [0, 20, 40, 60]), markersize=5, linewidth=1.4, c=:transparent)
    bar!(names, means_rh, sp=2, yerr=(err_rh[:, 1], err_rh[:, 2]), title="RH", xticks=nothing, xflip=true, label=nothing, xlim=(0, N), ylim=(0, 25000), bar_width=0.8, permute=(:x, :y), yticks=([0, 8, 16, 24]*1000, [0, 8, 16, 24]), markersize=5, linewidth=1.4, c=:transparent)
    plot!(xlabel="Delta NLL (x1000)", showaxis=false, grid=false, sp=2 + 1, top_margin=-9Plots.mm, bottom_margin=1Plots.mm)
    display(plot!())
end

# EXTENDED DATA FIGURES

function fig_ext1(problems)
    p = 13
    s = vector_to_s_type(problems[p][1])
    s_goal = vector_to_s_type(problems[p][2])
    display(draw_state(s, s_goal))

    mvs = [(2, 3), (1, 2), (3, 2), (1, 3)];

    for (n, mv) in enumerate(mvs)
        s = make_move(s, mv)
        display(draw_state(s, s_goal))
        #savefig("move$(n).svg")
    end
end

function puzzle_statistics(df)
    puzzle_df = DataFrame(subject=Int[], puzzle=Int[], Lopt=Int[], L=Int[])
    for subj in unique(df.subject)
        subj_df = df[df.subject .== subj, :]
        for prb in unique(subj_df.puzzle)
            prb_df = subj_df[subj_df.puzzle .== prb, :]
            Lopt = prb_df.Lopt[1]
            push!(puzzle_df, [subj, prb, Lopt, size(prb_df, 1)])
        end
    end
    return puzzle_df
end

function difficulty_stats(opt, completed)
    opt_rate = opt[completed .> 0] ./ completed[completed .> 0]
    return [(mean(opt_rate), sem(opt_rate))]
end

function fig_ext2(df)
    puzzle_df = puzzle_statistics(df)

    subj_diff_gdf_puz = groupby(puzzle_df, [:puzzle, :Lopt])
    opt_df_puz = combine(subj_diff_gdf_puz, [:Lopt, :L] => ((x, y) -> [(sum(x .== y), length(y))]) => [:opt, :completed])

    diff_gdf_puz = groupby(opt_df_puz, :Lopt)
    diff_df_puz = combine(diff_gdf_puz, [:opt, :completed] => difficulty_stats => [:opt_mean, :opt_sem])

    subj_diff_gdf_sub = groupby(puzzle_df, [:subject, :Lopt])
    opt_df_sub = combine(subj_diff_gdf_sub, [:Lopt, :L] => ((x, y) -> [(sum(x .== y), length(y))]) => [:opt, :completed])

    diff_gdf_sub = groupby(opt_df_sub, :Lopt)
    diff_df_sub = combine(diff_gdf_sub, [:opt, :completed] => difficulty_stats => [:opt_mean, :opt_sem])


    plot(layout=grid(1, 2), size=(372*2/2, 300), grid=false, dpi=300,         
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"),
        right_margin=0Plots.mm, top_margin=1Plots.mm, bottom_margin=6Plots.mm, left_margin=4Plots.mm, 
        fontfamily="helvetica", tick_direction=:out)

    @df diff_df_puz bar!(:opt_mean, yerr=:opt_sem, xticks=(1:5, :Lopt), sp=1, label=nothing, xlabel="Length", ylabel="Proportion optimal", ylim=(0, Inf), c=:transparent, ms=10, title="Across puzzles")
    @df diff_df_sub bar!(:opt_mean, yerr=:opt_sem, xticks=(1:5, :Lopt), sp=2, label=nothing, xlabel="Length", ylabel="", ylim=(0, Inf), c=:transparent, ms=10, title="Across subjects")
    display(plot!())
end

function fig_ext3(df)
    # count how how many of each d_goal appear per subject per difficulty level
    dgoal_diff_gdf = groupby(df, [:subject, :Lopt, :d_goal])
    dgoal_diff_df = combine(dgoal_diff_gdf, :d_goal => length => :hist_counts)
    dgoal_diff_df_norm = normalize_hist_counts(dgoal_diff_df, "subject", "Lopt", "d_goal", 1:8)
    # calculate subject error bars
    diff_gdf = groupby(dgoal_diff_df_norm, [:Lopt, :d_goal])
    diff_df = combine(diff_gdf, :norm_counts => (x -> [(mean(x), sem(x))]) => [:hist_mean, :hist_sem])

    l = @layout [grid(1, 4); a{0.001h}];
    plot(size=(372, 150), grid=false, layout=l, dpi=300, xflip=false, link=:both,
        legendfont=font(9, "helvetica"), 
        xtickfont=font(8, "helvetica"), 
        ytickfont=font(8, "helvetica"), 
        titlefont=font(9, "helvetica"), 
        guidefont=font(9, "helvetica"), 
        right_margin=0Plots.mm, top_margin=0Plots.mm, bottom_margin=3Plots.mm, left_margin=0Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, xticks=[1, 3, 5, 7, 9],
        background_color_legend=nothing, foreground_color_legend=nothing, legend=:topright)

    titles = ["Length 3", "Length 4", "Length 5", "Length 6", "Length 7"]
    ytickss = [[0, 0.1, 0.2, 0.3], [], [], [], []]
    diffs = [3, 4, 5, 6, 7]
    ylabels = ["Proportion" "" "" "" ""]
    for i in 1:4
        diff = diffs[i]
        dummy = diff_df[diff_df.Lopt .== diff, :]
        means = dummy.hist_mean
        sems = 1.96*dummy.hist_sem
        bar!(means, yerr=sems, sp=i, linecolor=:gray, markerstrokecolor=:gray, linewidth=1, markersize=0, label=nothing, title=titles[i], ylabel=ylabels[i], fillcolor=:transparent, xlabel="", yticks=ytickss[i])
        plot!([diffs[i], diffs[i]], [0, 1/(diffs[i])], sp=i, label=i < 4 ? nothing : "optimal", c=:red, linestyle=:dash)
        plot!([0.5, diffs[i]], [1/(diffs[i]), 1/(diffs[i])], sp=i, label=nothing, c=:red, linestyle=:dash)
    end
    plot!(xlabel="Distance to goal", showaxis=false, grid=false, sp=5, top_margin=-10Plots.mm, bottom_margin=2Plots.mm)
    display(plot!())
end

function fig_ext4(df, d_goals_prbs)
    # coarseness of surface
    N = 200
    # choice of gammas
    log_gammas = range(-2.5, -0.5, N)
    plot([], [], grid=false, c=:black, label="NLL surface", xlabel="gamma", ylabel="z-scored NLL", size=(300, 200), tick_direction=:out, legend=:topright)
    for subj in ProgressBar(unique(df.subject))
        df_subj = df[df.subject .== subj, :]
        nlls = zeros(N)
        # calculate NLL for each gamma
        Threads.@threads for n in eachindex(log_gammas)#
            log_gamma = log_gammas[n]
            nlls[n] = subject_nll_general(gamma_only_model, 10^log_gamma, df_subj, d_goals_prbs)
        end
        plot!(10 .^(log_gammas), zscore(nlls), label=nothing, c=:black, alpha=0.05)
        vline!([10^log_gammas[argmin(nlls)]], c=:red, alpha=0.07, label=nothing)
    end
    plot!([], [], xscale=:log10, xticks=[0.01, 0.1], xlim=(0.003, 0.3), c=:red, label="Minimum", background_color_legend=nothing, foreground_color_legend=nothing)
    display(plot!())
end

function fig_ext6(binned_stats)
    models = ["random_model", "optimal_model", "hill_climbing_model", "forward_search", "eureka_model", "opt_rand_model", "gamma_0_model", "gamma_only_model"]
    DVs = ["y_p_in_tree", "y_d_tree", "y_p_undo", "y_p_same_car"]
    IDV = "X_d_goal"
    MM = length(models)
    d = length(DVs)
    l = @layout [grid(d, MM); a{0.001h}];
    plot(size=(744, 700), grid=false, layout=l, dpi=300, xflip=true, link=:both,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=0Plots.mm, top_margin=0Plots.mm, bottom_margin=8Plots.mm, left_margin=0Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, xlim=(0, 8));

    titles = ["Random" "Optimal" "Hill\nclimbing" "Forward" "Eureka" "Optimal-\nrandom" "AND-OR\n(g=0)" "AND-OR"];
    ylabels = ["Prop. sensible" "Depth in tree" "Prop. undos" "Prop. same obj."];
    ytickss = [[0.4, 0.6, 0.8, 1.0], [1.0, 1.5, 2.0], ([0.0, 0.1, 0.2, 0.3], ["0", "0.1", "0.2", "0.3"]), ([0.0, 0.1, 0.2, 0.3, 0.4], ["0", "0.1", "0.2", "0.3", "0.4"])]
    ylimss = [(0.25, 1.0), (0.8, 2.3), (-Inf, 0.36), (0, 0.48)]
    order = [2, 3, 7, 6, 5, 8, 9, 4]

    for i in 1:d
        for j in 1:MM
            df_data = binned_stats[binned_stats.model .== "data", :]
            df_model = binned_stats[binned_stats.model .== models[j], :]
            sort!(df_data, :bin_number)
            sort!(df_model, :bin_number)
            xlabel = i == d ? "Distance\nto goal" : ""
            ylabel = j == 1 ? ylabels[i] : ""
            title = i == 1 ? titles[j] : ""
            yticks = j == 1 ? ytickss[i] : nothing
            xticks = i == d ? [0, 2, 4, 6, 8] : [0, 2, 4, 6, 8]
            ylims = ylimss[i]
            sp = (i-1)*MM + j
            o = order[j]

            plot!(df_data[:, "m_"*IDV], df_data[:, "m_"*DVs[i]], yerr=df_data[:, "sem_"*DVs[i]], sp=sp, c=:white, msw=1.4, label=nothing, xflip=true, linewidth=1, markershape=:none, ms=4, ylabel=ylabel, xticks=xticks, yticks=yticks)
            if i == 1 && j == 2
                plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], ribbon=df_model[:, "sem_"*DVs[i]], sp=sp, label=nothing, c=palette(:default)[o-1], ylabel=ylabel, title=title, xticks=xticks, yticks=yticks, ylims=ylims)
            else
                plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], ribbon=df_model[:, "sem_"*DVs[i]], sp=sp, label=nothing, c=palette(:default)[o-1], l=nothing, ylabel=ylabel, title=title, xticks=xticks, yticks=yticks, ylims=ylims)
            end
            plot!(df_model[:, "m_"*IDV], df_model[:, "m_"*DVs[i]], ribbon=df_model[:, "sem_"*DVs[i]], sp=sp, label=nothing, c=palette(:default)[o-1], l=nothing, ylabel=ylabel, title=title, xticks=xticks, yticks=yticks, ylims=ylims)
        end
    end
    plot!(xlabel="Distance to goal", showaxis=false, grid=false, sp=d*MM + 1, top_margin=-18Plots.mm, bottom_margin=0Plots.mm)
    display(plot!())
end

function fig_ext7(df_stats)
    models = ["random_model", "optimal_model", "hill_climbing_model", "forward_search", "eureka_model", "opt_rand_model", "gamma_0_model", "gamma_only_model"]
    Vs = [:h_d_tree, :h_d_tree_diff]
    lims = [1:3, 0:2]
    MM = length(models)
    d = length(Vs)
    l = @layout [grid(1, MM); a{0.001h}; grid(1, MM); a{0.001h}];
    plot(size=(744, 450), grid=false, layout=l, dpi=300, xflip=false, link=:y,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=0Plots.mm, top_margin=6Plots.mm, bottom_margin=4Plots.mm, left_margin=2Plots.mm, 
        fontfamily="helvetica", tick_direction=:out);

    titles = ["Random" "Optimal" "Hill\nclimbing" "Forward" "Eureka" "Optimal-\nrandom" "AND-OR\n(g=0)" "AND-OR"];
    xlabels = ["Depth" "Delta depth"]
    ytickss = [([0.0, 0.2, 0.4, 0.6], ["0", "0.2", "0.4", "0.6"]), ([0.0, 0.2, 0.4, 0.6, 0.8], ["0", "0.2", "0.4", "0.6", "0.8"])]
    xtickss = [[1, 2, 3], [0, 1, 2]]
    order = [2, 3, 7, 6, 5, 8, 9, 4]
    ii = 0
    for i in 1:d
        r = Vs[i]
        # Select only the sensible moves
        df_ = df_stats[df_stats.h_d_tree .< 1e9, :]
        gdf = groupby(df_, [:subject, :model, r])
        count_df = combine(gdf, r => length => :hist_counts)
        count_df_norm = normalize_hist_counts(count_df, "subject", "model", r, lims[i])
        # Take average of histograms
        diff_gdf = groupby(count_df_norm, [:model, r])
        diff_df = combine(diff_gdf, :norm_counts => (x -> [(mean(x), 1.96*sem(x))]) => [:hist_mean, :hist_sem])
        for j in 1:MM
            df_data = diff_df[diff_df.model .== "data", :]
            df_model = diff_df[diff_df.model .== models[j], :]
            sort!(df_model, r)
            ylabel = j == 1 ? "Proportion" : ""
            title = i == 1 ? titles[j] : ""
            yticks = j == 1 ? ytickss[i] : nothing
            xticks = xtickss[i]
            o = order[j]
            ii += 1
            model_sem = df_model[:, :hist_sem]
            model_sem[isnan.(model_sem)] .= 0
            bar!(df_data[:, r], df_data[:, :hist_mean], yerr=df_data[:, :hist_sem], sp=ii, c=:white, msw=1.4, label=nothing, linewidth=1.4, markershape=:none, ms=0, title=title, ylabel=ylabel, xticks=xticks, yticks=yticks, linecolor=:gray, markercolor=:gray)
            plot!(df_model[:, r], df_model[:, :hist_mean], ribbon=model_sem, sp=ii, label=nothing, c=palette(:default)[o-1])
            plot!(df_model[:, r], df_model[:, :hist_mean], ribbon=model_sem, sp=ii, label=nothing, c=palette(:default)[o-1])
        end
        ii += 1
        plot!(xlabel=xlabels[Int(1+Int(ii > 10))], showaxis=false, grid=false, sp=ii, top_margin=-12Plots.mm)
    end
    display(plot!())
end

function fig_ext8(binned_stats)
    models = ["data", "random_model", "optimal_model", "hill_climbing_model", "forward_search", "eureka_model", "opt_rand_model", "gamma_0_model", "gamma_only_model"]
    DVs = ["m_y_p_worse", "m_y_p_same", "m_y_p_better"]
    IDV = "m_X_d_goal"
    MM = length(models)
    d = length(DVs)
    l = @layout [grid(1, MM); a{0.001h}; a{0.001h}];
    plot(size=(744, 300), grid=false, layout=l, dpi=300, xflip=true, link=:both,
        legendfont=font(12, "helvetica"), 
        xtickfont=font(10, "helvetica"), 
        ytickfont=font(10, "helvetica"), 
        titlefont=font(12, "helvetica"), 
        guidefont=font(12, "helvetica"), 
        right_margin=0Plots.mm, top_margin=4Plots.mm, bottom_margin=6Plots.mm, left_margin=0Plots.mm, 
        fontfamily="helvetica", tick_direction=:out, xlim=(0, 8), ylim=(0, 1), yticks=nothing)

    labels = ["Worse" "Same" "Better"]
    titles = ["Data" "Random" "Optimal" "Hill\nclimbing" "Forward" "Eureka" "Optimal-\nrandom" "AND-OR\n(g=0)" "AND-OR"];
    xlabels = ["" for _ in 1:MM]
    ylabels = ["Proportion" "" "" "" "" "" "" "" "" ""]
    yticks = [([0, 0.2, 0.4, 0.6, 0.8, 1], ["0", "0.2", "0.4", "0.6", "0.8", "1"]), [([0, 0.2, 0.4, 0.6, 0.8, 1], ["", "", ""]) for _ in 1:MM]...]
    xticks = [[0, 2, 4, 6, 8] for _ in 1:MM]
    colors = [palette(:default)[2] palette(:default)[6] palette(:default)[16]]
    for i in 1:MM
        df_ = binned_stats[binned_stats.model .== models[i], :]
        areaplot!(df_[:, IDV], [df_[:, DVs[1]] + df_[:, DVs[2]] + df_[:, DVs[3]], df_[:, DVs[2]] + df_[:, DVs[3]], df_[:, DVs[3]]], sp=i, c=colors, xflip=true, label=nothing, xlabel=xlabels[i], ylabel=ylabels[i], title=titles[i], yticks=yticks[i], xticks=xticks[i])    
    end
    plot!(xlabel="Distance to goal", showaxis=false, grid=false, sp=MM+1, top_margin=-12Plots.mm)
    bar!([0 0 0], c=colors, labels=labels, legend_columns=length(labels), linewidth=0, sp=MM+2, showaxis=false, grid=false, background_color_legend=nothing, foreground_color_legend=nothing, legend=:top, top_margin=-4Plots.mm);
    display(plot!())
end