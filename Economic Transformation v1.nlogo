links-own [
  old-or-new
]

globals
[
  last-turtle
  
  link-budget 
  
  old-link-color
  new-link-color

  ;; in gui
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup-preferential
  clear-all
  set old-link-color red;
  set new-link-color green;
  set link-budget 100
  ask patches [ set pcolor white ]
  make-node
  make-node
  ask one-of turtles [
    create-links-with other turtles
    ask my-links [
      set old-or-new "old"
      show old-or-new
      set color old-link-color
      show color
    ]
  ]
  repeat ( initial-number-of-nodes - 2 ) [
    make-node
    add-preferential-links
    complete-turn
  ]
end

to setup-random
  clear-all
  set link-budget 100
  ask patches [ set pcolor white ]
  make-node
  repeat ( initial-number-of-nodes - 1 ) [
    make-node
    add-random-links
    complete-turn
  ]
end

to setup-both
end

to make-node
  create-turtles 1
  [
    set shape "circle"
    set color gray
    set last-turtle self
  ]
end

to add-random-node
end

to add-preferential-node
  make-node
  add-preferential-links
  complete-turn
end

to add-preferential-links
  repeat ( 100 / preferential-link-cost ) [
    add-preferential-link
    tick
  ]
end

to add-preferential-link
  ask last-turtle [
    let partners no-turtles
    let required-partner-count 
      (min (list 1 ((count turtles) - 1)))
    while [count partners < required-partner-count] [
      let partner one-of [both-ends] of one-of links
      if (partner != self) and (not member? partner partners) [
        set partners (turtle-set partners partner)
      ]  
    ]
    create-links-with partners
    ask my-links [
      set old-or-new "old"
      show old-or-new
      set color old-link-color
      show color
    ]
  ]
end

to add-random-links
  repeat ( random-links-allowed-per-node ) [
    add-random-link
    tick
  ]
end

to add-random-link
  ask last-turtle [
      create-link-with one-of other turtles ;; equal dist flag, with [ count link-neighbors < n ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;
;;; Main Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to go
  ;; rewire existing nodes
  ask turtles with [ any? links ]
  [
    ;; linked turtles can rewire a link to elsewhere
    if random 100 / rewire-probability < 1 [
      let thislink one-of my-links
      if thislink != nobody [
        ask thislink [
          let node1 end1
          ;; find a node distinct from node1 and not already a neighbor of node1
          let node2 one-of turtles with [ (self != node1) and (not link-neighbor? node1) ]
          ;; wire the new edge
          ask node1 [ create-link-with node2 ]
          ;; remove the old edge
          die
        ]
      ]
    ]
  ]
  ;; add new nodes and links
  if count turtles < maximum-number-of-nodes
    [
      make-node
      add-random-links
    ]
  complete-turn
end

to complete-turn
  tick
  if resizenodes? [ do-resizenodes ]
  if layout? [ layout ]
  if plot? [ do-plotting ]
end


;;;;;;;;;;;;;;
;;; Layout ;;;
;;;;;;;;;;;;;;

;; resize-nodes, change back and forth from size based on degree to a size of 1
to do-resizenodes
    ;; a node is a circle with diameter determined by
    ;; the SIZE variable; using SQRT makes the circle's
    ;; area proportional to its degree
    ;; ask turtles [ set size sqrt count link-neighbors ]
    ask turtles [
      set size ( sqrt count link-neighbors )
      if size > 1 [
        set color blue
      ]
      if size > 2 [
        set color cyan
      ]
      if size > 3 [
        set color turquoise
      ]
      if size > 4 [
        set color green
      ]
      if size > 5 [
        set color yellow
      ]
      if size > 6 [
        set color orange
      ]
      if size > 7 [
        set color red
      ]
    ]
    
end

to layout
  ;; the number 3 here is arbitrary; more repetitions slows down the
  ;; model, but too few gives poor layouts
  repeat 3 [
    ;; the more turtles we have to fit into the same amount of space,
    ;; the smaller the inputs to layout-spring we'll need to use
    let factor sqrt count turtles
    ;; numbers here are arbitrarily chosen for pleasing appearance
    layout-spring turtles links spring-constant spring-length repulsion     ;; was (1 / factor) (7 / factor) (1 / factor)
    display  ;; for smooth animation
  ]
  ;; don't bump the edges of the world
  let x-offset max [xcor] of turtles + min [xcor] of turtles
  let y-offset max [ycor] of turtles + min [ycor] of turtles
  ;; big jumps look funny, so only adjust a little each time
  set x-offset limit-magnitude x-offset 0.1
  set y-offset limit-magnitude y-offset 0.1
  ask turtles [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
end

to-report limit-magnitude [number limit]
  if number > limit [ report limit ]
  if number < (- limit) [ report (- limit) ]
  report number
end

;;;;;;;;;;;;;;;;
;;; Plotting ;;;
;;;;;;;;;;;;;;;;

to do-plotting ;; plotting procedure
  do-sizes-plot
  do-degree-distribution-plot
end

to do-sizes-plot
  set-current-plot "Sizes"
  if count turtles with [ color = gray ] > 0 [
    set-current-plot-pen "grays"
    plotxy ticks ( count turtles with [ color = gray ] )
  ]
  if count turtles with [ color = blue ] > 0 [
    set-current-plot-pen "blues"
    plotxy ticks ( count turtles with [ color = blue ] )
  ]
  if count turtles with [ color = cyan ] > 0 [
    set-current-plot-pen "cyans"
    plotxy ticks ( count turtles with [ color = cyan ] )
  ]
  if count turtles with [ color = turquoise ] > 0 [
    set-current-plot-pen "turquoises"
    plotxy ticks ( count turtles with [ color = turquoise ] )
  ]
  if count turtles with [ color = green ] > 0 [
    set-current-plot-pen "greens"
    plotxy ticks ( count turtles with [ color = green ] )
  ]
  if count turtles with [ color = yellow ] > 0 [
    set-current-plot-pen "yellows"
    plotxy ticks ( count turtles with [ color = yellow ] )
  ]
  if count turtles with [ color = orange ] > 0 [
    set-current-plot-pen "oranges"
    plotxy ticks ( count turtles with [ color = orange ] )
  ]
  if count turtles with [ color = red ] > 0 [
    set-current-plot-pen "reds"
    plotxy ticks ( count turtles with [ color = red ] )
  ]
end

to do-degree-distribution-plot
  let max-degree max [count link-neighbors] of turtles
  set-current-plot "Degree Distribution"
  plot-pen-reset  ;; erase what we plotted before
  set-plot-x-range 1 (max-degree + 1)  ;; + 1 to make room for the width of the last bar
  histogram [count link-neighbors] of turtles
end



; Licensing information is in the Information tab.
@#$#@#$#@
GRAPHICS-WINDOW
360
10
946
617
45
45
6.33
1
10
1
1
1
0
0
0
1
-45
45
-45
45
1
1
1
ticks

PLOT
954
308
1188
623
Degree Distribution
degree
# of nodes
1.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 1 -7500403 true

BUTTON
6
25
108
58
Preferential
setup-preferential
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
100
288
177
321
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

BUTTON
13
288
98
321
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SWITCH
982
48
1128
81
plot?
plot?
0
1
-1000

SWITCH
982
124
1128
157
layout?
layout?
0
1
-1000

MONITOR
273
83
352
128
# of nodes
count turtles
3
1
11

SWITCH
982
12
1128
45
resizenodes?
resizenodes?
0
1
-1000

SWITCH
982
85
1129
118
plot-decay?
plot-decay?
0
1
-1000

SLIDER
6
111
248
144
maximum-number-of-nodes
maximum-number-of-nodes
100
1000
300
100
1
NIL
HORIZONTAL

SLIDER
1139
125
1311
158
spring-constant
spring-constant
0
1
0.5
.1
1
NIL
HORIZONTAL

SLIDER
1140
163
1312
196
spring-length
spring-length
0
50
19
1
1
NIL
HORIZONTAL

SLIDER
1140
202
1312
235
repulsion
repulsion
0
10
4
.5
1
NIL
HORIZONTAL

BUTTON
1018
175
1091
208
Layout
layout
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
116
25
198
58
Random
setup-random
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
6
149
248
182
preferential-link-cost
preferential-link-cost
10
100
100
10
1
%
HORIZONTAL

SLIDER
6
186
269
219
random-links-allowed-per-node
random-links-allowed-per-node
1
10
1
1
1
NIL
HORIZONTAL

BUTTON
205
24
268
57
Both
setup-both
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
12
332
353
718
Sizes
Steps
Sizes
0.0
10.0
0.0
10.0
true
true
PENS
"grays" 1.0 0 -7500403 true
"blues" 1.0 0 -13345367 true
"cyans" 1.0 0 -11221820 true
"turquoises" 1.0 0 -14835848 true
"greens" 1.0 0 -10899396 true
"yellows" 1.0 0 -1184463 true
"oranges" 1.0 0 -955883 true
"reds" 1.0 0 -2674135 true

SLIDER
6
69
248
102
initial-number-of-nodes
initial-number-of-nodes
100
1000
100
100
1
NIL
HORIZONTAL

SLIDER
6
225
183
258
rewire-probability
rewire-probability
0
100
10
10
1
%
HORIZONTAL

BUTTON
377
638
543
671
Add Preferential Node
add-preferential-node
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
789
639
890
672
Rewire Link
rewire-one
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
553
678
700
711
Add Random Link
add-random-link
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
377
678
542
711
Add Preferential Link
add-preferential-link
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
553
638
700
671
Add Random Node
add-random-node
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

@#$#@#$#@
WHAT IS IT?
-----------

This exploratory model is based off of:
- Wilensky, U. (2005).  NetLogo Preferential Attachment model.  http://ccl.northwestern.edu/netlogo/models/PreferentialAttachment

Wilensky's model produces the initial network.
Future Forward Institute added the functionality to decay the network.

In some networks, a few "hubs" have lots of connections, while everybody else only has a few.  This model shows one way such networks can arise.

This model generates these networks by a process of "preferential attachment", in which new network members prefer to make a connection to the more popular existing members.

This model then decays the network by a process of "random removal" of nodes along with their links.

HOW IT WORKS
------------
The model starts with two nodes connected by an edge.

At each step, a new node is added.  A new node picks an existing node to connect to randomly, but with some bias.  More specifically, a node's chance of being selected is directly proportional to the number of connections it already has, or its "degree." This is the mechanism which is called "preferential attachment."

The decay function removes nodes at random from the network, including all of the links associated with that node. This demonstrates how quickly large sections of the network can collapse.

HOW TO USE IT
-------------
Pressing the GO ONCE button adds one new node.  To continuously add nodes, press GO.
Pressing the DECAY ONCE button removes one node and its links.  To continuously decay
the network , press DECAY.


The LAYOUT? switch controls whether or not the layout procedure is run.  This procedure attempts to move the nodes around to make the structure of the network easier to see.

The PLOT? switch turns off the plots which speeds up the model.

The RESIZE-NODES button will make all of the nodes take on a size representative of their degree distribution.  If you press it again the nodes will return to equal size.

If you want the model to run faster, you can turn off the LAYOUT? and PLOT? switches and/or freeze the view (using the on/off button in the control strip over the view). The LAYOUT? switch has the greatest effect on the speed of the model.

If you have LAYOUT? switched off, and then want the network to have a more appealing layout, press the REDO-LAYOUT button which will run the layout-step procedure until you press the button again. You can press REDO-LAYOUT at any time even if you had LAYOUT? switched on and it will try to make the network easier to see.


THINGS TO NOTICE
----------------
The networks that result from running this model are often called "scale-free" or "power law" networks. These are networks in which the distribution of the number of connections of each node is not a normal distribution -- instead it follows what is a called a power law distribution.  Power law distributions are different from normal distributions in that they do not have a peak at the average, and they are more likely to contain extreme values (see Barabasi 2002 for a further description of the frequency and significance of scale-free networks).  Barabasi originally described this mechanism for creating networks, but there are other mechanisms of creating scale-free networks and so the networks created by the mechanism implemented in this model are referred to as Barabasi scale-free networks.

You can see the degree distribution of the network in this model by looking at the plots. The top plot is a histogram of the degree of each node.  The bottom plot shows the same data, but both axes are on a logarithmic scale.  When degree distribution follows a power law, it appears as a straight line on the log-log plot.  One simple way to think about power laws is that if there is one node with a degree distribution of 1000, then there will be ten nodes with a degree distribution of 100, and 100 nodes with a degree distribution of 10.

When you decay this network by random removal of nodes with their links, most of the nodes removed are likely to have few links.  Consequently, the network suffers little decay.  Removal of nodes with high-degree, i.e. 'hubs', will cause more decay to the network.  Eventually the network suffers enough decay that large numbers of nodes become isolated from each other.

This is a non-linear effect, not a trend, and is unpredictable.

The graph of the 'Giant Component' shows how quickly total collapse can occur.


NETWORK LAYOUT
----------------
There are many ways to graphically display networks.  This model uses a common "spring" method where the movement of a node at each time step is the net result of "spring" forces that pulls connected nodes together and repulsion forces that push all the nodes away from each other.  This code is in the layout-step procedure. You can force this code to execute any time by pressing the REDO LAYOUT button, and pressing it again when you are happy with the layout.


RELATED MODELS
--------------
See other models in the Networks section of the Models Library, such as Giant Component.

See also Network Example, in the Code Examples section.


CREDITS AND REFERENCES
----------------------
This model is based on:
Albert-Laszlo Barabasi. Linked: The New Science of Networks, Perseus Publishing, Cambridge, Massachusetts, pages 79-92.

For a more technical treatment, see:
Albert-Laszlo Barabasi & Reka Albert. Emergence of Scaling in Random Networks, Science, Vol 286, Issue 5439, 15 October 1999, pages 509-512.

Barabasi's webpage has additional information at: http://www.nd.edu/~alb/

The layout algorithm is based on the Fruchterman-Reingold layout algorithm.  More information about this algorithm can be obtained at: http://citeseer.ist.psu.edu/fruchterman91graph.html.

For a model similar to the one described in the first extension, please consult:
W. Brian Arthur, "Urban Systems and Historical Path-Dependence", Chapt. 4 in Urban systems and Infrastructure, J. Ausubel and R. Herman (eds.), National Academy of Sciences, Washington, D.C., 1988.


HOW TO CITE
-----------
If you mention this model in an academic publication, Future Forward Institute asks that you include these citations for the model itself and for the NetLogo software:
Future Forward Institute
https://github.com/paulbhartzog/Network-Growth-and-Decay

If you mention this model in an academic publication, Wilensky asks that you include these citations for the model itself and for the NetLogo software:
- Wilensky, U. (2005).  NetLogo Preferential Attachment model.  http://ccl.northwestern.edu/netlogo/models/PreferentialAttachment.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
In other publications, please use:
- Copyright 2005 Uri Wilensky. All rights reserved. See http://ccl.northwestern.edu/netlogo/models/PreferentialAttachment for terms of use.


COPYRIGHT NOTICE
----------------
Creative Commons BY-SA 2011 Future Forward Institute. Some rights reserved.
This work is licensed under a Creative Commons Attribution-Share Alike 3.0 Unported License.

Url Wilensky's original code Copyright 2005 Uri Wilensky. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:
a) these copyright notices are included.
b) Url Wilensky's original code may not be redistributed for profit without permission from Uri Wilensky. Contact Uri Wilensky for appropriate licenses for redistribution for profit.

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1.2
@#$#@#$#@
set layout? false
set plot? false
setup repeat 300 [ go ]
repeat 100 [ layout ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
