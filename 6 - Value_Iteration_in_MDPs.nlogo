globals[patches-plabel-list]                          ;; Variable global para lista de parches

;; === Funcion setup === ;;
;; Se encarga de inicializar los valores de los
;; parches y las tortugas
to setup                                              ;; Declaración de la función setup
  ca                                                  ;; Limpia la pantalla y las variables
  reset-ticks                                         ;; Resetea los ticks del reloj

  set patches-plabel-list []                          ;; Limpia la lista de parches

  ask patches[set plabel 0]                           ;; Le dice a los parches que pongan su etiqueta en 0 (de utilidad)

  reset-patch-color                                   ;; Llama a la función reset patch color
end                                                   ;; Termina la función setup

;; === Funcion setup === ;;
;; Ejectuta el programa que realiza un tick
to go                                                 ;; Declara la función go
  tick                                                ;; Le aumenta un tick

  set patches-plabel-list []                          ;; Limpia la lista de parches
  foreach[0 1 2 3][ [?1] ->                           ;; Inicia ciclo que va desde 0 a 3 (coordenadas en x)
    let s-pxcor ?1                                    ;; Le pone a la variable s-pxcor el valor del ciclo donde se encuentra
    foreach[0 1 2][ [??1] ->                          ;; Inicia ciclo que va desde 0 a 2 (coordenadas en y)
      let s-pycor ??1                                 ;; Le asigna a s-pycor el valor del ciclo donde se encuentra
                                                      ;; Agrega en el último lugar de la lista de parches, el valor de la etiqueta de la coordenada en curso
      set patches-plabel-list lput ([plabel] of patch s-pxcor s-pycor) patches-plabel-list
    ]
  ]

  ask patch 2 1[                                      ;; Llama al parche de coordenadas 2,1
    value-iteration                                   ;; Llama a la función value-iteration
  ]

  plot-utilidad
  reset-patch-color                                   ;; Llama a la función reset-patch-color

  let checklist []                                    ;; Declara checklist como una lista vacia
  foreach[0 1 2 3][ [?1] ->                           ;; Por cada coordenada en x de 0 a 3:
    let s-pxcor ?1                                    ;; Asigna a s-pxcor el valor del valor actual del foreach
    foreach[0 1 2][ [??1] ->                          ;; Por cada coordenada en y de 0 a 2:
      let s-pycor ??1                                 ;; Asigna a s-pycor el valor del valor actual del foreach

                                                      ;; Agrega en el último lugar del checklist, el valor de la etiqueta de la coordenada en curso
      set checklist lput ([plabel] of patch s-pxcor s-pycor) checklist
    ]
  ]

  let difference-found false                          ;; Declara la variable booleana difference-found como falso

  let i 0                                             ;; Crea la variable i con 0
  while[(difference-found = false) and (i < length checklist)][ ;; Mientras difference-found sea falso y no se haya recorrido todo el checklist
    if((item i patches-plabel-list) != (item i checklist))[  ;; Si el valor de la lista de parches es igual al del checklist:
      set difference-found true                       ;; Se asigna true a difference-found
    ]

    set i (i + 1)                                     ;; Se le suma uno a i
  ]

  if(difference-found = false)[                       ;; Si no se encontró diferencia:
    ask patches with [pcolor = black] [sprout 1]
    ask patches with [pcolor = black ] [ politica-optima ]
    output-print "Equilibrium reached"                ;; Se imprime "Equilibrium reached"
    stop                                              ;; Se para la ejecución
  ]

end                                                   ;; Termina la función go

