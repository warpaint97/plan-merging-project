Here you can find our different approaches on tackling the plan merging problem.

The final encoding for the plan merger will be called `merger.lp` and can be run with the following command:

`clingo --out-atomf='%s.' -V0 encodings/merger.lp benchmarks/02_benchmark/plans/full_plan.lp benchmarks/02_benchmark/instance/x4_y4_n16_r2_s2_ps0_pr2_u2_o2_N002.lp > ../output.txt; cat ../output.txt | viz`
