#lang eopl
;Autores: Nombre1 Codigo1, Samuel Garcia Parra 2459476

;; Taller 2 — El intérprete de Cauca.
;; Fachada: reúne los seis módulos de src/ y reexporta todo lo que
;; definen, de modo que quien la requiera vea todos los nombres sin
;; requerir los módulos uno por uno.
;;
;;   src/sintaxis.rkt    especificación léxica y gramatical, scanner, parser
;;   src/valores.rkt     el valor procedimiento
;;   src/ambiente.rkt    el TAD ambiente y el ambiente inicial
;;   src/primitivas.rkt  las primitivas y sus verificaciones
;;   src/interprete.rkt  la evaluación y la aplicación de procedimientos
;;   src/interfaz.rkt    el punto de entrada y el REPL
;;
;; Los require van en un solo sentido. Racket no carga dos módulos que se
;; requieran entre sí.

(require "src/sintaxis.rkt")
(require "src/valores.rkt")
(require "src/ambiente.rkt")
(require "src/primitivas.rkt")
(require "src/interprete.rkt")
(require "src/interfaz.rkt")

(provide (all-from-out "src/sintaxis.rkt"
                       "src/valores.rkt"
                       "src/ambiente.rkt"
                       "src/primitivas.rkt"
                       "src/interprete.rkt"
                       "src/interfaz.rkt"))

;;; ==========================================================
;;; Ejemplos
;;; ==========================================================

#|
  Aquí van los ejemplos que pide el enunciado: 5 del scanner, 5 del
  parser y los de ejecución de cada parte, con el resultado de cada uno
  escrito al lado. Las pruebas con rackunit viven en pruebas-cauca.rkt.

  Scanner
    (scanner "add1(n)")   => ((literal-string12 "add1" 1)
                             (literal-string12 "(" 1)
                             (identificador n 1)
                             (literal-string12 ")" 1))
    
    (scanner "-7")        => ((numero -7 1))

    (scanner "3.5")       => ((numero 3.5 1))

    (scanner "let x = 1 in x end") => ((literal-string12 "let" 1)
                                      (identificador x 1)
                                      (literal-string12 "=" 1)
                                      (numero 1 1)
                                      (literal-string12 "in" 1)
                                      (identificador x 1)
                                      (literal-string12 "end" 1))
    
    (scanner "// comentario\n42") =>  ((numero 42 2)
  
  Parser
    (parser "42")    => #(struct:a-program #(struct:lit-exp 42))
  
    (parser "true")    => #(struct:a-program #(struct:true-exp))

    (parser "+(1, 2)")    => #(struct:a-program
                               #(struct:prim-exp #(struct:sum-prim) (#(struct:lit-exp 1) #(struct:lit-exp 2))))

    (parser "if true then 1 else 2 end")    => #(struct:a-program
                                                 #(struct:if-exp #(struct:true-exp) #(struct:lit-exp 1) #(struct:lit-exp 2)))

    (parser "let x = 1 in x end")    => #(struct:a-program #(struct:let-exp (x) (#(struct:lit-exp 1)) #(struct:var-exp x)))
  
  Ejecución del lenguaje base
    (interpretar "+(1, 2, 3)") => 6
    (interpretar "-(10, 3, 2)") => 5
    (interpretar "/(100, 5, 2)") => 10
    (interpretar "not(true)") => #f
    (interpretar "and(true, false)") => #f
    (interpretar "let x = 1 in let x = 2 in x end end") => 2
    (interpretar "let base = 8 altura = 5 in if and(>(base, 0), >(altura, 0)) then *(base, altura) else 0 end end") => 40
    (interpretar "if n then 1 else 2 end") => La condición debe ser booleana, se obtuvo 10
    (interpretar "z") => apply-env: Variable no ligada: z
    (interpretar "+(1, true)") => Se esperaban números, se recibió (1 #t)

  Primitivas nuevas
    (interpretar "...")   =>

  Procedimientos
    (interpretar "...")   =>

  Recursión y case
    (interpretar "...")   =>
|#
