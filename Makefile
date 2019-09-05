CC              =       icc
CCFLAGS = -O3 -qopenmp -qopt-report-phase=vec -qopt-report=5 -static-libstdc++ -static-libstdc++ -std=c++11 -Wno-unused-parameter -fno-alias -fargument-noalias -fstrict-aliasing
ifeq ($(VEC), yes)
	CCFLAGS += -march=ivybridge -qopt-prefetch -unroll
else ifeq ($(KNL),yes)
	CCFLAGS +=  -march=knl -qopt-prefetch -qopt-streaming-stores always
else ifeq ($(PAR),yes)
    CCFLAGS += -march=ivybridge -qopt-prefetch -unroll -qopt-streaming-stores always
else
	CCFLAGS += -qopt-prefetch=2 -no-vec -unroll -unroll-aggressive -qopt-streaming-stores always #-qopt-mem-layout-trans
endif
#

BIN_NAME = dot_product
SRC_DIR = src
BIN_DIR = bin
OBJ_DIR = obj
HEADER_DIR = header
BUILD_DIR = build
ASM_DIR = asm
SRC = $(wildcard $(SRC_DIR)/*.cpp)
OBJ = $(patsubst src/%.cpp,build/%.o,$(SRC))
ASM = $(patsubst src/%.cpp,asm/%.s,$(SRC))
INCLUDES = -I$(HEADER_DIR)
vpath %.cpp $(SRC_DIR)
#######
#RULES
#######
.DEFAULT_GOAL = all


$(BIN_DIR)/$(BIN_NAME):  $(OBJ) $(ASM)
	$(CC) $(CCFLAGS) $(INCLUDES) $(LIBS) -o $@ $(OBJ)
$(BUILD_DIR)/%.o: %.cpp
	$(CC) -c $(CCFLAGS) $(INCLUDES) $(LIBS) $< -o $@
$(ASM_DIR)/%.s: %.cpp
	$(CC) -c $(CCFLAGS) -S $(INCLUDES) $(LIBS) $< -o $@

checkdirs:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(ASM_DIR)

all: checkdirs $(BIN_DIR)/$(BIN_NAME)

delete:
	rm -rf $(BUILD_DIR) $(BIN_DIR) $(ASM_DIR) $(OBJ_DIR)
clean:
	rm -rf $(BUILD_DIR)/* $(BIN_DIR)/* $(ASM_DIR)/* $(OBJ_DIR)/*
