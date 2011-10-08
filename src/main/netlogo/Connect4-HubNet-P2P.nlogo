extensions [hubnet-client]

globals[
  moves                         ; number of moves so far
  winner?                       ; false until someone wins
  player-1                      ; either Red or Black
  player-2                      ; the opposite of player 1
  current-player                ; used to control game-play
  single-headings               ; list of headings for evaluating moves
  double-headings               ; list of headings for "inside" evaluation of moves
  undo-turtle
  winner-list
]

patches-own [anyone?           ; is there a checker here?
  type-here         ; color of checker here
  column
  row
]

turtles-own [my-row
  my-column
]

to startup
  setup
  hubnet-reset
end

to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  clear-output
  print " Would you like to play?"
  print " Pick a checker to begin"
  set winner? false
  set winner-list []
  setup-rows-and-columns
  set double-headings [45 90 135 180]
  ask patches [
    ifelse pycor = max-pycor 
    [set pcolor grey  
      set type-here grey 
      set anyone? false]  ; fills the un-needed row
    [ set pcolor yellow    ; create the game-board
      set anyone? false
      sprout 1 [ set shape "circle"       ; make the game-board 
        set color white 
        ask patch-here [set type-here white]]         ; look authentic 
    ] ]  
  set undo-turtle nobody  
  ifelse select-color-player-1 = "red"  [set player-1 "Red"  
    set player-2 "Black"] 
  [set player-1 "Black" 
    set player-2 "Red"]
  set current-player player-1
end

to setup-rows-and-columns
  ask patches [
    if pxcor = -3 [set column 1]
    if pxcor = -2 [set column 2]
    if pxcor = -1 [set column 3]
    if pxcor =  0 [set column 4]
    if pxcor =  1 [set column 5]
    if pxcor =  2 [set column 6]
    if pxcor =  3 [set column 7]
    
    if pycor = 2 [set row 1]
    if pycor = 1 [set row 2]
    if pycor = 0 [set row 3]
    if pycor = -1 [set row 4]
    if pycor = -2 [set row 5]
    if pycor = -3 [set row 6]
  ]
end

to set-single-headings            ; necessary to evaluate each move from the end
  if my-column = 1 and my-row < 4 [ set single-headings [90 135 180]]
  if my-column = 1 and my-row >= 4 [set single-headings [ 0 45 90]]
  if my-column = 2 or my-column = 3 and my-row < 4 [ set single-headings [90 135 180]]
  if my-column = 2 or my-column = 3 and my-row >= 4 [set single-headings [ 0 45 90]]
  if my-column = 4 and my-row < 4 [ set single-headings [90 135 180 225 270]]
  if my-column = 4 and my-row >= 4 [ set single-headings [0 45 90 270 315]]
  if my-column = 5  or my-column = 6 and my-row < 4 [ set single-headings [180 225 270]]
  if my-column = 5 or my-column = 6 and my-row >= 4[ set single-headings [0 270 315]]
  if my-column = 7 and my-row < 4 [ set single-headings [180 225 270]]
  if my-column = 7 and my-row >= 4 [set single-headings [ 0 315 270]]
end

to add-piece [x]     ; each button has x as its column number
  let open 0
  let type-color 0
  let move-complete 0
  let listing 0
  let player-1-count 0
  let player-2-count 0
  
  ifelse winner? = true [ setup ] [    ;; don't continue if the game is over
    ask turtles with [shape = "last-piece"] [set shape "circle"]
    set moves moves + 1
    set move-complete false 
    set listing [-3 -2 -1 0 1 2]       ;; used to see if there are any legal sites
    if [anyone?] of patch x 2 != true [ 
      crt 1 [ set undo-turtle self
        ifelse not show-last-played? [set shape "circle"]
        [set shape "last-piece"] 
        ifelse current-player = "Black" [set color black set type-color black ] 
          [set color red set type-color red]
        ifelse current-player = player-1 [set player-1-count player-1-count + 1 ]
          [set player-2-count player-2-count + 1 ]
        
        without-interruption [  
          foreach listing [
            ask patch x ? [if anyone? = false and move-complete = false
              [set open pycor       
                set anyone? true     ;; this patch is now used
                set move-complete true  ;; this turn is now over
                set type-here type-color] ]  ;;assigning the patch the checker color
          ]   ] 
        setxy x open                 ;; add the new checker
        set my-column [column] of patch-here   ;; assign a column and row
        set my-row [row] of patch-here
        
        set-single-headings   
        if moves >= 7 [check-for-winner ]
        if moves = 42 and winner? = false [
          print " No More Moves Left - Its a Draw!" 
          print " Hit Play Again? to re-start"] ]]
    
    ;if winner? = true [wait .4 if user-yes-or-no "Game Over! Would You like to Play Again?"
    ;                [ setup ]]
    
    ifelse player-1-count > player-2-count [set current-player player-2]
      [set current-player player-1] 
  ]
  
