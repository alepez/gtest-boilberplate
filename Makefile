################################################################################
# Project configuration

PROJECT ?= myproject
BUILD_DIR ?= build
DIST_DIR ?= dist
CXXFLAGS ?= -std=c++14 -pedantic -Wall -Wextra -c -fmessage-length=0
LDFLAGS ?=
LIBRARIES ?=
LIBRARIES_DIRS ?=

.PHONY: default
default: lib test

################################################################################
# Library building

LDFLAGS += $(foreach librarydir,$(LIBRARIES_DIRS),-L$(librarydir))
LDFLAGS += $(foreach library,$(LIBRARIES),-l$(library))

LIB_DIR := lib
LIB_CPP := $(shell find $(LIB_DIR) -name "*.cpp")
LIB_HPP := $(shell find $(LIB_DIR) -name "*.hpp")
LIB_OBJ := $(addprefix $(BUILD_DIR)/lib/, $(patsubst $(LIB_DIR)/%,%,$(patsubst %.cpp,%.o,$(LIB_CPP))))
LIB_DEP := $(LIB_OBJ:.o=.d)

LIB_BIN := $(DIST_DIR)/lib$(PROJECT).so

.PHONY: lib
lib: $(LIB_BIN)

$(LIB_BIN): $(LIB_OBJ)
	@mkdir $(dir $@)
	$(CXX) -shared -o $@ $(LIB_OBJ) $(LDFLAGS)

################################################################################
# Test bulding

TEST_DIR := test
TEST_CPP := $(shell find $(TEST_DIR) -name "*.cpp")
TEST_OBJ := $(addprefix $(BUILD_DIR)/test/, $(patsubst $(TEST_DIR)/%,%,$(patsubst %.cpp,%.o,$(TEST_CPP))))
TEST_DEP := $(TEST_OBJ:.o=.d)

TEST_BIN := $(DIST_DIR)/test

.PHONY: test
test: $(TEST_BIN)
	@./$(TEST_BIN)

$(TEST_BIN): $(TEST_OBJ) $(LIB_OBJ)
	@mkdir -p $(dir $(TEST_BIN))
	$(CXX) -o $@ $^ -lgtest -lgtest_main -lpthread

################################################################################
# Clean

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DIST_DIR)

################################################################################
# Object files generation

# auto generated dependencies
-include $(LIB_DEP)
-include $(TEST_DEP)

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -MT$@ -MMD -MP -MF$(@:%.o=%.d) -c -o $@ $<
