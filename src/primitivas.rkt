#lang eopl
;Autores: Juan S. Navarrete 2459562, Nombre2 Codigo2

;; Taller 2 — El intérprete de Cauca.
;; Las primitivas del lenguaje y las verificaciones de tipo y de
;; cantidad de argumentos que cada una exige. Requiere sintaxis.rkt.
;;
;; Aridades: +, -, *, / son n-arias; add1, sub1, not y abs son unarias;
;; las relacionales, and, or, xor e implica son binarias; entre es
;; ternaria; mcd y mcm son n-arias sobre enteros con al menos dos
;; argumentos; promedio es n-aria sobre números con al menos uno.

(require "sintaxis.rkt")

;; exigir-numeros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son números; si no, levanta
;; eopl:error a nombre de quien hizo la verificación.
(define exigir-numeros
  (lambda (args quien)
    (if ((list-of number?) args)
        #t
        (eopl:error quien "Se esperaban números, se recibió ~s" args))))

;; exigir-enteros : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son enteros; si no, levanta error.
(define exigir-enteros
  (lambda (args quien)
    (if ((list-of integer?) args)
        #t
        (eopl:error quien "Se esperaban enteros, se recibió ~s" args))))

;; exigir-booleanos : lista x symbol -> boolean
;; Retorna #t si todos los argumentos son booleanos; si no, levanta error.
(define exigir-booleanos
  (lambda (args quien)
    (if ((list-of boolean?) args)
        #t
        (eopl:error quien "Se esperaban booleanos, se recibió ~s" args))))

;; exigir-cantidad : lista x int x symbol -> boolean
;; Retorna #t si llegaron exactamente n argumentos; si no, levanta error.
(define exigir-cantidad
  (lambda (args n quien)
    (if (= (length args) n)
        #t
        (eopl:error quien "Se esperaban ~s argumentos, llegaron ~s" n (length args)))))

;; exigir-minimo : lista x int x symbol -> boolean
;; Retorna #t si llegaron al menos n argumentos; si no, levanta error.
(define exigir-minimo
  (lambda (args n quien)
    (if (>= (length args) n)
        #t
        (eopl:error quien "Se esperaban al menos ~s argumentos, llegaron ~s" n (length args)))))

;; aritmetica-nria : symbol x procedimiento x lista -> número
;; Aplica f a todos los argumentos (mínimo 2, todos números).
(define aritmetica-nria
  (lambda (quien f args)
    (begin (exigir-minimo args 2 quien)
           (exigir-numeros args quien)
           (apply f args))))

;; relacional : symbol x procedimiento x lista -> booleano
(define relacional
  (lambda (quien f args)
    (begin (exigir-cantidad args 2 quien)
           (exigir-numeros args quien)
           (f (car args) (cadr args)))))

;; logica-binaria : symbol x procedimiento x lista -> booleano
(define logica-binaria
  (lambda (quien f args)
    (begin (exigir-cantidad args 2 quien)
           (exigir-booleanos args quien)
           (f (car args) (cadr args)))))


;; evaluar-primitiva : primitiva x lista de valores -> valor
;; Verifica la cantidad y el tipo de los argumentos y aplica la
;; primitiva. Se resuelve con cases sobre el datatype primitiva.
(define evaluar-primitiva
  (lambda (prim args)
    (cases primitiva prim
      (sum-prim () (aritmetica-nria '+ + args))
      (minus-prim () (aritmetica-nria '- - args))
      (mult-prim () (aritmetica-nria '* * args))
      (div-prim ()
        (begin
          (exigir-minimo args 2 '/)
          (exigir-numeros args '/)
          (if ((list-of (lambda (x) (not (zero? x)))) (cdr args))
              (apply / args)
              (eopl:error '/ "División por cero"))))
      (add-prim ()
        (begin (exigir-cantidad args 1 'add1)
               (exigir-numeros args 'add1)
               (+ (car args) 1)))
      (sub-prim ()
        (begin (exigir-cantidad args 1 'sub1)
               (exigir-numeros args 'sub1)
               (- (car args) 1)))
      (mayor-prim () (relacional '> > args))
      (mayorigual-prim () (relacional '>= >= args))
      (menor-prim () (relacional '< < args))
      (menorigual-prim () (relacional '<= <= args))
      (igual-prim () (relacional '== = args))
      (not-prim ()
        (begin (exigir-cantidad args 1 'not)
               (exigir-booleanos args 'not)
               (not (car args))))
      (and-prim () (logica-binaria 'and (lambda (a b) (and a b)) args))
      (or-prim () (logica-binaria 'or (lambda (a b) (or a b)) args))
      (else (eopl:error 'evaluar-primitiva "Primitiva no soportada todavía")))))

   (provide (all-defined-out))