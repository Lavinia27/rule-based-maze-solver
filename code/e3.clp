;; Aceste reguli ghideaza agentul spre coordonatele iesirii cand e posibil.

;; Daca iesirea e mai la DREAPTA (> ?y) si e liber
(defrule Mutare_Prioritara_Dreapta
   ;; (inactiva)
   (declare (salience 60))
   ?s <- (scop avanseaza)
   ?a <- (agent ?x ?y)
   (iesire ?xi ?yi)
   (test (< ?y ?yi)) ;; Iesirea este la dreapta
   (test (>= (abs (- ?yi ?y)) (abs (- ?xi ?x)))) ;; Testeaza distantele X si Y
   (liber ?x ?y-nou&=(+ ?y 1))
   (not (zid ?x ?y-nou))
   (not (vizitat ?x ?y-nou))
   =>
   (retract ?a)
   (assert (agent ?x ?y-nou) (vizitat ?x ?y-nou) (venit-din ?x ?y-nou ?x ?y))
   (printout t "Agentul merge DREAPTA spre iesire la (" ?x ", " ?y-nou ")." crlf)
)

;; Daca iesirea e mai JOS (> ?x) si e liber
(defrule Mutare_Prioritara_Jos
   ;; (inactiva)
   (declare (salience 60))
   ?s <- (scop avanseaza)
   ?a <- (agent ?x ?y)
   (iesire ?xi ?yi)
   (test (< ?x ?xi)) ;; Iesirea este mai jos
   (test (> (abs (- ?xi ?x)) (abs (- ?yi ?y)))) ;; Testeaza distantele X si Y
   (liber ?x-nou&=(+ ?x 1) ?y)
   (not (zid ?x-nou ?y))
   (not (vizitat ?x-nou ?y))
   =>
   (retract ?a)
   (assert (agent ?x-nou ?y) (vizitat ?x-nou ?y) (venit-din ?x-nou ?y ?x ?y))
   (printout t "Agentul merge JOS spre iesire la (" ?x-nou ", " ?y ")." crlf)
)

;; Daca iesirea e mai la STANGA (< ?y) si e liber
(defrule Mutare_Prioritara_Stanga
   ;; (inactiva)
   (declare (salience 60))
   ?s <- (scop avanseaza)
   ?a <- (agent ?x ?y)
   (iesire ?xi ?yi)
   (test (> ?y ?yi)) ;; Iesirea este la stanga
   (test (>= (abs (- ?yi ?y)) (abs (- ?xi ?x)))) ;; Testeaza distantele X si Y
   (liber ?x ?y-nou&=(- ?y 1))
   (not (zid ?x ?y-nou))
   (not (vizitat ?x ?y-nou))
   =>
   (retract ?a)
   (assert (agent ?x ?y-nou) (vizitat ?x ?y-nou) (venit-din ?x ?y-nou ?x ?y))
   (printout t "Agentul merge STANGA spre iesire la (" ?x ", " ?y-nou ")." crlf)
)

;; Daca iesirea e mai SUS (< ?x) si e liber
(defrule Mutare_Prioritara_Sus
   ;; (inactiva)
   (declare (salience 60))
   ?s <- (scop avanseaza)
   ?a <- (agent ?x ?y)
   (iesire ?xi ?yi)
   (test (> ?x ?xi)) ;; Iesirea este mai sus
   (test (> (abs (- ?xi ?x)) (abs (- ?yi ?y)))) ;; Testeaza distantele X si Y
   (liber ?x-nou&=(- ?x 1) ?y)
   (not (zid ?x-nou ?y))
   (not (vizitat ?x-nou ?y))
   =>
   (retract ?a)
   (assert (agent ?x-nou ?y) (vizitat ?x-nou ?y) (venit-din ?x-nou ?y ?x ?y))
   (printout t "Agentul merge SUS spre iesire la (" ?x-nou ", " ?y ")." crlf)
)



   
; ----
;; REGULI PENTRU CONDITIA DE OPRIRE

;; Tipare de fapte folosite:
;; (scop avanseaza)
;; (agent ?x ?y)
;; (iesire ?x ?y)

(defrule Conditie_Oprire
   ;; (inactiva)
   (declare (salience 100))
   ?s <- (scop avanseaza)
   (agent ?x ?y)
   (iesire ?x ?y)
   =>
   (retract ?s)
   (assert (scop gasit-iesire))
   (printout t "SUCCES! Agentul a gasit iesirea la coordonatele (" ?x ", " ?y ")." crlf)
)

; -----
;; REGULI PENTRU INTRODUCERE SCOPURI (BACKTRACKING)

;; Tipare de fapte folosite:
;; (scop avanseaza)
;; (agent ?x ?y)
;; Evaluare negativa pentru toate directiile adiacente (nu exista o celula valida)

