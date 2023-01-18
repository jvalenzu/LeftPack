# make -k -C /Users/jvalenzu/Source/LeftPack -f /Users/jvalenzu/Source/LeftPack/Makefile

include Build/rules.mk

CPPFLAGS += -Wno-unused-variable -Werror -Wno-unused-result

INCLUDES += -IExternal
INCLUDES += -IExternal/include
INCLUDES += -I/usr/local/include

LDFLAGS += -L/usr/local/lib 

# C++ source code to object files
SRCS += Main.cpp CodeGen/BigMasks.cpp CodeGen/BigMasksMapped.cpp CodeGen/SplitMasks.cpp CodeGen/SplitMasksMapped.cpp
TEST_SRCS += Test.cpp CodeGen/BigMasks.cpp CodeGen/BigMasksMapped.cpp CodeGen/SplitMasks.cpp CodeGen/SplitMasksMapped.cpp

OBJS      := $(foreach src,$(SRCS),$(call outName,$(src)))
TEST_OBJS := $(foreach src,$(TEST_SRCS),$(call outName,$(src)))

all: LeftPack Test

LeftPack : $(OBJS) Makefile
	$(CXX) -o $@ $(OBJS) -I$(CURDIR) $(LDFLAGS) $(LIBRARIES)

Test : $(TEST_OBJS) Makefile
	$(CXX) -o $@ $(TEST_OBJS) -I$(CURDIR) $(LDFLAGS) $(LIBRARIES)

CodeGen/SplitMasks.cpp: Build/GenerateSplitMasks.pl
	perl Build/GenerateSplitMasks.pl

CodeGen/SplitMasksMapped.cpp: Build/GenerateSplitMasksMappedL.pl
	perl Build/GenerateSplitMasksMappedL.pl

CodeGen/BigMasks.cpp: Build/GenerateBigShuffleMasks.pl
	perl Build/GenerateBigShuffleMasks.pl

$(foreach src,$(SRCS),$(eval $(call srcToObj,$(src))))
$(foreach src,$(TEST_SRCS),$(eval $(call srcToObj,$(src))))

CLEAN += LeftPack

include Build/rules2.mk
