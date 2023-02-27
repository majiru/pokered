
</$cputype/mkfile
TGFX=tools/$O.gfx
TCMP=tools/$O.pkmncompress
TOOLS=$TGFX $TCMP

AS=rgbasm
AFLAGS=-hL -Q8 -P includes.asm -Weverything '-Wnumeric-string=2' '-Wtruncation=1' -D _RED
LD=rgblink
LDFLAGS=-p 0x00 -d -l layout.link
FIX=rgbfix
FIFLAGS=-p 0x00 -jsv -n 0 -k 01 -l 0x33 -m 0x13 -r 03 -t 'POKEMON RED'
O=o

TARG=pokered.gbc

OFILES=\
	audio.$O\
	home.$O\
	main.$O\
	maps.$O\
	ram.$O\
	text.$O\
	gfx/pics.$O\
	gfx/sprites.$O\
	gfx/tilesets.$O\

IFILES=`{for(i in `{walk | grep asm}){ sed -n 's/.*(INCLUDE|INCBIN) "(gfx.*(2bpp|1bpp|pic))".*/\2/gp' $i}}
PICFILES=`{echo $IFILES | grep '\.pic'}
B2FILES=`{echo $IFILES | grep '\.2bpp'}
B1FILES=`{echo $IFILES | grep '\.1bpp'}
JUNK=${PICFILES:%.pic=%.2bpp}

all:V:	$TARG

check:V:	$TARG
	@{
		rfork e;
		RETAIL=`{awk '{ print $1 }' roms.sha1 | sed 1q}
		OURS=`{sha1sum pokered.gbc | awk '{ print $1 }'}
		if(~ $RETAIL $OURS)
			;
	}

$TOOLS:
	@{ cd tools && mk all}

pic:V:	$PICFILES

d1:V:	$B2FILES

d2:V:	$B1FILES

$OFILES:	pic d1 d2

$TARG: $OFILES 
	$LD $LDFLAGS -o $target $OFILES
	$FIX $FIFLAGS $target

%.$O:	%.asm
	$AS $AFLAGS -o $stem.$O $stem.asm

%.2bpp:	%.png $TOOLS
	rgbgfx -o $stem.2bpp $stem.png

%.1bpp:	%.png $TOOLS
	rgbgfx -d1 -o $stem.1bpp $stem.png

%.pic:	%.2bpp $TOOLS
	$TCMP $stem.2bpp $stem.pic

gfx/battle/move_anim_0.2bpp:	gfx/battle/move_anim_0.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/battle/move_anim_1.2bpp:	gfx/battle/move_anim_1.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target

gfx/intro/blue_jigglypuff_1.2bpp: gfx/intro/blue_jigglypuff_1.png $TOOLS
	rgbgfx -h -o $target $prereq(1)
	$TGFX -o $target $target
gfx/intro/blue_jigglypuff_2.2bpp: gfx/intro/blue_jigglypuff_2.png $TOOLS
	rgbgfx -h -o $target $prereq(1)
	$TGFX -o $target $target
gfx/intro/blue_jigglypuff_3.2bpp: gfx/intro/blue_jigglypuff_3.png $TOOLS
	rgbgfx -h -o $target $prereq(1)
	$TGFX -o $target $target
gfx/intro/red_nidorino_1.2bpp: gfx/intro/red_nidorino_1.png $TOOLS
	rgbgfx -h -o $target $prereq(1)
	$TGFX -o $target $target
gfx/intro/red_nidorino_2.2bpp: gfx/intro/red_nidorino_2.png $TOOLS
	rgbgfx -h -o $target $prereq(1)
	$TGFX -o $target $target
gfx/intro/red_nidorino_3.2bpp: gfx/intro/red_nidorino_3.png $TOOLS
	rgbgfx -h -o $target $prereq(1)
	$TGFX -o $target $target

gfx/credits/the_end.2bpp:	gfx/credits/the_end.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --interleave --png $prereq(1) -o $target $target

gfx/slots/red_slots_1.2bpp:	gfx/slots/red_slots_1.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/slots/blue_slots_1.2bpp:	gfx/slots/blue_slots_1.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target

gfx/trade/game_boy.2bpp: gfx/trade/game_boy.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --remove-duplicates -o $target $target

gfx/intro/gengar.2bpp:	gfx/intro/gengar.png $TOOLS
	rgbgfx -h -o $target $prereq(1)
	$TGFX --remove-duplicates '--preserve=0x19,0x76' -o $target $target
gfx/tilesets/flower/flower1.2bpp:	gfx/tilesets/flower/flower1.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/flower/flower2.2bpp:	gfx/tilesets/flower/flower2.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/flower/flower3.2bpp:	gfx/tilesets/flower/flower3.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/cavern.2bpp:	gfx/tilesets/cavern.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/cemetery.2bpp:	gfx/tilesets/cemetery.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/club.2bpp:	gfx/tilesets/club.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/facility.2bpp:	gfx/tilesets/facility.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/forest.2bpp:	gfx/tilesets/forest.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/gate.2bpp:	gfx/tilesets/gate.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/gym.2bpp:	gfx/tilesets/gym.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/house.2bpp:	gfx/tilesets/house.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/interior.2bpp:	gfx/tilesets/interior.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/lab.2bpp:	gfx/tilesets/lab.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/lobby.2bpp:	gfx/tilesets/lobby.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/mansion.2bpp:	gfx/tilesets/mansion.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/overworld.2bpp:	gfx/tilesets/overworld.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/tilesets_rg/flower.2bpp:	gfx/tilesets/tilesets_rg/flower.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/tilesets_rg/forest.2bpp:	gfx/tilesets/tilesets_rg/forest.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/tilesets_rg/overworld.2bpp:	gfx/tilesets/tilesets_rg/overworld.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/plateau.2bpp:	gfx/tilesets/plateau.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/pokecenter.2bpp:	gfx/tilesets/pokecenter.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/reds_house.2bpp:	gfx/tilesets/reds_house.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX '--preserve=0x48' --trim-whitespace -o $target $target
gfx/tilesets/ship.2bpp:	gfx/tilesets/ship.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/ship_port.2bpp:	gfx/tilesets/ship_port.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target
gfx/tilesets/underground.2bpp:	gfx/tilesets/underground.png $TOOLS
	rgbgfx -o $target $prereq(1)
	$TGFX --trim-whitespace -o $target $target

clean:VQ:
	for(i in $IFILES)
		rm -f $i
	for(i in $JUNK)
		rm -f $i
	rm -f *.o $TARG
	@{ cd tools && mk clean }
