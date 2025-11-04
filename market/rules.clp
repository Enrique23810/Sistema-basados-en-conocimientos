;;
;; --- PRUEBA DE DEBUG ---
(defrule debug-file-loaded
   (declare (salience 100)) ; Prioridad alta
   (initial-fact)
   =>
   (printout t "--- ARCHIVO DE REGLAS v3 CARGADO EXITOSAMENTE ---" crlf crlf)
)
;; -------------------------------------------

;;Define a rule for finding those customers who have not bought nothing at all... so far
(defrule cust-not-buying
     (customer (customer-id ?id) (name ?name))
     (not (order (order-number ?order) (customer-id ?id)))
   =>
   (printout t ?name " no ha comprado... nada!" crlf))

;;Define a rule for finding which products have been bought
(defrule prods-bought
   (order (order-number ?order))
   (line-item (order-number ?order) (part-number ?part))
   (product (part-number ?part) (name ?pn))
   =>
   (printout t ?pn " was bought " crlf))

;;Define a rule for finding which products have been bought AND their quantity
(defrule prods-qty-bgt
   (order (order-number ?order))
   (line-item (order-number ?order) (part-number ?part) (quantity ?q))
   (product (part-number ?part) (name ?p) )
   =>
   (printout t ?q " " ?p " was/were bought " crlf))

;;Define a rule for finding customers and their shopping info
(defrule customer-shopping
   (customer (customer-id ?id) (name ?cn))
   (order (order-number ?order) (customer-id ?id))
   (line-item (order-number ?order) (part-number ?part))
   (product (part-number ?part) (name ?pn))
   =>
   (printout t ?cn " bought  " ?pn crlf))

;;Define a rule for finding those customers who bought more than 5 products
(defrule cust-5-prods
   (customer (customer-id ?id) (name ?cn))
   (order (order-number ?order) (customer-id ?id))
   (line-item (order-number ?order) (part-number ?part) (quantity ?q))
   (test (> ?q 5))
   (product (part-number ?part) (name ?pn))
   =>
   (printout t ?cn " bought more than 5 products (" ?pn ")" crlf))

;; Define a rule for texting custormers who have not bought ...
(defrule text-cust (customer (customer-id ?cid) (name ?name) (phone ?phone))
                   (not (order (order-number ?order) (customer-id ?cid)))
=>
(assert (text-customer ?name ?phone "tienes 25% desc prox compra"))
(printout t ?name " 3313073905 tienes 25% desc prox compra" crlf)) ;; <-- Con salto de línea

;; Define a rule for calling  custormers who have not bought ...
(defrule call-cust (customer (customer-id ?cid) (name ?name) (phone ?phone))
                   (not (order (order-number ?order) (customer-id ?cid)))
=>
(assert (call-customer ?name ?phone "tienes 25% desc prox compra"))
(printout t ?name " 3313073905 tienes 25% desc prox compra" crlf)) ;; <-- Con salto de línea

;;
;; REGLA DE CROSS-SELLING (CORREGIDA)
;;
(defrule recommend-usb-for-amplifier
   (customer (customer-id ?cid) (name ?cname))
   
   ;; --- CORRECCIÓN: Buscando SÍMBOLOS, no "Strings" ---
   (product (part-number ?amplifier-pid) (name Amplifier)) 
   (order (customer-id ?cid) (order-number ?order1))
   (line-item (order-number ?order1) (part-number ?amplifier-pid))
   
   ;; --- CORRECCIÓN: Buscando SÍMBOLOS, no "Strings" ---
   (product (part-number ?usb-pid) (name USBMem))
   (not (and (order (customer-id ?cid) (order-number ?order2))
             (line-item (order-number ?order2) (part-number ?usb-pid))
        )
   )
   =>
   (printout t crlf) 
   (printout t ">>> RECOMENDACION (Cross-Sell) para " ?cname ":" crlf)
   (printout t "    Vimos que compraste un 'Amplifier'. ¡Una 'USBMem' seria el complemento perfecto!" crlf)
   (printout t crlf)
)
