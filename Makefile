
BASENAME = ThemeExplorer.exe

INCDIR ?= include
SRCDIR ?= src
BINDIR ?= bin
OBJDIR ?= obj

GCC ?= gcc

CC = $(GCC) -c
LD = $(GCC)
WINDRES = windres
DLLTOOL = dlltool
DEP = $(GCC) -x c -MM -MG
RM = rm -rf

INCLUDES = -I$(INCDIR) -I$(SRCDIR)


WINVER = -D_WIN32_IE=0x0601 -D_WIN32_WINNT=0x0601 -DWINVER=_WIN32_WINNT
UNICODE = -DUNICODE -D_UNICODE

override CPPFLAGS += $(UNICODE) $(WINVER) $(INCLUDES)
override CFLAGS += -Wall
override LDFLAGS += -mwindows
override LIBS += -lcomctl32 -luxtheme

ifndef DEBUG
    DEBUG = 0
endif
ifneq ($(DEBUG),0)
	override CPPFLAGS += -DDEBUG=$(DEBUG)
	override CFLAGS += -g -O0
else
	override CFLAGS += -O3
	override LDFLAGS += -s
endif

HEADERS = $(wildcard $(SRCDIR)/*.h)
C_SOURCES = $(wildcard $(SRCDIR)/*.c)
RC_SOURCES = $(wildcard $(SRCDIR)/*.rc)
SOURCES = $(C_SOURCES) $(RC_SOURCES)
C_OBJECTS = $(addprefix $(OBJDIR)/, $(notdir $(addsuffix .o,$(basename $(C_SOURCES)))))
RC_OBJECTS = $(addprefix $(OBJDIR)/, $(notdir $(addsuffix .o,$(basename $(RC_SOURCES)))))
OBJECTS = $(addprefix $(OBJDIR)/, $(notdir $(addsuffix .o,$(basename $(SOURCES)))))
TARGET = $(BINDIR)/$(BASENAME)


####################
# The main targets #
####################

.PHONY: all clean

all: $(TARGET)

clean:
	$(RM) $(OBJECTS)
	$(RM) $(TARGET)


################
# Dependencies #
################

# The dependencies are automatically detected by scanning all sources in src/.

Makefile.dep: $(SOURCES) $(HEADERS)
	$(RM) Makefile.dep
	echo "# This file is automatically (re)generated by Makefile when any source" >> Makefile.dep
	echo "# is modified or when new source is added into the src/ directory." >> Makefile.dep
	echo "# Do not modify this file manually." >> Makefile.dep
	echo >> Makefile.dep
	echo >> Makefile.dep
	$(DEP) $(CPPFLAGS) $(SOURCES) | sed "/\.o:/ s/^/$(subst /,\\/,$(OBJDIR))\//" >> Makefile.dep
	echo "$(RC_OBJECTS): $(wildcard $(SRCDIR)/res/*)" >> Makefile.dep
	echo >> Makefile.dep

include Makefile.dep


###############
# Build rules #
###############

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.rc
	$(WINDRES) $(filter-out -DUNICODE -D_UNICODE, $(CPPFLAGS)) -I$(SRCDIR) $< $@


