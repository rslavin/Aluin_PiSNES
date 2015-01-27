#ZSNESFX=1
#ZSNESC4=1
#ASMCPU=1
#SPC700ASM=1
#NETPLAY=1
UNZIP=1
#THREAD_SOUND=1


ifdef SPC700ASM
SOUNDOBJ=spctool/spc700.o spctool/dsp.o spctool.o spctool/soundmod.o spc.o
SOUNDDEFINES=-DSPCTOOL
else
#SOUNDOBJ=spc700.o soundux.o apu.o i386/spc.o
SOUNDOBJ=spc700.o soundux.o apu.o
SOUNDDEFINES=-DSPC700_C
endif

ifdef ASMCPU
CPUOBJ=i386/cpuops.o i386/cpuexec.o i386/sa1ops.o
else
CPUOBJ=cpuops.o cpuexec.o
endif

ifdef ASMKREED
KREEDOBJ=i386/2xSaImmx.o i386/bilinear.o 2xsai.o
KREEDDEFINES=-DMMX
else
KREEDDEFINES=
#KREEDOBJ=2xsai.o
endif

OBJECTS=$(CPUOBJ) $(FXOBJ) $(C4OBJ) \
	cpu.o tile.o gfx.o clip.o \
	memmap.o ppu.o dma.o unix/unix.o \
	$(SOUNDOBJ) unix/graphics.o dsp1.o \
    snes9x.o snapshot.o data.o globals.o \
	unix/gles2.o \
	$(KREEDOBJ)

ifdef NETPLAY
OBJECTS += netplay.o server.o
NETPLAYDEFINES=-DNETPLAY_SUPPORT
endif

ifdef UNZIP
OBJECTS += loadzip.o unzip/unzip.o unzip/explode.o unzip/unreduce.o \
	   unzip/unshrink.o
UNZIPDEFINES=-DUNZIP_SUPPORT
endif

ifdef THREAD_SOUND
CPUDEFINES += -DUSE_THREADS
EXTRALIBS += -lpthread -lcygipc
endif

GLIDEDEPENDS=no_glide
GLIDENO_DEPENDS=use_glide

OPENGLDEPENDS=no_opengl
OPENGLNO_DEPENDS=use_opengl

CCC = g++
CC = gcc
NASM = nasm

INCLUDES=-I/usr/include -I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads \
    -I/opt/vc/include/interface/vmcs_host/linux 


#OPTIMISE= -D_ZAURUS -O3 -march=armv6zk -mcpu=arm1176jzf-s -mtune=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard -ffast-math -fstrict-aliasing -fomit-frame-pointer 
OPTIMISE= -D_ZAURUS -O3 -march=armv6 -mfpu=vfp -mfloat-abi=hard -ffast-math -fstrict-aliasing -fomit-frame-pointer 

CCFLAGS = $(OPTIMISE) \
-I/usr/include \
-I/usr/include/SDL \
-I. \
-Iunzip \
-Isdl \
-I/usr/include/glib-2.0 -I/usr/lib/arm-linux-gnueabihf/glib-2.0/include \
-D__linux \
-DZLIB \
-DVAR_CYCLES \
-DCPU_SHUTDOWN \
-DSPC700_SHUTDOWN \
-fpermissive \
-Wno-write-strings \
$(CPUDEFINES) \
$(SOUNDDEFINES) \
$(NETPLAYDEFINES) \
$(UNZIPDEFINES) \
$(GUIDEFINES) \
-DNO_INLINE_SET_GET

#-DDEBUGGER
#-DJOYSTICK_SUPPORT

CFLAGS=$(CCFLAGS)

.SUFFIXES: .o .cpp .c .cc .h .m .i .S .asm .obj

LDLIBS = -L/usr/lib/arm-linux-gnueabihf -L/opt/vc/lib -lbcm_host -lGLESv2 -lEGL -lglib-2.0 -lbcm_host -lbcm_host -lbcm_host -lrt -lm -lasound

all: snes9x snes9x.gui

snes9x: $(OBJECTS) 
	$(CC) $(INCLUDES) -o $@ $(OBJECTS) $(EXTRALIBS) $(LDLIBS) -lSDL -lstdc++ -lz -lpthread 

snes9x.gui: unix/frontend.o
	$(CC) $(INCLUDES) -o $@ unix/frontend.o $(EXTRALIBS) $(LDLIBS) -lSDL -lstdc++ -lz -lpthread 

.cpp.o:
	$(CCC) $(INCLUDES) -c $(CCFLAGS) $*.cpp -o $@

