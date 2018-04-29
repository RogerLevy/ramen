$000100 [version] stage-ver

0 value player
0 value cam
objlist stage

: ?check  ?dup ?exit  r> drop ;

\ -----------------------------------------------------------------------
[section] camera
create m  16 cells /allot

: track
    ?dup -exit
    cam ?check
    's x 2@  160 120 2-  cam 's x 2! ;

: camtrans
    cam ?check
    m al_identity_transform
    m  cam 's x 2@ 2pfloor 2negate 2af  al_translate_transform
    m al_use_transform ;


\ -----------------------------------------------------------------------
[section] go
: think  stage each> behave ;
: locomote  stage each>  vx x v+ ;
: playfield  stage each> draw ;
: (go)    go>  noop ;
: (step)  step>  think  stage multi  locomote ;
: (show)  show>  black backdrop  player track  camtrans  playfield ;
: go  (go)  (step)  (show) ;

