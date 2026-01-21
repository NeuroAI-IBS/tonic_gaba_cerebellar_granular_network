TITLE Cerebellar granule cell GABA

COMMENT
GABA receptor for the cerebellar granule cell with three time constants.

Written by Shyam Kumar Sudhakar and Sungho Hong
Computational Neuroscience Unit, Okinawa Institute of Science and Technology, Japan
Supervision: Erik De Schutter

Correspondence: Sungho Hong (shhong@oist.jp)

September 16, 2017
ENDCOMMENT


NEURON {
	POINT_PROCESS GrCGABAexp
	RANGE tau1, tau2, c2, egaba, i,tau3
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

}

ASSIGNED {
	v (mV)
	i (nA)
	g (uS)
	factor
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
	A = A + weight*factor
	B = B + c2*weight*factor
	C = C + (1-c2)*weight*factor
}