end

to update-color   ;; used to change the starting player's color
  ifelse select-color-player-1 = "red"  [set player-1 "Red"  
    set player-2 "Black"] 
  [set player-1 "Black" 
    set player-2 "Red"]
  set current-player player-1
end

to check-for-winner
  let mycolor 0
  let win? 0
  let points 0
  let origin 0
  
  set points 0
  set mycolor color          ; color of turtle for patches to evaluate
  set win? false
  
  ;;check four to the left, right, or diagonal for a win
  without-interruption [
    foreach single-headings [ if not win? [ set winner-list []  
      ask patch-here [ set winner-list lput self winner-list
        ask patch-at-heading-and-distance ? 1 [   ; check one out checker away
          if type-here = mycolor [ set winner-list lput self winner-list ;; do the color's match?
            ask patch-at-heading-and-distance ? 1 [ if type-here = mycolor [ set winner-list lput self winner-list ;;if yes above, check two out
              ask patch-at-heading-and-distance ? 1 [ if type-here = mycolor  [ set win? true set winner-list lput self winner-list ] ; if three check out you win!
                
              ] ]]]]  ]]]]
  
  ;; if no winner yet, look two the right and two to the left on all headings for columns 3 - 5 
  if win? != true and xcor > -2 and xcor < 2 [   ;; if you didn't win with the single evaluations - looking at the end of each string
    without-interruption [
      foreach double-headings [ if not win? [ set winner-list []    ;; look at the two-way or double evaluations
        set points 0
        ask patch-here [ set origin self  set winner-list lput self winner-list
          
          ;; ask first one out 
          ask patch-at-heading-and-distance ? 1 [ 
            if type-here = mycolor [ set points points + 1  set winner-list lput self winner-list   ;; only continue if there is another one on this heading
              ask patch-at-heading-and-distance ? 1 [   ;;ask patch two out
                if type-here = mycolor [set points points + 1 set winner-list lput self winner-list ] 
                ask origin [ask patch-at-heading-and-distance (? + 180) 1 [   ;; now go back and go in the opposite direction
                  if type-here = mycolor [set points points + 1 set winner-list lput self winner-list
                    ifelse points = 3 [set win? true] [   
                      ask patch-at-heading-and-distance (? + 180) 1 [ 
                        if type-here = mycolor [set points points + 1 set winner-list lput self winner-list
                          if points = 3 [set win? true ]
                        ]]]]]]]]]]    ]    ]  ]    ]
  
  ;; look two to the right and one to the left for column 2 (xcor = -2)
  if win? != true and xcor = -2 [   ;; if you didn't win with the single evaluations - looking at the end of each string
    without-interruption [ 
      foreach double-headings [  if not win? [ set winner-list []    ;; look at the two-way or double evaluations
        
        set points 0
        ask patch-here [ set origin self set winner-list lput self winner-list 
          
          ;; ask first one out 
          ask patch-at-heading-and-distance ? 1 [ 
            if type-here = mycolor [ set points points + 1  set winner-list lput self winner-list  ;; only continue if there is another one on this heading
              ask patch-at-heading-and-distance ? 1 [   ;;ask patch two out
                if type-here = mycolor [set points points + 1 set winner-list lput self winner-list] 
                ask origin [ask patch-at-heading-and-distance (? + 180) 1 [   ;; now go back and go in the opposite direction
                  if type-here = mycolor [set points points + 1 set winner-list lput self winner-list
                    ifelse points = 3 [set win? true] [ ]
                  ]]]]]]]]]] ]         
  
  ;; finally, look one to the right, and two to the left for column 6 (pxcor 2)
  if win? != true and xcor = 2 [   
    without-interruption [
      foreach double-headings [ if not win? [ set winner-list []     ;; look at the two-way or double evaluations
        
        set points 0
        ask patch-here [ set origin self  set winner-list lput self winner-list
          
          ;; ask first one out 
          ask patch-at-heading-and-distance ? 1 [ 
            if type-here = mycolor [ set points points + 1 set winner-list lput self winner-list   ;; only continue if there is another one on this heading
              ask origin [ask patch-at-heading-and-distance (? + 180) 1 [   ;; now go back and go in the opposite direction
                if type-here = mycolor [set points points + 1 set winner-list lput self winner-list
                  ifelse points = 3 [set win? true] [   
                    ask patch-at-heading-and-distance (? + 180) 1 [ 
                      if type-here = mycolor [set points points + 1 set winner-list lput self winner-list
                        if points = 3 [set win? true ]
                      ]]]]]]]]]]    ]    ]    ]
  
  ;; if the game is won, end it!
  if win? = true [set winner? true   ; ending the game
    print (word " " current-player " won the game in " round (moves / 2) " moves!")
    
    if show-winner? = true [
      without-interruption [
        foreach winner-list [ ask ? [set pcolor green]
          ask turtles with [shape = "last-piece"] [set shape "circle"]                
        ]
      ]]                
    ]
