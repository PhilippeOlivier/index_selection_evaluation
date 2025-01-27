# **READ THIS FIRST**

I have adapted the code of the 2020 Kossmann paper to make it work in Docker. It is a bit hacky but it works reliably.


## Before creating the Docker environment

If you do not have a CPLEX license and the CPLEX installer, uncomment the CPLEX code in the Dockerfile.


## Create the Docker environment

This is done in two steps. First, the image is created, and some fixes are applied through the Dockerfile. Second, the container is created, and some more fixes are manually applied.

Create the image:

```bash
host$ git clone https://github.com/PhilippeOlivier/index_selection_evaluation
host$ cd index_selection_evaluation
host$ docker image build --tag kossmann .
```

Start the container (you will always be root inside the container):

```bash
host$ docker run -it --rm kossmann
```

Apply the additional fixes:

```bash
docker# cd index_selection_evaluation
docker# ./fixes.sh
```

This fixes some errors in the C code for the TPC-DS benchmarks then recompiles. This then runs some unit tests to make sure that everything works fine. Normally, these tests should only output two errors (they don't need to be fixed for now).

When the tests are finished and that the two errors are displayed in the terminal, the environment is properly set up.


## Run tests

To run tests, first copy the file `benchmark_results/tpch_wo_2_17_20/config.json` under a different name, e.g.,

```bash
docker# cp benchmark_results/tpch_wo_2_17_20/config.json benchmark_results/tpch_wo_2_17_20/config-pganalyze.json
```

Then, edit this file to only use the algorithms that you want (in my case, I only kept `dexter` and `extend`) and set their time limit as you see fit (30s should be enough since they should both terminate quickly anyway).

To run the TPC-H benchmarks, execute:

```bash
docker# python3 -m selection benchmark_results/tpch_wo_2_17_20/config-pganalyze.json
```

The results can be found in `benchmark_results/results_ALGORITHM_tpch_queries.csv`.


## To do

- [ ] Figure out how to run CoPhy.
- [ ] Interpret the benchmarks' output.
- [ ] Why do the TPC-H benchmarks only have ~20 queries?
- [ ] What is coverage? `coverage run...`
- [ ] Implement our model here (in `selection/algorithms/pganalyze_algorithm.py`).


## Below this line is the rest of the original README

# Index Selection Evaluation

This repository contains the source code for the evaluation platform presented in the paper [*Magic mirror in my hand, which is the best in the land? An Experimental Evaluation of Index Selection Algorithms*](http://www.vldb.org/pvldb/vol13/p2382-kossmann.pdf). As part of this paper, we re-implemented 8 index selection algorithms ([references](#references) listed below):

- The drop heuristic [1]
- An algorithm similar to the initial AutoAdmin algorithm [2]
- An algorithm loosely following the DB2 advisor index selection [3]
- The Relaxation algorithm [4]
- CoPhy's approach [5]
- Dexter [6]
- The Extend algorithm [7]
- An algorithm loosely following SQLServer's DTA Anytime index selection [8]

The implementations of the algorithms can be found under `selection/algorithms`. Documentation, also regarding the parameters of the algorithms, is part of the source files.

While some of the chosen algorithms are related to tools employed in commercial DBMS products, the re-implemented algorithms do not fully reflect the behavior and performance of the original tools, which may be continuously enhanced and optimized.

## Citing the project
If you use (parts of) our implementation for research on index selection, please consider citing our paper:
```
@article{DBLP:journals/pvldb/KossmannHJS20,
  author    = {Jan Kossmann and
               Stefan Halfpap and
               Marcel Jankrift and
               Rainer Schlosser},
  title     = {Magic mirror in my hand, which is the best in the land? An Experimental
               Evaluation of Index Selection Algorithms},
  journal   = {Proc. {VLDB} Endow.},
  volume    = {13},
  number    = {11},
  pages     = {2382--2395},
  year      = {2020},
  url       = {http://www.vldb.org/pvldb/vol13/p2382-kossmann.pdf}
}
```

## Cost Estimation
The evaluation platform allows utilizing cost estimations that are either based on hypothetical (what-if) or actual indexes. By default hypothetical indexes are used. For PostgreSQL, [HypoPG](https://github.com/HypoPG/hypopg) is used to provide what-if capabilities. To assess the accuracy of HypoPG, a comparison of cost estimations based on actual and hypothetical indexes for the TPC-H and TPC-DS benchmarks is provided [in this repository](https://github.com/hyrise/index_selection_evaluation/tree/refactoring/benchmark_results/cost_estimation_actual_vs_hypo) as well.

Further details regarding cost estimation will be provided by the corresponding paper as soon as it is published.

## Usage

Install script:
* `./scripts/install.sh`

Run index selection evaluation for the TPC-H benchmark:
* `python3 -m selection benchmark_results/tpch_wo_2_17_20/config.json`
(If the last parameter is omitted, the default config `example_configs/config.json` is used)

Run tests:
* `python3 -m unittest discover tests`

Get coverage:
```
coverage run --source=selection -m unittest discover tests/
coverage html
open htmlcov/index.html
```

## Adding a new algorithm:
* Create a new algorithm class, based on `selection/algorithms/example_algorithm.py`
* Add algorithm class name in `selection/index_selection_evaluation.py` to this dictionary:
```
ALGORITHMS = {'extend': ExtendAlgorithm,
              'drop': DropHeuristicAlgorithm}
```
* Create or adjust configuration files


## Formatting and Linting
The code can be automatically formatted and linted by calling `./scripts/format.sh` and `./scripts/lint.sh` from the main folder.

# References
[1] (Drop): Kyu-Young Whang: Index Selection in Relational Databases. FODO 1985: 487-500

[2] (AutoAdmin): Surajit Chaudhuri, Vivek R. Narasayya: An Efficient Cost-Driven Index Selection Tool for Microsoft SQL Server. VLDB 1997: 146-155

[3] (DB2Advis): Gary Valentin, Michael Zuliani, Daniel C. Zilio, Guy M. Lohman, Alan Skelley: DB2 Advisor: An Optimizer Smart Enough to Recommend Its Own Indexes. ICDE 2000: 101-110

[4] (Relaxation): Nicolas Bruno, Surajit Chaudhuri: Automatic Physical Database Tuning: A Relaxation-based Approach. SIGMOD Conference 2005: 227-238

[5] (CoPhy): Debabrata Dash, Neoklis Polyzotis, Anastasia Ailamaki: CoPhy: A Scalable, Portable, and Interactive Index Advisor for Large Workloads. Proc. VLDB Endow. 4(6): 362-372 (2011)

[6] (Dexter): Andrew Kane:  https://medium.com/@ankane/introducing-dexter-the-automatic-indexer-for-postgres-5f8fa8b28f27

[7] (Extend): Rainer Schlosser, Jan Kossmann, Martin Boissier: Efficient Scalable Multi-attribute Index Selection Using Recursive Strategies. ICDE 2019: 1238-1249

[8] (Anytime): Not published yet. DTA documentation: https://docs.microsoft.com/de-de/sql/tools/dta/dta-utility?view=sql-server-ver15

# Acknowledgements
We thank S. Chaudhuri, V. Narasayya, J. Rouhaud, A. Sharma, and D. Zilio for support, detailed answers, providing source code, and bug fixes.
