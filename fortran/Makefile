include arch.make

objects:=util.o 

all: slph
slph: $(objects)
	$(MPIFC) $(FFLAGS) -o $@ $^ $(LDFLAGS) $(LIBS)
slph.o: util.mod
%.o %.mod: %.f90
	$(MPIFC) $(FFLAGS) -c -o $*.o $<
	touch $*.mod
clean:
	rm -f slph *.mod *.o
