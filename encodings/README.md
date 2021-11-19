Here you can find our different approaches on tackling the plan merging problem.

The final encoding for the plan merger will be called `merger.lp` and can be executed with the following structure:

`clingo --out-atomf='%s.' -V0 merger.lp instance.lp plan_r1.lp, plan_r2.lp,...,plan_rX.lp > output.txt; cat output.txt | viz`
