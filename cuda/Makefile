# declaration
UNAME = $(shell uname)

COMMON_CFLAGS = -g -std=c++17 -I include -L lib 

ifeq ($(UNAME), Linux)
	# specific for Linux
	CC = gcc
	CFLAGS = -Wall -fPIC $(COMMON_CFLAGS)
	LDFLAGS = -l stdc++ -I /opt/cuda/include -L /opt/cuda/lib64 -l cudart -l m
	NVCC = nvcc
	NVCCFLAGS += --compiler-options -fPIC $(COMMON_CFLAGS)
endif
ifeq ($(UNAME), Darwin)
	# specific for MacOS
endif

# compile cuda object
CUDA_OBJECT_SRC_LIST = $(shell find src -name "*.cu")
CUDA_OBJECT_OUT_LIST = $(patsubst src/%.cu,obj/%.o,$(CUDA_OBJECT_SRC_LIST))
obj/%.o: src/%.cu
	@mkdir -p $(dir $@)
	$(NVCC) $(NVCCFLAGS) -c -o $@ $<


# compile object
OBJECT_SRC_LIST = $(shell find src -name "*.cpp") # recursive wildcard
OBJECT_OUT_LIST = $(patsubst src/%.cpp,obj/%.o,$(OBJECT_SRC_LIST))
obj/%.o: src/%.cpp
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

# link library
LIBRARY_SRC_LIST = $(wildcard src/*)
LIBRARY_OUT_LIST = $(patsubst src/%,lib/lib%.so,$(LIBRARY_SRC_LIST))
lib/lib%.so: # not sure how to put in the dependencies here
	@mkdir -p lib
	$(CC) $(CFLAGS) -shared -o $@ obj/$*/*.o $(LDFLAGS)

# compile and link target
TARGET_SRC_LIST = $(wildcard target/*.cpp)
TARGET_OUT_LIST = $(patsubst target/%.cpp,bin/%,$(TARGET_SRC_LIST))
THIS_LDFLAGS = $(patsubst src/%,-l %,$(LIBRARY_SRC_LIST))
bin/%: target/%.cpp
	@mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(THIS_LDFLAGS)

all: $(CUDA_OBJECT_OUT_LIST) $(OBJECT_OUT_LIST) $(LIBRARY_OUT_LIST) $(TARGET_OUT_LIST)

clean:
	rm -rf obj lib bin

.PHONY: clean all