to politica-optima
  let own-pxcor pxcor                             ;; Asigna a own-pxcor el valor recibido de la coordenada en x del parche
  let own-pycor pycor                             ;; Asigna a own-pycor el valor recibido de la coordenada en y del parche
  let own-plabel [plabel] of patch own-pxcor own-pycor  ;; Asigna a own-plabel el valor de la etiqueta del mismo parche

  let north-plabel 0                                    ;; Asigna a north-plabel el valor de 0
  let south-plabel 0                                    ;; Asigna a south-plabel el valor de 0
  let east-plabel 0                                     ;; Asigna a east-plabel el valor de 0
  let west-plabel 0                                     ;; Asigna a west-plabel el valor de 0

                                                        ;; Si arriba del parche hay una pared o el parche azul:
  ifelse(patch own-pxcor (own-pycor + 1) = nobody) or ([pcolor] of patch own-pxcor (own-pycor + 1) = blue)[
    set north-plabel own-plabel                         ;; Se asigna a north-plabel la etiqueta del parche actual
  ]
  [                                                     ;; Si no:
    set north-plabel ([plabel] of patch own-pxcor (own-pycor + 1)) ;; Se asigna a north-plabel el valor de la etiqueta del parche de arriba
  ]
                                                        ;; Si a la derecha del parche hay una pared o el parche azul:
  ifelse(patch (own-pxcor + 1) own-pycor = nobody) or ([pcolor] of patch (own-pxcor + 1) own-pycor = blue)[
    set east-plabel own-plabel                          ;; Se le asigna a east-plabel el valor de la etiqueta del parche actual
  ]
  [                                                     ;; Si no:
    set east-plabel ([plabel] of patch (own-pxcor + 1) own-pycor) ;; Se le asigna a east-plabel el valor de la etiqueta del parche de la derecha
  ]
                                                        ;; Si abajo del parche hay una pared o el parche azul:
  ifelse(patch own-pxcor (own-pycor - 1) = nobody) or ([pcolor] of patch own-pxcor (own-pycor - 1) = blue)[
    set south-plabel own-plabel                         ;; Se le asigna a south-plabel el valor de la etiqueta del parche actual
  ]
  [                                                     ;; Si no:
    set south-plabel ([plabel] of patch own-pxcor (own-pycor - 1)) ;; Se le asigna a south-plabel el valor de la etiqueta del parche de abajo
  ]
                                                        ;; Si a la izquierda del parche hay una pared o el parche azul:
  ifelse(patch (own-pxcor - 1) own-pycor = nobody) or ([pcolor] of patch (own-pxcor - 1) own-pycor = blue)[
    set west-plabel own-plabel                          ;; Se le asigna a west-plabel el valor de la etiqueta del parche acual
  ]
  [                                                     ;; Si no:
    set west-plabel ([plabel] of patch (own-pxcor - 1) own-pycor) ;; Se asigna a west-plabel el valor de la etiqueta del parche a la izquierda
  ]

  let north-move precision ( gamma * ((0.8 * north-plabel) + (0.1 * east-plabel) + (0.1 * west-plabel))) 3
  let east-move precision ( gamma * ((0.8 * east-plabel) + (0.1 * north-plabel) + (0.1 * south-plabel))) 3
  let south-move precision ( gamma * ((0.8 * south-plabel) + (0.1 * east-plabel) + (0.1 * west-plabel))) 3
  let west-move precision ( gamma * ((0.8 * west-plabel) + (0.1 * north-plabel) + (0.1 * south-plabel))) 3

  let max-move north-move                            ;; Se asigna a max-label el valor de north-plabel obtenido antes
  let max-move-direction "north"

  if(east-move > max-move)[                          ;; Si el valor de la etiqueta de la derecha es mayor al de max-label:
    set max-move east-move                           ;; Se asigna a max-label el valor de east-plabel
    set max-move-direction "east"                     ;; Se asigna a max-plabel-direction el string de "east"
  ]

  if(south-move > max-move)[                         ;; Si el valor de la etiqueta de abajo es mayor al de max-label:
    set max-move south-move                          ;; Se asigna a max-label el valor de south-plabel
    set max-move-direction "south"                    ;; Se asigna a max-plabel-direction el string de "south"
  ]

  if(west-move > max-move)[                          ;; Si el valor de la etiqueta de la izquierda es mayor al de max-label:
    set max-move west-plabel                           ;; Se asigna a max-label el valor de west-plabel
    set max-move-direction "west"                     ;; Se asigna a max-plabel-direction el string de "west"
  ]

  if(max-move-direction = "north")[                   ;; Si la direccion es norte:
    ask turtles-here [set heading 0]
  ]
  if(max-move-direction = "east")[                    ;; Si la direccion es este:
    ask turtles-here [set heading 90]
  ]
  if(max-move-direction = "south")[                   ;; Si la direccion es sur:
    ask turtles-here [set heading 180]
  ]
  if(max-move-direction = "west")[                    ;; Si la direccion es oeste:
    ask turtles-here [set heading 270]
  ]