end


to undo-move    ;; to enable you to undo a move.  
  if not winner?  and undo-turtle != nobody [
    ask undo-turtle [ ask patch-here [set anyone? false ] die]
    ifelse current-player = player-2 [set current-player player-1] [set current-player player-2]
  ]
end

to listen-clients
  while [ hubnet-message-waiting? ]
  [
    hubnet-fetch-message
    if not (hubnet-enter-message? or hubnet-exit-message?) [
      add-piece read-from-string hubnet-message-tag - 4
    ]
  ]
end

to connect-to-9173 hubnet-client:connect "red" "localhost" 9173 end
to connect-to-9174 hubnet-client:connect "black" "localhost" 9174 end

to local-click [col]
  add-piece col - 4
  hubnet-client:click-button (word "" col)
end
@#$#@#$#@
GRAPHICS-WINDOW
273
10
661
419
3
3
54.0
1
10
1
1
1
0
1
1
1
-3
3
-3
3
0
0
1
ticks
30.0

BUTTON
275
432
330
465
1
local-click 1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
329
432
384
465
2
local-click 2
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
383
432
438
465
3
local-click 3
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
437
432
492
465
4
local-click 4
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
492
432
547
465
5
local-click 5\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
545
432
600
465
6
local-click 6
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
599
432
654
465
7
local-click 7
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
31
388
120
464
Start Over?
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
195
167
262
212
Next-Up
current-player
3
1
11

MONITOR
195
64
262
109
  Player 1
player-1
3
1
11

MONITOR
195
116
262
161
  Player 2
player-2
3
1
11

TEXTBOX
15
10
178
72
        CONNECT FOUR!\nBe the first to get four checkers in a row, column, or on a diagonal.
11
0.0
0

MONITOR
195
13
262
58
   Moves
round (moves / 2 )
3
1
11

TEXTBOX
405
469
495
487
Select a Column!
11
0.0
0

BUTTON
137
431
254
464
Undo last move
undo-move
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
4
84
124
129
select-color-player-1
select-color-player-1
"red" "black"
1

BUTTON
129
85
184
118
update
update-color
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
4
133
124
166
show-winner?
show-winner?
0
1
-1000

SWITCH
4
169
149
202
show-last-played?
show-last-played?
0
1
-1000

BUTTON
52
256
164
289
NIL
listen-clients
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
37
293
177
326
NIL
connect-to-9173
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
37
329
177
362
NIL
connect-to-9174\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This model is a Netlogo version of the classic Milton Bradley/Hasbro game "Connect Four: The Vertical Four-in-a-Row Checkers Game."  It is intended to be a two-player game, and is entirely for fun!  

The rules are simple.  Each player places a colored-checker in one of the seven slots.  The first player to get four in a row, column, or on a diagonal wins.  

## HOW IT WORKS

SETUP creates the game board, with seven columns and six rows.  The grey space at the top of the screen is necessary because Netlogo's graphic canvas won't permit the exact dimensions of the game space.  The white "holes" are turtles that serve as place-holders for the colored checkers.  They have no other function in the game.   

SETUP-COLUMNS-AND-ROWS is probably not necessary, but it simplifies the procedure used to evaluate whether the game has been won.