.c.o:
	$(CC) $(INCLUDES) -c $(CCFLAGS) $*.c -o $@

.cpp.S:
	$(CCC) $(INCLUDES) -S $(CCFLAGS) $*.cpp -o $@

.cpp.i:
	$(CCC) $(INCLUDES) -E $(CCFLAGS) $*.cpp -o $@

.S.o:
	$(CCC) $(INCLUDES) -c $(CCFLAGS) $*.S -o $@

.S.i:
	$(CCC) $(INCLUDES) -c -E $(CCFLAGS) $*.S -o $@

.asm.o:
	$(NASM) -f elf $(FXDEFINES) -i . -i i386 -o $@ $*.asm

clean:
	rm -f $(OBJECTS) offsets.o unix/unix.o unix/graphics.o unix/frontend.o
#release: CCFLAGS += -DNO_DEBUGGER

release: clean all

ppu.o: $(FXDEPENDS)
cpu.o: $(FXDEPENDS)
memmap.o: $(FXDEPENDS)
globals.o: $(FXDEPENDS)
i386/cpuexec.o: $(FXDEPENDS)
snapshot.o: $(FXDEPENDS)
snaporig.o: $(FXDEPENDS)

unix/unix.o: $(GLIDEDEPENDS) $(OPENGLDEPENDS)
unix/x11.o: $(GLIDEDEPENDS) $(OPENGLDEPENDS)
unix/glide.o: $(GLIDEDEPENDS)
gfx.o: $(GLIDEDEPENDS) $(OPENGLDEPENDS)
unix/opengl.o: $(OPENGLDEPENDS)

i386/cpuexec.o: i386/asmstruc.h i386/offsets.h
i386/cpuops.o: i386/asmstruc.h i386/asmops.h i386/getset.S i386/asmaddr.h i386/offsets.h
i386/spc700.o: i386/asmstruc.h i386/spcops.h i386/offsets.h
cpuexec.o: cpuexec.h cpuops.h snes9x.h snapshot.h gfx.h \
	memmap.h ppu.h debug.h port.h display.h apu.h spc700.h apu.h
debug.o: cpuops.h cpuexec.h snes9x.h \
	memmap.h ppu.h debug.h missing.h port.h display.h apu.h
ppu.o: snes9x.h memmap.h ppu.h missing.h port.h cpuexec.h \
	apu.h spc700.h fxemu.h fxinst.h
dsp1.o: snes9x.h port.h dsp1.h
snapshot.o: snapshot.h memmap.h snes9x.h 65c816.h ppu.h \
	cpuexec.h display.h apu.h spc700.h soundux.h
snes96.o: port.h snes9x.h memmap.h
memmap.o: cpuexec.h snes9x.h memmap.h ppu.h port.h cheats.h getset.h apu.h \
	  spc700.h
unix.o: cpuexec.h snes9x.h port.h snapshot.h display.h apu.h gfx.h cheats.h
x11.o: display.h snes9x.h memmap.h debug.h ppu.h snapshot.h gfx.h
ggi.o: display.h snes9x.h memmap.h debug.h ppu.h snapshot.h gfx.h 
graphics.o: display.h snes9x.h memmap.h debug.h ppu.h snapshot.h gfx.h soundux.h
gfx.o: memmap.h snes9x.h ppu.h gfx.h display.h port.h
tile.o: memmap.h snes9x.h ppu.h display.h gfx.h tile.h
spc700.o: spc700.h apu.h apumem.h snes9x.h memmap.h
apu.o: spc700.h apu.h apumem.h snes9x.h soundux.h
soundux.o: snes9x.h soundux.h apu.h
dma.o: ppu.h dma.h memmap.h getset.h snes9x.h port.h apu.h spc700.h
cheats.o: cheats.h snes9x.h port.h memmap.h
fxemu.o: fxemu.h fxinst.h
fxinst.o: fxemu.h fxinst.h
fxdbg.o: fxemu.h fxinst.h
offsets.o: port.h snes9x.h memmap.h ppu.h apu.h cpuexec.h 65c816.h
globals.o: memmap.h spc700.h apu.h cpuexec.h ppu.h cheats.h snes9x.h gfx.h \
	   missing.h dma.h dsp1.h soundux.h
xf86.o: display.h snes9x.h memmap.h debug.h ppu.h snapshot.h gfx.h
server.o: snes9x.h port.h memmap.h netplay.h
netplay.o: snes9x.h port.h memmap.h netplay.h
snaporig.o: cpuexec.h