(defrule Detectare_Fundatura
   ;; (inactiva)
   (declare (salience 90))
   ?s <- (scop avanseaza)
   (agent ?x ?y)
   
   ;; Verificare SUS blocat / lipsa / vizitat
   (not (and (liber ?x-sus ?y) 
		(test (= ?x-sus (- ?x 1))) 
		(not (zid ?x-sus ?y)) 
		(not (vizitat ?x-sus ?y))))
		
   ;; Verificare DREAPTA blocat / lipsa / vizitat
   (not (and (liber ?x ?y-dr)  
		(test (= ?y-dr (+ ?y 1)))  
		(not (zid ?x ?y-dr)) 
		(not (vizitat ?x ?y-dr))))
   ;; Verificare JOS blocat / lipsa / vizitat
   (not (and (liber ?x-jos ?y) 
		(test (= ?x-jos (+ ?x 1))) 
		(not (zid ?x-jos ?y)) 
		(not (vizitat ?x-jos ?y))))
   ;; Verificare STANGA blocat / lipsa / vizitat
   (not (and (liber ?x ?y-st)  
		(test (= ?y-st (- ?y 1)))  
		(not (zid ?x ?y-st)) 
		(not (vizitat ?x ?y-st))))
   =>
   (retract ?s)
   (assert (scop intoarcere))
   (printout t "Fundatura la (" ?x ", " ?y "). Nu exista mutari valide. Se initiaza backtracking." crlf)
)
; -------
(defrule Sari_La_Iesire
   ;; Prioritate uriașă (80), bate Dreapta(40), Jos(30), etc., dar e sub Fundatura(90)
   (declare (salience 80)) 
   ?s <- (scop avanseaza)
   ?a <- (agent ?x ?y)
   (iesire ?xi ?yi)
   
   ;; Verificăm dacă ieșirea este un vecin direct (Distanța matematică este fix 1)
   (test (= (+ (abs (- ?x ?xi)) (abs (- ?y ?yi))) 1))
   =>
   (retract ?a)
   (assert (agent ?xi ?yi))
   (assert (vizitat ?xi ?yi))
   (assert (venit-din ?xi ?yi ?x ?y))
   (printout t "S-a apropiat de iesirea (" ?xi ", " ?yi "). " crlf)
)


; -------
;; REGULI PENTRU ACTIUNILE PRIMARE (MUTARI)

;; Tipare: (scop avanseaza), (agent ?x ?y), (liber ?x ?y+1), nu zid, nu vizitat
(defrule Mutare_Dreapta
   ;; (inactiva)
   (declare (salience 40))
   ?s <- (scop avanseaza)
   ?a <- (agent ?x ?y)
   (liber ?x ?y-nou&=(+ ?y 1))
   (not (zid ?x ?y-nou))
   (not (vizitat ?x ?y-nou))
   =>
   (retract ?a)
   (assert (agent ?x ?y-nou))
   (assert (vizitat ?x ?y-nou))
   (assert (venit-din ?x ?y-nou ?x ?y)) ;; Salvam urma pentru intoarcere
   (printout t "Agentul s-a mutat DREAPTA la coordonatele (" ?x ", " ?y-nou ")." crlf)
)

;; Tipare: (scop avanseaza), (agent ?x ?y), (liber ?x+1 ?y), nu zid, nu vizitat
(defrule Mutare_Jos
   ;; (inactiva)
   (declare (salience 30))
   ?s <- (scop avanseaza)
   ?a <- (agent ?x ?y)
   (liber ?x-nou&=(+ ?x 1) ?y)
   (not (zid ?x-nou ?y))
   (not (vizitat ?x-nou ?y))
   =>
   (retract ?a)
   (assert (agent ?x-nou ?y))
   (assert (vizitat ?x-nou ?y))
   (assert (venit-din ?x-nou ?y ?x ?y))
   (printout t "Agentul s-a mutat JOS la coordonatele (" ?x-nou ", " ?y ")." crlf)
)

;; Tipare: (scop avanseaza), (agent ?x ?y), (liber ?x ?y-1), nu zid, nu vizitat
(defrule Mutare_Stanga
   ;; (inactiva)
   (declare (salience 20))
   ?s <- (scop avanseaza)
   ?a <- (agent ?x ?y)
   (liber ?x ?y-nou&=(- ?y 1))
   (not (zid ?x ?y-nou))
   (not (vizitat ?x ?y-nou))
   =>
   (retract ?a)
   (assert (agent ?x ?y-nou))
   (assert (vizitat ?x ?y-nou))
   (assert (venit-din ?x ?y-nou ?x ?y))
   (printout t "Agentul s-a mutat STANGA la coordonatele (" ?x ", " ?y-nou ")." crlf)
)

;; Tipare: (scop avanseaza), (agent ?x ?y), (liber ?x-1 ?y), nu zid, nu vizitat
(defrule Mutare_Sus
   ;; (inactiva)
   (declare (salience 10))
   ?s <- (scop avanseaza)
   ?a <- (agent ?x ?y)
   (liber ?x-nou&=(- ?x 1) ?y)
   (not (zid ?x-nou ?y))
   (not (vizitat ?x-nou ?y))
   =>
   (retract ?a)
   (assert (agent ?x-nou ?y))
   (assert (vizitat ?x-nou ?y))
   (assert (venit-din ?x-nou ?y ?x ?y))
   (printout t "Agentul s-a mutat SUS la coordonatele (" ?x-nou ", " ?y ")." crlf)
)

; -------
;; REGULA PENTRU EXECUTIE BACKTRACKING
;; Tipare: (scop intoarcere), (agent ?x ?y), (venit-din ?x ?y ?x-ant ?y-ant)

(defrule Executie_Intoarcere
   ;; (inactiva)
   ?s <- (scop intoarcere)
   ?a <- (agent ?x ?y)
   (venit-din ?x ?y ?x-ant ?y-ant)
   =>
   (retract ?a ?s)
   (assert (agent ?x-ant ?y-ant))
   (assert (drum_infundat ?x ?y)) ;; Blocăm complet nodul pentru viitor
   (assert (scop avanseaza))      ;; Reluam cautarea din celula veche
   (printout t "Agentul s-a intors la (" ?x-ant ", " ?y-ant ")." crlf)
)