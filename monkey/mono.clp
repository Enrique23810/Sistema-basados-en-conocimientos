;; ----------------------------------------------------
;; Problema del Mono y las Bananas en CLIPS
;; (Versión Avanzada con Estado Aleatorio y Reglas Basadas en Prioridad)
;; ----------------------------------------------------

;; --- 1. DEFINICIÓN DE ESTRUCTURAS (Templates) ---
(deftemplate estado
   (slot mono-en      (type SYMBOL))  ; Ubicación del mono (puerta, ventana, centro)
   (slot caja-en      (type SYMBOL))  ; Ubicación de la caja (puerta, ventana, centro)
   (slot mono-sobre   (type SYMBOL))  ; Posición del mono (suelo, caja)
   (slot tiene-bananas (type SYMBOL))  ; (si | no)
)

;; --- 3. BASE DE CONOCIMIENTO (Reglas) ---

;; Regla 0: INICIALIZAR EL MUNDO (Prioridad Máxima)
(defrule inicializar-estado-aleatorio
   (declare (salience 1000)) ; La prioridad más alta
   (initial-fact)
   =>
   ;; Genera dos números aleatorios: 1, 2, o 3
   (bind ?mono-rnd (random 1 3))
   (bind ?caja-rnd (random 1 3))
   
   ;; Mapea el # aleatorio del mono a una ubicación
   (bind ?mono-loc nil)
   (if (= ?mono-rnd 1) then (bind ?mono-loc puerta)
   else if (= ?mono-rnd 2) then (bind ?mono-loc ventana)
   else (bind ?mono-loc centro))
   
   ;; Mapea el # aleatorio de la caja a una ubicación
   (bind ?caja-loc nil)
   (if (= ?caja-rnd 1) then (bind ?caja-loc puerta)
   else if (= ?caja-rnd 2) then (bind ?caja-loc ventana)
   else (bind ?caja-loc centro))
   
   (printout t "--- ESTADO INICIAL ALEATORIO ---" crlf)
   (printout t "Mono empieza en: " ?mono-loc crlf)
   (printout t "Caja empieza en: " ?caja-loc crlf crlf)
   
   ;; Crea el hecho inicial (assert)
   (assert (estado (mono-en ?mono-loc)
                   (caja-en ?caja-loc)
                   (mono-sobre suelo)
                   (tiene-bananas no)))
)

;; Regla 4: AGARRAR LAS BANANAS (Prioridad 100)
(defrule agarrar-bananas
   (declare (salience 100))
   ?e <- (estado (mono-en centro) 
                 (mono-sobre caja) 
                 (tiene-bananas no))
   =>
   (modify ?e (tiene-bananas si))
   (printout t "Paso 4: ¡El mono agarra las bananas!" crlf)
)

;; Regla 3: SUBIRSE A LA CAJA (Prioridad 90)
(defrule subirse-a-la-caja
   (declare (salience 90))
   ?e <- (estado (mono-en centro) 
                 (caja-en centro) 
                 (mono-sobre suelo))
   =>
   (modify ?e (mono-sobre caja))
   (printout t "Paso 3: El mono se sube a la caja." crlf)
)

;; Regla 2: EMPUJAR LA CAJA AL CENTRO (Prioridad 80)
(defrule empujar-caja-al-centro
   (declare (salience 80))
   ?e <- (estado (mono-en ?loc&:(neq ?loc centro)) 
                 (caja-en ?loc) 
                 (mono-sobre suelo))
   =>
   (modify ?e (mono-en centro) (caja-en centro))
   (printout t "Paso 2: El mono empuja la caja al centro." crlf)
)

;; Regla 1: CAMINAR HACIA LA CAJA (Prioridad 70)
(defrule caminar-hacia-caja
   (declare (salience 70))
   ?e <- (estado (mono-en ?m-loc) 
                 (caja-en ?c-loc&:(neq ?c-loc ?m-loc)) 
                 (mono-sobre suelo))
   =>
   (modify ?e (mono-en ?c-loc))
   (printout t "Paso 1: El mono camina hacia la caja." crlf)
)

;; Regla Final: DECLARAR VICTORIA (Prioridad Mínima)
(defrule declarar-victoria
    (declare (salience -100))
    ?e <- (estado (tiene-bananas si))
    =>
    (printout t crlf "¡¡¡VICTORIA!!!" crlf)
    (retract ?e) ; Limpia el hecho para terminar la simulación
)