ADD-PIECE [x] is called by the seven buttons on the bottom of the screen. They are used by the players to add each checker to the board.  ADD-PIECE [x] finds the first "empty" space in the relevant column, and inserts a checker of the player's color.  This procedure uses a list to evaluate possible y coordinates to find the first empty space in a column.  Once placed on the board, the new turtle sets its color to that of the player, and uses SET-POSSIBLE-HEADINGS to set its own list of possible headings for evaluating each move. 

CHECK-FOR-WINNER is only run after seven moves have been completed.  This procedure uses the single-headings and double-headings lists to look in each of the legal directions to determine if the most recently-played checker has won the game.  SETUP-SINGLE-HEADINGS creates the list for each piece based on its row and column.  

CHECK-FOR-WINNER looks first to see if the latest piece is at the end of a chain of 4 like-checkers (single-headings), and then looks to see if it is inside (not on the end) of a string of four checkers.  This analysis involves looking forward two checkers on a heading, and then "turning around" (by adding 180 degrees to the heading) to look at the two checkers in the opposite direction.   The double-heading analysis is done in three steps, with different rules depending on the xcor of the checker.   The replication of code is necessary to avoid accidental wrapping of the screen producing a false win.
    

When the game is over, the command window prints which side won, and in how many steps.  A dialog box is opened to play again.

## HOW TO USE IT

It's pretty self-explanatory.  Find a friend, and start seeing who can win the game first.  Its the 1970's version of outwit, outlast, and outplay!  

If you want to change the starting player's color, use the SELECT-PLAYER-1 choice and hit UPDATE COLORS.  

Turn on SHOW-WINNER? to reveal the winning pattern when the game is over.

Turn on SHOW-LAST-PLAYED? to highlight the most recent checker piece played.

If you accidentally hit one of the column buttons twice, or if you made a move you want to take back, hit the UNDO MOVE button!  

## THINGS TO NOTICE

