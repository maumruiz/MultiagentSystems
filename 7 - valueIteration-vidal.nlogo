extensions [table]                            ;; Importa la funcionalidad de tablas

;; State of the world is x,y, heading (0, 90, 180, 270)
;; Actions: "fd 1", "lt 90", "rt 90"
;; Los parches verdes son recompenza, los rojos son castigo

;; u = utility
;; headings = direcciones a donde se puede ir
;; actions = movimientos que pueden hacer las tortugas
globals [u headings actions]                  ;; Variables globales

;; === Funcion setup === ;;
;; Se encarga de inicializar los valores de los
;; parches y las tortugas, y poner valores a las listas
;; de headings, actions y crea la tabla de utilidad
to setup                                      ;; Declara la función setup
  ca                                          ;; Limpia la pantalla
  reset-ticks                                 ;; Resetea los ciclos de reloj

  ;; Inicializacion de valores
  set headings [0 90 180 270]                 ;; Pone direcciones a la lista de headings
  set actions ["fd 1" "lt 90" "rt 90"]        ;; Pone las acciones que puede realizar la tortuga a la lista actions
  set u table:make                            ;; Crea la tabla de utilidades

  ;; Inicialización de parches
  ask patches [                               ;; Llama a todos los parches
   let coin random 10                         ;; Crea una variable llamada coin y le pone un valor random de 0 a 10
   set pcolor white                           ;; Pinta el parche de blanco
   if (coin = 0) [                            ;; Si la variable coin salió con 0:
     set pcolor red                           ;; Pinta el parche de rojo
   ]
   if (coin = 1) [                            ;; Si la variable salió con 1:
     set pcolor green                         ;; Pinta el parche de verde
   ]
  ]

  ;; Inicializa las tortugas
  create-turtles num-turtles [                ;; Crea el numero de tortugas que se haya escogido en el slider
   set color blue                             ;; Pinta las tortugas de azul
   setxy random-pxcor random-pycor            ;; Las coloca en lugares al azar en el mapa
    set heading one-of headings               ;; Les pone direcciones permitidas por el programa (arriba, derecha, izquierda, abajo)
  ]
end                                           ;; Termina la función setup


;; === Funcion go === ;;
;; Avanza un ciclo de reloj
;; para mover a las tortugas
to go                                         ;; Declara la función go
  tick                                        ;; Avanza un ciclo de reloj
  ask turtles [                               ;; Llama a todas las tortugas
   take-best-action                           ;; Llama a la función take-best-action
  ]
end                                           ;; Termina la función go

;; === Funcion put-utility === ;;
;; Función que ayuda a ponerle una utilidad
;; a la tabla de utilidades según sea la
;; coordenada y dirección
to put-utility [x y dir utility]              ;; Declara la función put-utility que recibe coordenadas en x, y, la dirección y la utilidad
  let state (list x y dir)                    ;; Crea el estado de coordenadas con dirección
  table:put u state utility                   ;; Pone la utilidad al hash con llave el estado y valor la utilidad
end                                           ;; Termina la función put-utility

;; === Funcion get-utility === ;;
;; Función que regresa el valor del estado que
;; se esté buscando, regresa 0 si aún no se le ha
;; asignado utilidad
to-report get-utility [x y dir]               ;; Declara la función get-utility que recibe coordenadas x, y y la dirección
  let state (list x y dir)                    ;; Crea la variable state que es una lista con el estado
  if (table:has-key? u state) [               ;; Si la tabla de utilidades tiene una llave igual al estado buscado:
   report table:get u (list x y dir)          ;; regresa el valor de la utilidad de ese estado
  ]
  put-utility x y dir 0                       ;; Llama a la función put-utility para poner utilidad de 0 a ese estado
  report 0                                    ;; regresa 0
end                                           ;; Termina la función get-utility

;; === Funcion value-iteration === ;;
;; Función principal del programa. Realiza el algoritmo
;; de value iteration para encontrar las utilidades de cada
;; estado y las políticas óptimas
to value-iteration                            ;; Declara la función value-iteration
  let delta 1000                              ;; Crea la variable delta con un valor de 1000 (para entrar al ciclo correctamente)
  let my-turtle 0                             ;; Crea una variable my-turtle que será fantasma para recorrer los estados

  create-turtles 1 [                          ;; Crea una tortuga (fantasma) con:
    set my-turtle self                        ;; Asigna esta tortuga a la variable my-turtle
    set hidden? true                          ;; Asigna un estado escondido a la tortuga
  ]

  while [delta > epsilon * (1 - gamma) / gamma] [ ;; Mientras delta sea mayor a epsion por la diferencia de gamma
    set delta 0                               ;; Asigna 0 a la variable delta
    ask patches [                             ;; Llama a todos los parches:
      foreach headings [                      ;; Por cada dirección que se puede tomar:
        [?1] ->                               ;; Asigna a la variable ?1 el valor del ciclo actual de direcciones
        let x pxcor                           ;; Crea x con el valor de la coordenada x de este parche
        let y pycor                           ;; Crea y con el valor de la coordenada y de este parche
        let dir ?1                            ;; Crea la variable dir con la dirección actual del ciclo
        let best-action 0                     ;; Crea la variable best-action con valor de 0
        ask my-turtle [                       ;; Llama a todas las tortugas para:
          setxy x y                           ;; Pone a la tortuga en la coordenada del parche
          set heading dir                     ;; Le asigna una dirección de la dirección actual del ciclo (se repite para todas las direcciones)
          let best-utility item 1 get-best-action ;;Obtiene la mejor utilidad de acuerdo a las acciones que puede realizar la tortuga
          let current-utility get-utility x y dir ;; Obtiene la utilidad actual del estado donde se encuentra la tortuga
          let new-utility (get-reward + gamma * best-utility) ;; Obtiene la nueva utilidad mediante la operación R + gamma * mejor utilidad
          put-utility x y dir new-utility     ;; Pone la nueva utilidad al estado actual
          if (abs (current-utility - new-utility) > delta) [ ;; Si la diferencia entre la utilidad actual y la nueva utilidad es mayor a delta:
            set delta abs(current-utility - new-utility) ;; Asigna la diferencia a delta
          ]
        ]
      ]
    ]
    plot delta                                ;; Grafica delta después de todo el ciclo de operación de los parches
  ]
  ask my-turtle [die]                         ;; Mata a la tortuga fantasma
