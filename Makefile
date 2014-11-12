YASM = /usr/local/bin/yasm

PROGS = cpuid64 cpuid32 cpurand

all: $(PROGS)

clean:
	-rm $(PROGS)
	-rm *.o

## cpuid64

cpuid64: cpuid64.o
	ld -e main -macosx_version_min 10.7 -arch x86_64 cpuid64.o -o cpuid64

cpuid64.o: cpuid64.s
	$(YASM) -f macho64 cpuid64.s


## cpuid32

cpuid32: cpuid32.o
	ld -e _main -macosx_version_min 10.7 -arch i386 cpuid32.o -o cpuid32

cpuid32.o: cpuid32.s
	as -arch i386 -o cpuid32.o cpuid32.s


## cpurand

cpurand: cpurand.o
	ld -e main -macosx_version_min 10.7 -arch x86_64 cpurand.o -o cpurand

cpurand.o: cpurand.s
	$(YASM) -l cpurand.lst -f macho64 cpurand.s

