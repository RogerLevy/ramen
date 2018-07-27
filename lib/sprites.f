\ Sprite objects!
\ - Render subimages or image regions
\ - Define animation data and animate sprites

\ Region tables
6 cells constant /region
    \ x , y , w , h , originx , originy , 

3 cells constant /frame
    \ index+flip , ofsx , ofsy , 
    \ hflip = $1
    \ vflip = $2
    \ index is fixed point

redef on
    \ Transformation info; will be factored out into Ramen's core eventually
    var sx  var sy  var ang  var cx  var cy
    color sizeof field tint

    \ animation state:
    var img  var anm  var rgntbl  var anmspd  var anmctr    \ all can be modified freely.  only required value is ANM.
redef off

\ Drawing
: sprite ( image srcx srcy w h flip )  \ pass a rectangle defining the region to draw
    locals| flip h w y x |
    image.bmp @  x y w h 4af  tint 4@ 4af  cx 2@  at@  4af  sx 3@ 3af  flip
        al_draw_tinted_scaled_rotated_bitmap_region ;
: objsubimage  ( image n flip -- )  >r  over >subxywh  r> sprite ;

\ Get current frame data
: curframe  ( -- srcx srcy w h )
    rgntbl @ ?dup if
        anm @ @  /region * +  4@
    else
        anm @ @  img @  >subxywh
    then ;
: curflip  anm @ @ #3 and ;

\ Draw + animate
defer animlooped ( -- )  :is animlooped ;  \ define this in your app to do stuff every time an animation ends/loops
: sprite+  ( -- )
    anm @ -exit
    anm @ cell+ 2@ +at  \ apply the offset
    img @ ?dup if  curframe  curflip sprite  then
    anmspd @ anmctr +!
    begin  anmctr @ 1 >= while
        anmctr --  /frame anm +!
        anm @ @ $deadbeef = if  anm @ cell+ @ anm +!  animlooped  then
    repeat
;

\ Play an animation.
: /scale  1 1 sx 2! ;
: /tint   1 1 1 1 tint 4! ;
: /animate  anm @ ?exit  /scale  /tint ;  \ first time call initializes scale and tint
: animate  ( anim -- )  /animate  anm !  0 anmctr !  draw> sprite+ ;

\ Define self-playing animations
: anim:  ( image regiontable|0 speed -- loopaddr )  ( -- )  \ when defined word is called, animation plays
    create  3,  here
    does>  @+ img !  @+ rgntbl !  @+ anmspd !   animate ;
: frames,  for  3dup 3, loop 3drop  ;
: loop:  drop here ;
: ;anim  ( loopaddr -- )  here -  $deadbeef ,  , ;
: animrange,  ( start len -- ) over + swap do  i , 0 , 0 ,  loop  ;

\ Animation tables
: addanim:  ( cellstack -- cellstack loopaddr ) here over push here ;
