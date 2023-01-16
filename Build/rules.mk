# can't define any targets in here, just macros

empty:=
slash=/
underscore=_
slash_to_underscore = $(subst $(slash),$(underscore),$1)
space:=$(empty) $(empty)
first_dot = $(subst $(space),.,$(wordlist 1, 2,$(subst ., ,$(1))))

CPPFLAGS += -Wno-parentheses
CPPFLAGS += -Wno-deprecated-declarations
CPPFLAGS += -Wc++11-extensions

ifeq ($(BUILD_TYPE),Release)
CPPFLAGS += -O2 -g -fprofile-instr-generate -fcoverage-mapping
CPPFLAGS += -DNDEBUG=1
else
#CPPFLAGS += -fstack-protector-strong
CPPFLAGS += -g -O2
CPPFLAGS += -D_DEBUG=1
endif

CXXFLAGS += -std=c++11 -stdlib=libc++ 

ifeq ($(BUILD_TYPE),Release)
LDFLAGS += -Wc++11-extensions -fprofile-instr-generate
else
LDFLAGS += -Wc++11-extensions
endif

# C++ generated code with dependencies
outName = obj/$(basename $(call slash_to_underscore,$1)).o
depName = obj/$(basename $(call slash_to_underscore,$1)).d

define srcToObj

ifeq (x$(filter %.cpp, $1),x)
$(call outName,$1) : obj/dummy $1 $(call depName,$1) Makefile
	$(CC) $(CPPFLAGS) $(CCFLAGS) -MMD $(INCLUDES) -I$(CURDIR) -c -o $(call outName,$1) $1
else
$(call outName,$1) : obj/dummy $1 $(call depName,$1) Makefile
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD $(INCLUDES) -I$(CURDIR) -c -o $(call outName,$1) $1
endif

$(call depName,$1) : $1

# depname
-include $(call depName,$1)

CLEAN += $(call depName,$1)
CLEAN += $(call outName,$1)
endef
