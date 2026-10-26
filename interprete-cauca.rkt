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
  Primitivas nuevas
    (interpretar "abs(-7)")                    => 7
    (interpretar "abs(5)")                     => 5
    (interpretar "abs(-2.5)")                  => 2.5
    (interpretar "abs(true)")                  => error (se esperaban números)

    (interpretar "mcd(12, 18)")                => 6
    (interpretar "mcd(7, 13)")                 => 1
    (interpretar "mcd(12, 18, 24)")            => 6
    (interpretar "mcd(1.5, 2)")                => error (se esperaban enteros)

    (interpretar "mcm(4, 6)")                  => 12
    (interpretar "mcm(2, 3, 4)")               => 12
    (interpretar "mcm(0, 5)")                  => 0
    (interpretar "mcm(6)")                     => error (se esperaban al menos 2 argumentos)

    (interpretar "promedio(1, 2, 3, 4)")       => 5/2
    (interpretar "promedio(10)")               => 10
    (interpretar "promedio(n, m)")             => 13/2
    (interpretar "promedio(true)")             => error (se esperaban números)

    (interpretar "xor(true, false)")           => #t
    (interpretar "xor(true, true)")            => #f
    (interpretar "xor(false, false)")          => #f
    (interpretar "xor(1, true)")               => error (se esperaban booleanos)

    (interpretar "implica(true, false)")       => #f
    (interpretar "implica(false, true)")       => #t
    (interpretar "implica(true, true)")        => #t
    (interpretar "implica(1, true)")           => error (se esperaban booleanos)

    (interpretar "entre(5, 1, 10)")            => #t
    (interpretar "entre(11, 1, 10)")           => #f
    (interpretar "entre(1, 1, 1)")             => #t
    (interpretar "entre(1, 2)")                => error (se esperaban 3 argumentos)

  Recursión y case
    letrec simple:
      (interpretar "letrec factorial (k) = if ==(k, 0) then 1
                      else *(k, apply factorial (sub1(k))) end
                    in apply factorial (5) end")                    => 120
    letrec con dos parámetros (el ejemplo de potencia):
      (interpretar "letrec potencia (base, exp) = if ==(exp, 0) then 1
                      else *(base, apply potencia (base, sub1(exp))) end
                    in apply potencia (2, 10) end")                 => 1024
    letrec mutuamente recursivo:
      (interpretar "letrec par? (k) = if ==(k, 0) then true
                      else apply impar? (sub1(k)) end
                    impar? (k) = if ==(k, 0) then false
                      else apply par? (sub1(k)) end
                    in apply par? (10) end")                        => #t
    letrec con un procedimiento como argumento:
      (interpretar "letrec aplicarn (f, k, x) = if ==(k, 0) then x
                      else apply aplicarn (f, sub1(k), apply f (x)) end
                    in apply aplicarn (proc (v) *(v, 2) end, 3, 1) end")  => 8

    case, rama que coincide:
      (interpretar "case 3 of 1 => 100 of 3 => 300 of 7 => 700 otherwise => 0 end")  => 300
    case, rama otherwise:
      (interpretar "case 5 of 1 => 100 of 3 => 300 otherwise => 0 end")              => 0
    case, control evaluado una sola vez:
      (interpretar "case +(1, 2) of 2 => 20 of 3 => 30 otherwise => 0 end")          => 30
    case, error por control no numérico:
      (interpretar "case true of 1 => 1 otherwise => 0 end")  => error (el control debe ser un número)
|#
