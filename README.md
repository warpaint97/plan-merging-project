# Plan Merging Project

## About
This is a student project at the University of Potsdam which deals with the declarative programming language ASP (Answer Set Programming) and the [asprilo](https://potassco.org/asprilo/) framework by [potassco](https://potassco.org) where robots in a warehouse environment need to fulfill their goals. For simplicity, we are solely focusing on the M-Domain in which it suffices when robots reach the destination of an ordered product in a shelf. 
We aim to find a solution for intelligently merging plans of individual robots into one common plan for all robots to increase performance.

## Directories
- `benchmarks/` contains all of our  M-domain benchmark instances for the asprilo framework.
- `encodings/` contains all of our encodings for the plan merger.
- `benchmark_tool/` contains our tool to generate benchmarks for the M-domain.
- `tester/` contains python scripts which help in testing our merger encodings on a given benchmark.

## Contributors
- Aaron Bishop: aaron.bishop@uni-potsdam.de
- Anton Rabe: anton.rabe@uni-potsdam.de
- Louis Donath: lodonath@uni-potsdam.de

## Literature
- [clingo Guide](http://wp.doc.ic.ac.uk/arusso/wp-content/uploads/sites/47/2015/01/clingo_guide.pdf)
- [clingo Python API](https://potassco.org/clingo/python-api/5.4/)