end

;; === Funcion value-iteration === ;;
;; Ejectuta el algoritmo que calcula la política óptima
;; del parche que haya llamado esta función
to value-iteration                                      ;; Declara la función value-iteration
  set pcolor yellow                                     ;; Pinta el parche de color amarillo

  set plabel compute-plabel pxcor pycor                 ;; Llama a la función compute-plabel para poner la etiqueta de esta coordenada

  ask neighbors4[                                       ;; Llama a los 4 parches que están a los lados del parche actual
    if (pcolor = black)[                                ;; Si el color del parche es negro:
      value-iteration                                   ;; Se llama recursivamente la función value-iteration
    ]
  ]
end                                                     ;; Termina la función value-iteration

;; === Funcion compute-plabel. Recibe las coordenadas del parche === ;;
;; Calcula el valor de utilidad del parche
to-report compute-plabel [input-pxcor input-pycor]      ;; Declara la función compute-plabel
  let own-pxcor input-pxcor                             ;; Asigna a own-pxcor el valor recibido de la coordenada en x del parche
  let own-pycor input-pycor                             ;; Asigna a own-pycor el valor recibido de la coordenada en y del parche
  let own-plabel [plabel] of patch own-pxcor own-pycor  ;; Asigna a own-plabel el valor de la etiqueta del mismo parche

  let north-plabel 0                                    ;; Asigna a north-plabel el valor de 0
  let south-plabel 0                                    ;; Asigna a south-plabel el valor de 0
  let east-plabel 0                                     ;; Asigna a east-plabel el valor de 0
  let west-plabel 0                                     ;; Asigna a west-plabel el valor de 0

                                                        ;; Si arriba del parche hay una pared o el parche azul:
  ifelse(patch own-pxcor (own-pycor + 1) = nobody) or ([pcolor] of patch own-pxcor (own-pycor + 1) = blue)[
    set north-plabel own-plabel                         ;; Se asigna a north-plabel la etiqueta del parche actual
  ]
  [                                                     ;; Si no:
    set north-plabel ([plabel] of patch own-pxcor (own-pycor + 1)) ;; Se asigna a north-plabel el valor de la etiqueta del parche de arriba
  ]
                                                        ;; Si a la derecha del parche hay una pared o el parche azul:
  ifelse(patch (own-pxcor + 1) own-pycor = nobody) or ([pcolor] of patch (own-pxcor + 1) own-pycor = blue)[
    set east-plabel own-plabel                          ;; Se le asigna a east-plabel el valor de la etiqueta del parche actual
  ]
  [                                                     ;; Si no:
    set east-plabel ([plabel] of patch (own-pxcor + 1) own-pycor) ;; Se le asigna a east-plabel el valor de la etiqueta del parche de la derecha
  ]
                                                        ;; Si abajo del parche hay una pared o el parche azul:
  ifelse(patch own-pxcor (own-pycor - 1) = nobody) or ([pcolor] of patch own-pxcor (own-pycor - 1) = blue)[
    set south-plabel own-plabel                         ;; Se le asigna a south-plabel el valor de la etiqueta del parche actual
  ]
  [                                                     ;; Si no:
    set south-plabel ([plabel] of patch own-pxcor (own-pycor - 1)) ;; Se le asigna a south-plabel el valor de la etiqueta del parche de abajo
  ]
                                                        ;; Si a la izquierda del parche hay una pared o el parche azul:
  ifelse(patch (own-pxcor - 1) own-pycor = nobody) or ([pcolor] of patch (own-pxcor - 1) own-pycor = blue)[
    set west-plabel own-plabel                          ;; Se le asigna a west-plabel el valor de la etiqueta del parche acual
  ]
  [                                                     ;; Si no:
    set west-plabel ([plabel] of patch (own-pxcor - 1) own-pycor) ;; Se asigna a west-plabel el valor de la etiqueta del parche a la izquierda
  ]

  let max-label north-plabel                            ;; Se asigna a max-label el valor de north-plabel obtenido antes
  let max-plabel-direction "north"                      ;; Se asigna a max-plabel-direction el string "north"

  if(east-plabel > max-label)[                          ;; Si el valor de la etiqueta de la derecha es mayor al de max-label:
    set max-label east-plabel                           ;; Se asigna a max-label el valor de east-plabel
    set max-plabel-direction "east"                     ;; Se asigna a max-plabel-direction el string de "east"
  ]

  if(south-plabel > max-label)[                         ;; Si el valor de la etiqueta de abajo es mayor al de max-label:
    set max-label south-plabel                          ;; Se asigna a max-label el valor de south-plabel
    set max-plabel-direction "south"                    ;; Se asigna a max-plabel-direction el string de "south"
  ]

  if(west-plabel > max-label)[                          ;; Si el valor de la etiqueta de la izquierda es mayor al de max-label:
    set max-label west-plabel                           ;; Se asigna a max-label el valor de west-plabel
    set max-plabel-direction "west"                     ;; Se asigna a max-plabel-direction el string de "west"
  ]

  if(max-plabel-direction = "north")[                   ;; Si la direccion es norte:
                                                        ;; Regresa el valor de la política avanzando hacia arriba
    report precision ( gamma * ((0.8 * north-plabel) + (0.1 * east-plabel) + (0.1 * west-plabel)) + R) 3
  ]
  if(max-plabel-direction = "east")[                    ;; Si la direccion es este:
                                                        ;; Regresa el valor de la política avanzando hacia la derecha
    report precision ( gamma * ((0.8 * east-plabel) + (0.1 * north-plabel) + (0.1 * south-plabel)) + R) 3
  ]
  if(max-plabel-direction = "south")[                   ;; Si la direccion es sur:
                                                        ;; Regresa el valor de la política avanzando hacia abajo
    report precision ( gamma * ((0.8 * south-plabel) + (0.1 * east-plabel) + (0.1 * west-plabel)) + R) 3
  ]
  if(max-plabel-direction = "west")[                    ;; Si la direccion es oeste:
                                                        ;; Regresa el valor de la política avanzando hacia la izquierda
    report precision ( gamma * ((0.8 * west-plabel) + (0.1 * north-plabel) + (0.1 * south-plabel)) + R) 3
  ]
