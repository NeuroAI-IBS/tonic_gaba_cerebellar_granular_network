TITLE Cerebellar granule cell GABA

COMMENT
Stochastic GABA receptor for the cerebellar granule cell with three time constants.

Originally written by Shyam Kumar Sudhakar and Sungho Hong
Computational Neuroscience Unit, Okinawa Institute of Science and Technology, Japan
Supervision: Erik De Schutter
September 16, 2017

Revised for stochastic part by Oliver James
Supervision: Sungho Hong
Center for Memory and Glioscience, Institute for Basic Science, South Korea
Correspondence: Sungho Hong (sunghohong@ibs.re.kr)
January 21, 2026

ENDCOMMENT


NEURON {
	POINT_PROCESS GrCGABAexpStoch
	RANGE tau1, tau2, c2, egaba, i,tau3, release_prob,seed_spatial, seed_temporal
	NONSPECIFIC_CURRENT i
	RANGE g
}

UNITS {
	(nA) = (nanoamp)
	(mV) = (millivolt)
	(uS) = (microsiemens)
}

PARAMETER {
	tau1=  0.25 (ms) <1e-9,1e9>

	: Here are adult parameters
	tau2 = 9 (ms) <1e-9,1e9>
	tau3 = 81 (ms)
	c2 = 0.88319

	egaba = -81	(mV) : should be set by ecl again

	: Spatial and temporal seeds for randomness
    seed_spatial = 1    : Seed for spatial variation (different synapses)
    seed_temporal = 1   : Seed for temporal variation (different events)
	release_prob = 0.5 <0,1>    : Release probability [0,1]

}

ASSIGNED {
	v (mV)
	i (nA)
	g (uS)
	factor
	event_count  : Counter for temporal randomness
}

STATE {
	A (uS)
	B (uS)
	C (uS)
}

INITIAL {
	LOCAL tp

	if (tau1/tau2 > .9999) {
		tau1 = .9999*tau2
	}

	: this factor is only approximate forthree
	tp = (tau1*tau2)/(tau2 - tau1) * log(tau2/tau1)
	factor = -exp(-tp/tau1) + exp(-tp/tau2)
	factor = 1/factor

	A = 0
	B = 0
	C = 0
}

BREAKPOINT {
	SOLVE state METHOD cnexp

	g = ((B+C) - A)
	i = g*(v - egaba)
}

DERIVATIVE state {

	A' = -A/tau1
	B' = -B/tau2
	C' = -C/tau3

}

NET_RECEIVE(weight (uS)) {

    LOCAL rval
    : Generate uniform random number using NEURON's scop_random()
    rval = scop_random()

     if (rval < release_prob) {

     A = A + weight*factor
 	 B = B + c2*weight*factor
 	 C = C + (1-c2)*weight*factor

 	 : For checking purpose
 	 :VERBATIM
     :printf("RELEASING SPIKES \n");
     :ENDVERBATIM

     }
     :else{
     :  	VERBATIM
 	 :	printf("FAILED TO RELEASE SPIKES \n");
 	 :	ENDVERBATIM
     :}

     : Increment event counter for temporal variation
     event_count = event_count + 1

}

: Procedure to set seeds - reinitializes the random number generator
PROCEDURE setSeeds(spatial, temporal) {
    seed_spatial = spatial
    seed_temporal = temporal
    event_count = 0

    : Reset NEURON's random seed with combined seed
    set_seed(seed_spatial * 1009 + seed_temporal * 1013)
}

: Function to get current event count
FUNCTION getEventCount() {
    getEventCount = event_count
}

: Reset event counter
PROCEDURE resetCounter() {
    event_count = 0
}

: Generate a random number on demand (useful for testing)
FUNCTION getRandomNumber() {
    getRandomNumber = scop_random()
}

: Procedure to advance the random stream by n steps
PROCEDURE advanceRandom(n) {
    LOCAL i, dummy
    FROM i = 1 TO n {
        dummy = scop_random()
    }
}