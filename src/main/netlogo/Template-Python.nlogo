extensions [hubnet-proxy]

breed [ students student ]
students-own [ user-id step-size ]

to startup
  hubnet-reset
  hubnet-proxy:start 9999
end

to setup
  clear-patches
  clear-drawing
  clear-output
  ask turtles [
    set step-size 1
    hubnet-send user-id "step-size" step-size
  ]
  reset-ticks
end

to go
  listen-clients
  every 0.1 [ tick ]
end


to listen-clients
  while [ hubnet-message-waiting? ]
  [
    hubnet-fetch-message
    ifelse hubnet-enter-message?
    [ create-new-student ]
    [
      ifelse hubnet-exit-message?
      [ remove-student ]
      [ ask students with [user-id = hubnet-message-source]
        [ execute-command hubnet-message-tag ] 
    ]
  ]
end

to create-new-student
  create-students 1 [
    set user-id hubnet-message-source
    set label user-id
    set step-size 1
    send-info-to-clients
  ]
end

to remove-student
  ask students with [user-id = hubnet-message-source] [ die ]
end

to execute-command [command]
  if command = "step-size" [ set step-size hubnet-message stop ]
  if command = "up" [ execute-move 0 stop ]
  if command = "down" [ execute-move 180 stop ]
  if command = "right" [ execute-move 90 stop ]
  if command = "left" [ execute-move 270 stop ]
end

to send-info-to-clients ;; turtle procedure
  hubnet-send user-id "location" (word "(" pxcor "," pycor ")")
end

to execute-move [new-heading]
  set heading new-heading
  fd step-size
  send-info-to-clients
end
@#$#@#$#@
GRAPHICS-WINDOW
231
10
661
461
10
10
20.0
1
10
1
1
1
0
0
0
1
-10
10
-10
10
1
1
0
ticks
30.0

BUTTON
34
51
105
84
NIL
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

BUTTON
107
51
178
84
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

@#$#@#$#@
## WHAT IS IT?

This template contains code that can serve as a starting point for creating new HubNet activities. It shares many of the basic procedures used by other HubNet activities, which are required to connect to and communicate with clients in Disease-like activities.

## HOW IT WORKS

In activities like Disease, each client controls a single turtle on the server.  These turtles are a breed called STUDENTS.  When a client logs in we create a new student turtle and set it up with the default attributes.  Students own a variable for every widget on the client that holds a state, that is, sliders, switches, choosers, and input boxes.  Whenever a user changes one of these elements on the client, a message is sent to the server.  The server catches the message and stores the result.  In this example a slider is used to demonstrate this behavior.  You can also send messages to the client-side widgets using hubnet-send.  Monitors on clients must be updated manually by the model, that is you must send a message to a monitor every time you want the value displayed to change. For example, if you have a monitor that displays the current location of the client's avatar, you must send a message to the client like this:

     hubnet-send "location" (word xcor " " ycor)

whenever the client moves.  Buttons on the client side send but do not receive messages.  When a user presses a button, a message is sent to the server.  The server catches the message and executes the appropriate commands.  In this case, the commands should always be turtle commands since the clients control only a single turtle.

## HOW TO USE IT

To start the activity press the GO button.  Ask students to login using the HubNet client or you can test the activity locally by pressing the LOCAL button in the HubNet Control Center. To see the view in the client interface check the Mirror 2D view on clients checkbox.  The clients can use the UP, DOWN, LEFT, and RIGHT buttons to move their avatar and change the amount they move each step by changing the STEP-SIZE slider.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

@#$#@#$#@
NetLogo 5.0RC2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
VIEW
252
10
682
440
0
0
0
1
1
1
1
1
0
1
1
1
-10
10
-10
10

BUTTON
85
121
147
154
up
NIL
NIL
1
T
OBSERVER
NIL
I

BUTTON
85
187
150
220
down
NIL
NIL
1
T
OBSERVER
NIL
K

BUTTON
147
154
210
187
right
NIL
NIL
1
T
OBSERVER
NIL
L

BUTTON
23
154
85
187
left
NIL
NIL
1
T
OBSERVER
NIL
J

SLIDER
39
78
189
111
step-size
step-size
1
5
2
1
1
NIL
HORIZONTAL

MONITOR
70
21
157
70
location
NIL
0
1

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
