# MIPS Multicycle Processor

This is an implementation of a MIPS Multicycle Processor in *Verilog* HDL with
*Quartus II* software on the *Altera DE2-70* board.

The processor is distributed over several Verilog files with (more or less) all
the expected functionality implemented.

Also, there's a *Quartus II* project file so it can interact with an *Altera
DE2-70* board. This way you can test it on real hardware.

For all of you simulator enthusiasts, the *Quartus II* software allows it.
Finally, you can use your own program, provided that you know how to handle
multiparty Verilog files.

# How to use

Download any Quartus software from their webpage (although I recommend *Quartus
II Web Edition*) and then open the project file on it
(+MIPS-MULTI_v10/TopDE3.vwf+).

The expected functionality is described through the modules.

# Authors/Credit

THIS WAS NOT DONE BY ME.

The whole project was made over the course of several semesters by a lot of
people. The credits are distributed over the Verilog modules (files ending with
+.v+).

The whole processor was built through assignments on the class of _Computer
Organization and Architecture_ on the _University of Brasilia *(UnB)*_, Brazil.

# License/Copyright

There's no official license on the whole project, but some parts are licensed
separately.

DE2_70_pin_assignments.csv is Copyrighted to the Altera Corporation (C) 1991-2007.

The Verilog modules don't have a license so I'll assume public domain. You can
assume that too.

All MIPS-Assembly tests (files ending on +.s+) are Public Domain.

