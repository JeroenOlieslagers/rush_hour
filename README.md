# Rush Hour
Code to reproduce figures from paper.

# Installation
Julia 1.8.5 is required to run the analysis code. Later versions will not be able to load some of the data correctly. The list of required packages can be found in `load_scripts.jl`.

Instructions on installing Julia can be found at https://julialang.org/install/.

The typical install time of Julia and the required dependencies is less than 15min.

# Demo

There is a demo jupyter notebook located in `demos/`, which contains the instructions on how to replicate some key figures. The expected run time may vary depending on which analysis are done and which data has already been pre-processed.

Specific instructions can be found in the `load_scripts.jl` and `main.jl` files. To reproduce all the figures, please see `main.jl`.

# Authors and Acknowledgements
Jeroen Olieslagers

# License
The code is released under the terms of the [MIT License](https://github.com/WeiJiMaLab/rush_hour/blob/main/LICENSE.txt).

```
rush_hour
├── README.md
├── Project.toml                : tells julia which packages to install
├── Manifest.toml
├── demos
├── figures                     : contains all figures from paper
├── data
│   ├── processed_data
│   └── raw_data
└── src
```