end                                           ;; Termina la función value-iteration

;report's the turtle's best action and utility given its current x,y,heading and current u
;report [best-action its-utility]
;; === Funcion get-best-action === ;;
;; Regresa la mejor acción de la tortuga y su utilidad,
;; dada su x,y,dirección y utilidad actual.
to-report get-best-action                     ;; Declara la función get-best-action
  let x xcor                                  ;; Agrega una variable x con la coordenada x de la tortuga
  let y ycor                                  ;; Agrega una variable y con la coordenada y de la tortuga
  let dir heading                             ;; Agrega una variable dir con la dirección tortuga
  let best-action 0                           ;; Agrega la variable best-action con valor de 0 por el momento
  let best-utility -100000                    ;; Incializa la mejor utilidad con -10000
  foreach actions [                           ;; Por cada accion que puede realizar la tortuga:
    [?1] ->                                   ;; Asigna a ?1 el valor de cada iteración
    run ?1 ;take action, run "fd 1"           ;; Realiza la primera acción
    let utility-of-action get-utility xcor ycor heading ;; Crea la variable utility-of-action con el valor que regrese la función get-utility del estado actual
    if(utility-of-action > best-utility) [    ;; Si la utilidad de la acción es mayor a la mejor utilidad hasta el momento:
      set best-action ?1                      ;; Le asigna la acción actual a la mejor acción
      set best-utility utility-of-action      ;; Le asigna la utilidad de la acción a la mejor utilidad
    ]
    setxy x y                                 ;; Regresa a la tortuga a su posición original
    set heading dir                           ;; Regresa a la tortuga a su dirección original
  ]
  report  (list best-action best-utility)     ;; Regresa una lista con [mejor acción , mejor utilidad]
end                                           ;; Termina la función get-best-action

;;;;;;;;; Turtle functions ;;;;;;;;;;;;;;;;;;;

;; === Funcion get-reward === ;;
;; Función que regresa el valor de la recompenza
;; dada a la tortuga de acuerdo al parche donde se encuentre
to-report get-reward                          ;; Declara la función get-reward
  if (pcolor = green) [report winRewardValue] ;; Si el parche es verde: regresa el valor de recompenza
  if (pcolor = red) [report loseRewardValue]  ;; Si el parche es rojo: regresa el valor del castigo
  report 0                                    ;; Si es otro color, regresa 0
end                                           ;; Termina la función get-reward

;; === Funcion take-best-action === ;;
;; Función que realiza la mejor acción de la tortuga
;; de acuerdo a su estado actual
to take-best-action                           ;; Declara la función take-best-action
  let best-action first get-best-action       ;; Agrega la variable best-action con el valor que regrese la función get-best-action
  run best-action                             ;; Realiza la mejor acción
end                                           ;; Termina la función take-best-action
@#$#@#$#@
GRAPHICS-WINDOW
266
10
703
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
95
15
159
48
Setup
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
775
30
871
90
winRewardValue
10.0
1
0
Number

INPUTBOX
776
102
869
162
loseRewardValue
-10.0
1
0
Number

SLIDER
743
239
915
272
gamma
gamma
0
1
0.9
0.01
1
NIL
HORIZONTAL

SLIDER
744
289
916
322
epsilon
epsilon
0
1
0.1
0.01
1
NIL
HORIZONTAL

PLOT
35
208
235
358
delta
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

BUTTON
73
64
185
97
NIL
value-iteration
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
743
188
915
221
num-turtles
num-turtles
0
100
42.0
1
1
NIL
HORIZONTAL

BUTTON
96
113
159
146
NIL
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

@#$#@#$#@
## WHAT IS IT?

El modelo representa el algoritmo de value iteration en un mundo donde hay estados finales al azar donde dan recompenzas positivas o negativas y hay tortugas que se mueven como mejor les conviene

## HOW IT WORKS

Se realizó el algoritmo de value iteration para que se obtengan las utilidades máximas de cada estado y las mejores acciones a tomar de cada estado. Después de correr el algoritmo, las tortugas pueden decidir a dónde les conviene ir para llegar al estado final positivo más cercano.

## HOW TO USE IT

Para usar el modelo, se tiene que dar click al botón setup para limpiar la pantalla y colocar los parches y tortugas. Después, se tiene que dar click al botón value iteration para calcular las utilidades máximas y políticas de todos los estados. Una vez realizado esto, se tiene que dar al botón go para que las tortugas se muevan como mejor les convenga.

## THINGS TO NOTICE

Se pueden cambiar los valores de las recompenzas positivas y negativas, así como también la cantidad de tortugas que aparecen en el mundo, el valor de gamma y el valor de epsilon. La gráfica muestra como va cambiando delta mediante los ciclos de value iteration.

## THINGS TO TRY

Se pueden modificar los valores de gamma y epsilon para ver como se comporta el algoritmo de value iteration.

## EXTENDING THE MODEL

Se puede probar con poner solamente un estado final positivo para ver como las tortugas encuentran el mejor camino hacia solo un lugar

## CREDITS AND REFERENCES

José vidal "https://www.youtube.com/watch?v=dBDVkPjyYF4"
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
