#lang eopl
;Autores: Nombre1 Codigo1, Samuel Garcia Parra 202459476

;; Taller 2 — El intérprete de Cauca.
;; Las primitivas del lenguaje y las verificaciones de tipo y de
;; cantidad de argumentos que cada una exige. Requiere sintaxis.rkt.
;;
;; Aridades: +, -, *, / son n-arias; add1, sub1, not y abs son unarias;
;; las relacionales, and, or, xor e implica son binarias; entre es
;; ternaria; mcd y mcm son n-arias sobre enteros con al menos dos
;; argumentos; promedio es n-aria sobre números con al menos uno.

(require "sintaxis.rkt")

(define todos?
  (lambda (pred lst)
    (or (null? lst) (and (pred (car lst)) (todos? pred (cdr lst))))))

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

    (if (>= (length args) n) #t
        (eopl:error quien "se esperaban al menos ~s argumentos, llegaron ~s" n (length args)))))

(define calcular-mcd-2
  (lambda (a b) (if (= b 0) (abs a) (calcular-mcd-2 b (remainder a b)))))
;; Calcula para 2 numeros, es recursiva

(define calcular-mcd
  (lambda (args)
    (if (null? (cdr args)) (abs (car args))
        (calcular-mcd-2 (car args) (calcular-mcd (cdr args))))))
;; Si es un solo valor devuelve si valor absoluto, en otro caso combina el primer
;; elemento con el MCD del resto

(define calcular-mcm-2
  (lambda (a b)
    (if (or (= a 0) (= b 0)) 0 (/ (abs (* a b)) (calcular-mcd-2 a b)))))
;; Cuida el resultado en caso de que sea 0 (dividir entre 0 debe dar 0)

(define calcular-mcm
  (lambda (args)
    (if (null? (cdr args)) (abs (car args))
        (calcular-mcm-2 (car args) (calcular-mcm (cdr args))))))
;; Igual que mcd, pero con el mcm de los numeros

(define calcular-promedio
  (lambda (args) (/ (apply + args) (length args))))
;; Suma los datos y divide entre la cantidad 

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
    (cases primitiva prim
      (sum-prim ()  ...)      ;Pendiente hasta que Navarrete las agregue
      ...
      (abs-prim ()      (primitiva-abs args))       ;En este archivo
      (mcd-prim ()      (primitiva-mcd args))
      (mcm-prim ()      (primitiva-mcm args))
      (promedio-prim () (primitiva-promedio args))
      (xor-prim ()      (primitiva-xor args))
      (implica-prim ()  (primitiva-implica args))
      (entre-prim ()    (primitiva-entre args)))))

   (provide (all-defined-out))