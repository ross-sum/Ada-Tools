#########################################################
#                Make file for dStrings                 #
#########################################################

# The following flag defines if static or dynamic library
# for serial_comms.  Set a value for true, leave empty for
# false.
DYNAMIC = true
# Use standard variables to define compile and link flags
#
TL=tools
TSV=test/test_vectors
TST=test/test_generic_binary_trees
TSD=test/test_generic_binary_trees_with_data
TSB=test/test_base_64
TSS=test/test_stack
SOURCE=.
ACC=gprbuild
TO=$(TL).gpr
TTV=$(TSV).gpr
TTT=$(TST).gpr
TTD=$(TSD).gpr
TTB=$(TSB).gpr
TTS=$(TSS).gpr
HOST_TYPE := $(shell uname -m)
OS_TYPE := $(shell uname -o)
ifeq ($(HOST_TYPE),amd)
        TARGET=sparc
else ifeq ($(HOST_TYPE),x86_64)
ifeq ($(OS_TYPE),Cygwin)
        TARGET=win
else
        TARGET=amd64
endif
else ifeq ($(HOST_TYPE),x86)
        TARGET=x86
else ifeq ($(HOST_TYPE),i686)
        TARGET=x86
else ifeq ($(HOST_TYPE),arm)
        TARGET=pi
else ifeq ($(HOST_TYPE),armv7l)
        TARGET=pi
else ifeq ($(HOST_TYPE),aarch64)
        TARGET=pi64
endif
TD=obj_$(TARGET)
BIN=/usr/local/bin
ETC=/usr/local/etc
LIB=/usr/local/lib
ifeq ("$1.",".")
	FLAGS=-Xhware=$(TARGET)
else
	FLAGS=-Xhware=$(TARGET) $1
endif
ifeq ($(OS_TYPE),Cygwin)
        FLAGS+=-cargs -I/usr/include/sys
endif

tools:
	echo "Building for $(HOST_TYPE) at $(TD):"
	$(ACC) -P $(TO) $(FLAGS)

tests:
	echo "Building for $(HOST_TYPE) at $(TD):"
	$(ACC) -P $(TTV) $(FLAGS)
	$(ACC) -P $(TTT) $(FLAGS)
	$(ACC) -P $(TTD) $(FLAGS)
	$(ACC) -P $(TTB) $(FLAGS)
	$(ACC) -P $(TTS) $(FLAGS)

# Define the target "all"
all:
	tools
	tests

         # Clean up to force the next compilation to be everything
clean:
	rm -f $(TD)/*.o $(TD)/*.ali $(TD)/*.a

dist-clean: distclean

distclean: clean

