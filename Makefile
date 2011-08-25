
GPRBUILD=gprbuild
GPRCLEAN=gprclean

GPR_FILE=dispersion.gpr

all: prep
	$(GPRBUILD) -P $(GPR_FILE)

clean: prep
	$(GPRCLEAN) -P $(GPR_FILE)

### Dependency targets

prep:
	mkdir -p obj/debug
	mkdir -p obj/release

###


.PHONY: all clean prep
