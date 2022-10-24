CC = cc

CFLAGS = -Wall -g -std=c++17 -fPIC -I . -I include -L lib
LDFLAGS = -l stdc++ -l clblast
LIBRARY = OpenclExample

LIBRARY_FILE = lib/lib$(LIBRARY).so

UNAME = $(shell uname)

ifeq ($(UNAME), Linux)
LDFLAGS += -l OpenCL -fopenmp
endif
ifeq ($(UNAME), Darwin)
CFLAGS += -I /opt/homebrew/include/ -I/opt/homebrew/opt/libomp/include -L /opt/homebrew/lib -L/opt/homebrew/opt/libomp/lib
LDFLAGS += -framework OpenCL -l omp
endif

# $(wildcard src/*.cpp): get all .cpp files from current dir
TRG_FILES = $(wildcard *.cpp)
# $(patsubst %.cpp,%, $(TRG_FILES)): change all .cpp files in current dir into exec files
TRG_EXECS = $(patsubst %.cpp, %.out, $(TRG_FILES))
# $(wildcard src/*.cpp): get all .cpp files from "src/"
SRC_FILES = $(wildcard src/*.cpp)
# $(patsubst src/%.cpp,obj/%.o,$(SRC_FILES)): change all .cpp files in "src/" into "obj/.o"
OBJ_FILES = $(patsubst src/%.cpp, obj/%.o, $(SRC_FILES))

KNL_FILES = $(wildcard src/kernel/*.cl)
KNL_HDRS = $(patsubst src/kernel/%.cl, src/kernel/%.cl.h, $(KNL_FILES))


build: dir $(KNL_HDRS) $(LIBRARY_FILE) $(TRG_EXECS)
	echo "done"

dir:
	mkdir -p lib obj include/kernel

%.out: %.cpp
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) -l $(LIBRARY)

src/kernel/%.cl.h: src/kernel/%.cl
	rm -f $@
	touch $@
	echo "#ifndef __$(patsubst src/kernel/%.cl.h,%, $@)__"  >> $@
	echo "#define __$(patsubst src/kernel/%.cl.h,%, $@)__"  >> $@
	xxd -i $< >> $@
	echo "#endif // __$(patsubst src/kernel/%.cl.h,%, $@)__"  >> $@


$(LIBRARY_FILE): $(OBJ_FILES)
	$(CC) $(CFLAGS) -shared -o $(LIBRARY_FILE) $(OBJ_FILES) $(LDFLAGS)


obj/%.o: src/%.cpp
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -rf $(TRG_EXECS) $(KNL_HDRS) lib obj
	
.PHONY: build dir clean