include arch.make

objects:=util.o config.o slph.o 

all: slph
slph: $(objects)
	$(MPIFC) $(FFLAGS) -o $@ $^ $(LDFLAGS) $(LIBS)
config.o: config.mod
slph.o: util.mod
%.o %.mod: %.f90
	$(MPIFC) $(FFLAGS) -c -o $*.o $<
	touch $*.mod
clean:
	rm -f slph *.mod *.o
