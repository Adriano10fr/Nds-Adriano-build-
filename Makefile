.SUFFIXES:

ifeq ($(strip $(DEVKITARM)),)
$(error DEVKITARM is not set)
endif

include $(DEVKITARM)/ds_rules

TARGET := AdrianoPrototype
BUILD := build
SOURCES := source
INCLUDES :=

ARCH := -march=armv5te -mtune=arm946e-s -mthumb

CFLAGS := -g -Wall -O2 -ffunction-sections -fdata-sections $(ARCH)
CFLAGS += $(INCLUDE) -DARM9

CXXFLAGS := $(CFLAGS) -fno-rtti -fno-exceptions
ASFLAGS := -g $(ARCH)

LDFLAGS := -specs=ds_arm9.specs -g $(ARCH)

LIBS := -lnds9
LIBDIRS := $(LIBNDS)

ifneq ($(BUILD),$(notdir $(CURDIR)))

export OUTPUT := $(CURDIR)/$(TARGET)
export VPATH := $(CURDIR)/source
export DEPSDIR := $(CURDIR)/$(BUILD)

CFILES := $(notdir $(wildcard $(SOURCES)/*.c))
OFILES := $(CFILES:.c=.o)

export LD := $(CC)
export OFILES := $(OFILES)

export INCLUDE := $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir)) \
                  $(foreach dir,$(LIBDIRS),-I$(dir)/include) \
                  -I$(CURDIR)/$(BUILD)

export LIBPATHS := $(foreach dir,$(LIBDIRS),-L$(dir)/lib)

.PHONY: all clean

all: $(BUILD)

$(BUILD):
	mkdir -p $@
	$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

clean:
	rm -rf $(BUILD) $(TARGET).elf $(TARGET).nds

else

DEPENDS := $(OFILES:.o=.d)

$(OUTPUT).nds: $(OUTPUT).elf

$(OUTPUT).elf: $(OFILES)

%.o: %.c
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

-include $(DEPENDS)

endif