The code for this model is relatively short, with just three critical procedures. (STARTUP loads the model but isn't necessary, nor is UNDO-MOVES, SETUP-ROWS-AND-COLUMNS, and UPDATE-COLORS).  

Notice how the ADD-PIECES and CHECK-FOR-WINNERS procedures enable the game to work.  That is the heart of the model.  While CHECK-FOR-WINNER is long, it basically repeats the same procedures multiple times.  

The game will only run under Netlogo 2.0 and later because of its reliance on the "ask patch-at-heading-and-distance" primitive.

The model is not really "agent-based" in the traditional sense of the word, but it illustrates the robustness of the Netlogo environment and its ease of use.  And it is just plain fun to play!

## EXTENDING THE MODEL

One possible extension would be to build a procedure that would provide a "Help" mode - either pointing out existing patterns of three like-checkers or warning when a player is   
"in check."  

Another extension would be to have the checkers appear at the top of the screen, and then "drop" into place in each column.  

Re-write the Add-Pieces code so that the last piece has a visual marker on it.

A one-player version of the game (with a computer opponent) is probably the most challenging extension to the model, and would certainly take longer than the initial model to code, but it would be an amazing accomplishment!

## RELATED MODELS

This model is related to the game models in the Netlogo Models Library.  Unlike Frogger and Pac-Man, which require the awkward use of buttons to replicate the original joysticks, CONNECT FOUR plays completely like the original - withthe one exceptions of having the ability to make all the checkers drop to the table.

## CREDITS AND REFERENCES

This model was inspired by the Hasbro game "CONNECT FOUR" and is dedicated to Nicholas Gizzi, an enthusiastic six year-old who is fascinated by the original Connect Four, and is now learning to move virtual turtles around a computer screen!  He dutifully beta-tested this model.
    

The model was created by Michael C. Gizzi with assistance from Boyce Baker and Richard Vail. The model is copyright 2003 by the Center for Agent-Based Modeling, Mesa State College, 2508 Blichman Avenue, Grand Junction, CO 81505.  http://www.modelingcomplexity.org.  

The original board game CONNECT FOUR is copyright Hasbro 1998.  

## THE MODEL IS INTENDED SOLELY FOR EDUCATIONAL AND ENTERTAINMENT PURPOSES.  IT MAY NOT BE REPRODUCED FOR COMMERCIAL USE WITHOUT VIOLATING EITHER OF THE COPYRIGHTS LISTED HERE.   
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -1184463 true false 151 152 137 77 105 67 89 67 66 74 48 85 36 100 24 116 14 134 0 151 15 167 22 182 40 206 58 220 82 226 105 226 134 222
Polygon -16777216 true false 151 150 149 128 149 114 155 98 178 80 197 80 217 81 233 95 242 117 246 141 247 151 245 177 234 195 218 207 206 211 184 211 161 204 151 189 148 171
Polygon -7500403 true true 246 151 241 119 240 96 250 81 261 78 275 87 282 103 277 115 287 121 299 150 286 180 277 189 283 197 281 210 270 222 256 222 243 212 242 192
Polygon -16777216 true false 115 70 129 74 128 223 114 224
Polygon -16777216 true false 89 67 74 71 74 224 89 225 89 67
Polygon -16777216 true false 43 91 31 106 31 195 45 211
Line -1 false 200 144 213 70
Line -1 false 213 70 213 45
Line -1 false 214 45 203 26
Line -1 false 204 26 185 22
Line -1 false 185 22 170 25
Line -1 false 169 26 159 37
Line -1 false 159 37 156 55
Line -1 false 157 55 199 143
Line -1 false 200 141 162 227
Line -1 false 162 227 163 241
Line -1 false 163 241 171 249
Line -1 false 171 249 190 254
Line -1 false 192 253 203 248
Line -1 false 205 249 218 235
Line -1 false 218 235 200 144

bird1
false
0
Polygon -7500403 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7500403 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7500403 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7500403 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7500403 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7500403 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7500403 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7500403 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7500403 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

circle
false
0
Circle -7500403 true true 35 35 230

last-piece
false
0
Circle -7500403 true true 35 35 230
Rectangle -13791810 true false 118 122 185 183
Rectangle -7500403 true true 97 103 197 194
Circle -1 true false 133 132 34
Rectangle -7500403 true true 120 120 171 168
Circle -7500403 true true 130 132 36
Circle -1 true false 138 137 28

person
false
0
Circle -7500403 true true 155 20 63
Rectangle -7500403 true true 158 79 217 164
Polygon -7500403 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7500403 true true 216 83 267 123 248 143 215 107
Polygon -7500403 true true 167 163 145 234 183 234 183 163
Polygon -7500403 true true 195 163 195 233 227 233 206 159

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92

spacecraft
true
0
Polygon -7500403 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7500403 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7500403 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8630108 true false 195 75 195 120 240 120 240 75
Polygon -8630108 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7500403 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8630108 true false 90 210 105 225 120 210
Polygon -8630108 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7500403 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8630108 true false 210 210 195 225 180 210
Polygon -8630108 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7500403 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7500403 true true 15 105 105 165
Rectangle -7500403 true true 45 90 105 105
Polygon -7500403 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7500403 true true 105 120 263 195
Rectangle -7500403 true true 108 195 259 201
Rectangle -7500403 true true 114 201 252 210
Rectangle -7500403 true true 120 210 243 214
Rectangle -7500403 true true 115 114 255 120
Rectangle -7500403 true true 128 108 248 114
Rectangle -7500403 true true 150 105 225 108
Rectangle -7500403 true true 132 214 155 270
Rectangle -7500403 true true 110 260 132 270
Rectangle -7500403 true true 210 214 232 270
Rectangle -7500403 true true 189 260 210 270
Line -7500403 true 263 127 281 155
Line -7500403 true 281 155 281 192

wolf-left
false
3
Polygon -6459832 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6459832 true true 87 80 79 55 76 79
Polygon -6459832 true true 81 75 70 58 73 82
Polygon -6459832 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6459832 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6459832 true true 116 140 114 189 105 137
Rectangle -6459832 true true 109 150 114 192
Rectangle -6459832 true true 111 143 116 191
Polygon -6459832 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6459832 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6459832 true true 214 134 203 168 192 148
Polygon -6459832 true true 204 151 203 176 193 148
Polygon -6459832 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6459832 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6459832 true true 201 99 214 69 215 99
Polygon -6459832 true true 207 98 223 71 220 101
Polygon -6459832 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6459832 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6459832 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6459832 true true 48 143 58 141
Polygon -6459832 true true 46 136 68 137
Polygon -6459832 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6459832 true true 38 138 66 149
Polygon -6459832 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6459832 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 5.0RC2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
