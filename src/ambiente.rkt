#lang eopl
;Autores: Juan S. Navarrete 2459562, Samuel Garcia Parra 2459476
;; Taller 2 — El intérprete de Cauca.
;; El TAD ambiente, la búsqueda de ligaduras y el ambiente inicial.
;; Requiere sintaxis.rkt y valores.rkt.
;;
;; Aquí se declara con define-datatype el tipo ambiente, con tres
;; variantes:
;;
;;   ambiente-vacio()
;;   ambiente-extendido(ids, valores, env)
;;     ids      (list-of symbol?)
;;     valores  list?
;;     env      ambiente?
;;   ambiente-recursivo(proc-names, idss, bodies, env)
;;     proc-names  (list-of symbol?)   los nombres declarados en el letrec
;;     idss        list?               la lista de parámetros de cada uno
;;     bodies      (list-of expresion?) los cuerpos, guardados sin evaluar
;;     env         ambiente?
;;
;; La variante recursiva no construye clausuras: las arma apply-env en el
;; momento de la búsqueda, y el ambiente que les entrega es el propio
;; ambiente-recursivo (EOPL, sección 3.4, figura 3.9).

(require "sintaxis.rkt")
(require "valores.rkt")

(define-datatype ambiente ambiente?
  (ambiente-vacio)
  (ambiente-extendido
   (ids (list-of symbol?))
   (vals list?)
   (env ambiente?)))
;; En la Parte 4 se agrega aquí la variante ambiente-recursivo.

;; posicion : symbol x lista de symbol -> entero | #f
;; Índice de x dentro de la lista, o #f si no está.
(define posicion
  (lambda (x lst)
    (letrec ((buscar (lambda (l i)
                       (cond ((null? l) #f)
                             ((eqv? (car l) x) i)
                             (else (buscar (cdr l) (+ i 1)))))))
      (buscar lst 0))))


;; apply-env : ambiente x symbol -> valor
;; Busca el identificador en el ambiente, respetando el shadowing de las
;; ligaduras más recientes, y levanta eopl:error si no está ligado.
(define apply-env
  (lambda (env id)
    (cases ambiente env
      (ambiente-vacio ()
        (eopl:error 'apply-env "Variable no ligada: ~s" id))
      (ambiente-extendido (ids vals env-previo)
        (let ((pos (posicion id ids)))
          (if pos
              (list-ref vals pos)
              (apply-env env-previo id)))))))

;; ambiente-inicial : -> ambiente
;; El ambiente con que arranca todo programa:
;; n = 10, m = 3, p = 7, q = 2, r = 5.
(define ambiente-inicial
  (lambda ()
    (ambiente-extendido '(n m p q r) '(10 3 7 2 5) (ambiente-vacio))))

(provide (all-defined-out))
