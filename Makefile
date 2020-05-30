SDCC ?= sdcc
STCCODESIZE ?= 4089
SDCCOPTS ?= --iram-size 256 --code-size $(STCCODESIZE) --xram-size 0 --data-loc 0x30 --disable-warning 126 --disable-warning 59
SDCCREV ?= -Dstc15w404as
STCGAL ?= stcgal/stcgal.py
STCGALOPTS ?= 
STCGALPORT ?= /dev/ttyS5
STCGALPROT ?= stc15
FLASHFILE ?= main.hex
SYSCLK ?= 11059
CFLAGS ?= -DWITH_ALT_LED9 -DWITHOUT_LEDTABLE_RELOC -DWITHOUT_DATE -DDEBUG -DWITHOUT_SNOOZE

SRC = src/adc.c src/ds1302.c

OBJ=$(patsubst src%.c,build%.rel, $(SRC))

all: main eeprom flash

build/%.rel: src/%.c src/%.h
	mkdir -p $(dir $@)
	$(SDCC) $(SDCCOPTS) $(SDCCREV) -o $@ -c $<

main: $(OBJ)
	$(SDCC) -o build/ src/$@.c $(SDCCOPTS) $(SDCCREV) $(CFLAGS) $^
	@ tail -n 5 build/main.mem | head -n 2
	@ tail -n 1 build/main.mem
	cp build/$@.ihx $@.hex
	
eeprom:
	sed -ne '/:..1/ { s/1/0/2; p }' main.hex > eeprom.hex

flash:
	$(STCGAL) -p $(STCGALPORT) -P $(STCGALPROT) -t $(SYSCLK) $(STCGALOPTS) $(FLASHFILE)

clean:
	rm -f *.ihx *.hex *.bin
	rm -rf build/*

cpp: SDCCOPTS+=-E
cpp: main
