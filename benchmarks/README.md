# Benchmarks
This directory contains all of our benchmarks to test for different scenarios in the asprilo framework and are free for anyone to use.

Each benchmark usually contains an `instance/` directory containing the benchmark instance and a `plans/` directory containing the individual plans for each robot `plan_rX.lp` as well as a full plan for all robots `full_plan.lp`.

The `occurs/2` predicate in the plans have been renamed to `occurs_/2` in order to seperate them from our output plan for the plan merger.
