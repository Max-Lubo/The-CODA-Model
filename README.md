# The-CODA-Model
The following MATLAB files may be used to simulate both the base CODA model and several extensions to the model,
with changeable parameters and opinion maps and histograms as outputs.

The base CODA model has been constructed in the "Run_CODA_Model.m" file.
Each of the other files containing extensions to the CODA model have been written to run as stand-alone models, however 
they have been structured for the purpose of combining them in a modular way (see "CODA_Update_MooreContrarians.m" for
an example of how this may be accomplished).

The primary output of each file is the opinion map both at t=0 and at the maximum time, though they may be modified to display the opinion
maps updating in real time (by uncommenting the the relevant plotting code towards the end of the for loop).
Each file also includes a method for plotting opinion change histograms for the population at the maximum time of the model.

The mathematical equations used in these files are based on the papers of A. Martins below:

Martins. A, 2008, Continuous Opinions and Discrete Actions in Opinion Dynamics Problems.

Martins. A, 2008, Bayesian Updating Rules in Continuous Opinion Dynamics Models.

Martins. A, 2021, Agent mental models and Bayesian rules as a tool to create opinion dynamics models.

Martins et al, 2009, An opinion dynamics model for the diffusion of innovations.

Martins. A, 2008, Mobility and social network effects on extremist opinions.

Martins. A, 2013, Trust in the CODA model: Opinion dynamics and the reliability of other agents.

Martins. A, 2009, The Importance of Disagreeing: Contrarians and Extremism in the CODA model.

This code was created as part of the MA4K8 Maths in Action Project.

Max Lubowiecki.

Warwick Mathematics Institute.
