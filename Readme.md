# Model of the neuro-glia interaction in the cerebellar granular network

This is a physiologically detailed model of the cerebellar granular network including neuro-glia interaction, used for:

Kwon, J., Kim, S., Woo, J., Tanaka-Yamamoto, K., Oliver, J., De Schutter, E., Hong, S. & Lee, C.J. (2026). Cerebellar tonic inhibition orchestrates the maturation of information processing and motor coordination. Experimental and Molecular Medicine, in press.

This model is based on the model by [Sudhakar et al. (2017)](https://modeldb.science/232023) and the Python package [Pycabnn](https://www.frontiersin.org/journals/neuroinformatics/articles/10.3389/fninf.2020.00031) ([github link](https://github.com/shhong/pycabnn)). It runs on the [NEURON](https://www.neuron.yale.edu/neuron/) simulation platform with an [MPI-based parallel running feature](https://www.neuron.yale.edu/neuron/static/papers/jnm/parallelizing_models_jnm2008.pdf) enabled.



## How to run the model

Please refer to the [Pycabnn](https://www.frontiersin.org/journals/neuroinformatics/articles/10.3389/fninf.2020.00031) paper for an overview of model construction and running. We included a snapshot of the Pycabnn used by our simulations in the paper
(SHA1:`733eadfc09c08d235e72d4d3e1eec504a1568a0a`). To run the simulation:

1. First change the settings in script files:
   1. Moduling loading part in `batch_slurm_start.sh` (from line 69) and all script files in`scripts/` (around line 34).
   2. `NEURONHOME` variable in `batch_slurm_start.sh` (line 37) and all scripts files in `scripts/`.
   3. (Optional) `CLUSTER` variable in `batch_slurm_start.sh` and the name of `scripts/*_clustername.slurm`.
2. Modify the cell model and choose the parameters for the case that you want to run:
   1. Comment/uncomment the set of parameters in`templates/Granule_template_CL.hoc` for the GABA receptors (line 154-178, currently set for the WT adults case).
   2. Note that the parameters to be used are in `params/set{protocol code}{case code}`. Here the cased code is `a` for WT adults, `y` for WT young, `ako` for Best1 KO adults, `yko` for Best1 KO young. The protocol code is `1000` for only the background mossy fiber inputs and `2000` for the sinusoidal inputs in the stimulated zone as in the paper.
3. Run `batch_slurm_start.sh params/set{protocol code}{case code}`.



## Contributors

- Oliver James (@OliverMount): Stochastic GABA receptor mechanism.
- Sungho Hong (@shhong): Granule cell and GABAergec current models, model design, simulation, and supervision of the project.

------
*Written by Sungho Hong, Center for Memory and Glioscience, Institute for Basic Science, Korea*

*January 21, 2026*

*Correspondence: [Sungho Hong](mailto:sunghohong@ibs.re.kr), Center for Memory and Glioscience, Institute for Basic Science*
