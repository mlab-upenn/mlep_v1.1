function [instructions] = idinputHelp()


 instructions = {
     'SIGNAL INPUT';
     'This Tab generates random input signals for System Identification. The Matlab built-in function IDINPUT is used to generate the signal.';
     '1. CONTROL STEP: It defines how often the input signal changes in terms of the E+ timestep';
     '2. TYPE: One of the following';
     '     "RGS": Generates a Random, Gaussian Signal.';
     '     "RBS": Generates a Random, Binary Signal.';
     '     "PRBS": Generates a Pseudo-random, Binary Signal.';
     '     "SINE": Generates a sum-of-sinusoid signal.';
     '2. SIGNAL SCALE: Scale factor for the original IDINPUT Signal';
     '3. BAND = [LFR,HFR], where LFR and HFR are the lower and upper limits of the passband, expressed in fractions of the Nyquist frequency (thus always numbers between 0 and 1).';
     '4. LEVELS = [MIN, MAX] It defines the input levels, the maximum and the minimum';
     'FOR MORE INFORMATION CHECK THE HELP FOR IDINPUT'};
     
end