end

;; === Funcion reset-patch-color === ;;
;; Pone colores a los parches según las coordenadas fijas del mapa
to reset-patch-color                                  ;; Declara la función reset patch color
  ask patches[set pcolor black]                       ;; Pinta todos los parches de negro

  ask patch 1 1[set pcolor blue]                      ;; Pinta de color azul al parche de la coordenada 1,1

  ask patch 3 2[                                      ;; Llama al parche de las coordenadas 3,2
    set pcolor green                                  ;; Lo pinta de color verde
    set plabel winning-state-value                    ;; Le pone de etiqueta el valor global de winning-state-value
  ]
  ask patch 3 1[                                      ;; Llama al parche de las coordenadas 3,1
    set pcolor red                                    ;; Lo pinta de color rojo
    set plabel losing-state-value                     ;; Le pone el valor global de losing-state-value a su etiqueta
  ]
end                                                   ;; Termina la función reset patch color

to plot-utilidad                                      ;; Declara la funcion plotUtility para graficar los cambios en las utilidades
  set-current-plot "Utilidad"                         ;; indicamos que es la grafica Utilidad
  set-current-plot-pen "Celda 0,0" plot [plabel] of patch 0 0    ;; La pluma llamada "Celda 0,0" graficara el label del patch 0 0
  set-current-plot-pen "Celda 0,1" plot [plabel] of patch 0 1    ;; La pluma llamada "Celda 0,1" graficara el label del patch 0 1
  set-current-plot-pen "Celda 0,2" plot [plabel] of patch 0 2    ;; La pluma llamada "Celda 0,2" graficara el label del patch 0 2
  set-current-plot-pen "Celda 1,0" plot [plabel] of patch 1 0    ;; La pluma llamada "Celda 1,0" graficara el label del patch 1 0
  set-current-plot-pen "Celda 1,2" plot [plabel] of patch 1 2    ;; La pluma llamada "Celda 1,2" graficara el label del patch 1 2
  set-current-plot-pen "Celda 2,0" plot [plabel] of patch 2 0    ;; La pluma llamada "Celda 2,0" graficara el label del patch 2 0
  set-current-plot-pen "Celda 2,1" plot [plabel] of patch 2 1    ;; La pluma llamada "Celda 2,1" graficara el label del patch 2 1
  set-current-plot-pen "Celda 2,2" plot [plabel] of patch 2 2    ;; La pluma llamada "Celda 2,2" graficara el label del patch 2 2
  set-current-plot-pen "Celda 3,0" plot [plabel] of patch 3 0    ;; La pluma llamada "Celda 3,0" graficara el label del patch 3 0
end                                                   ;; Termina la función plotUtilidad
@#$#@#$#@
GRAPHICS-WINDOW
250
24
658
333
-1
-1
100.0
1
10
1
1
1
0
0
0
1
0
3
0
2
0
0
1
ticks
30.0

BUTTON
30
51
239
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

INPUTBOX
678
127
833
187
R
-0.04
1
0
Number

INPUTBOX
677
51
832
111
winning-state-value
1.0
1
0
Number

INPUTBOX
844
51
999
111
losing-state-value
-1.0
1
0
Number

BUTTON
153
92
239
125
go (one step)
go
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
30
92
149
125
go (until equilibrium)
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
844
128
1000
173
iteration-selection
iteration-selection
"value-iteration" "policy-iteration"
0

OUTPUT
682
222
946
261
18

SLIDER
49
136
221
169
gamma
gamma
0
1
1.0
0.1
1
NIL
HORIZONTAL

PLOT
36
178
236
328
Utilidad
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"Celda 0,0" 1.0 0 -7500403 true "" ""
"Celda 0,1" 1.0 0 -2674135 true "" ""
"Celda 0,2" 1.0 0 -955883 true "" ""
"Celda 1,0" 1.0 0 -6459832 true "" ""
"Celda 1,2" 1.0 0 -10899396 true "" ""
"Celda 2,0" 1.0 0 -13840069 true "" ""
"Celda 2,1" 1.0 0 -14835848 true "" ""
"Celda 2,2" 1.0 0 -11221820 true "" ""
"Celda 3,0" 1.0 0 -1184463 true "" ""

@#$#@#$#@
## WHAT IS IT?

Este modelo de netlogo simula el value iteration en los MDPs.

## HOW IT WORKS

El modelo funciona con métodos para sacar utilidades de cada parche donde se puede mover un agente. Se hacen iteraciones para sacar el valor máximo de utilidad.

## HOW TO USE IT

En el modelo se debe hacer primero click en el botón de setup para inicializar los parches y valores. Se puede cambiar el valor de gamma, de los estados finales y del refuerzo.

## THINGS TO NOTICE

La gráfica muestra la evolución de las utilidades de cada parche hasta que llega al valor máximo de utilidad.

## THINGS TO TRY

Se puede mover a los valores de gamma y Refuerzo para ver como cambian las acciones recomendadas para maximizar la utilidad.


## CREDITS AND REFERENCES

This model is done by Larry LIN Jun Jie.
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
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
