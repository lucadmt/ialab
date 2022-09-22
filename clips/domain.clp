(defmodule DOMAIN (export ?ALL))

(deftemplate DOMAIN::house
  (slot id (default-dynamic (gensym*)))
  (slot mq (type INTEGER) (range 1 ?VARIABLE))
  (slot nrooms (type INTEGER) (range 1 ?VARIABLE))
  (slot ntoilettes (type INTEGER) (range 1 ?VARIABLE))
  (slot nlevels (type INTEGER) (range 1 ?VARIABLE))
  (slot weather (allowed-symbols cold freezing warm hot mild unknown))
  (slot city)
  (slot zone (allowed-symbols centro completamento periferia campagna))
  (slot hood)
  (slot elevator)
  (slot renewables)   ;; takes energy from renewable sources or not
  (slot furnished (default TRUE))
  (slot carbox)
  (slot carboxmq (type INTEGER) (range 0 ?VARIABLE))
  (slot fixtures-rank (type INTEGER) (range 1 5))
  (slot internet-rank (type INTEGER) (range 0 5))
  (slot score (type FLOAT) (range 0.0 100.0) (default 0.0))
  (slot scoring-round (type INTEGER) (range 0 3) (default 0))
  (slot kind (allowed-symbols rent property) (default property))
  (slot nearest-club (default-dynamic (random 0 10)))
  (slot nearest-school (default-dynamic (random 0 10)))
  (slot nearest-phisician (default-dynamic (random 0 10)))
  (slot price (type INTEGER) (range 0 ?VARIABLE)))

(deftemplate DOMAIN::city
  (slot handle)
  (slot internet-rank (type INTEGER) (range 1 5))
  (slot weather (allowed-symbols cold freezing warm hot mild))
  (slot kind (allowed-symbols seaside sea-near neutral forestside mount-near mountside))
  (slot inhabitants (type INTEGER))) ;; Useful to model activity

(deftemplate DOMAIN::hood
  (slot handle)
  (slot city)
  (slot rent-price (type FLOAT) (default 10.0))
  (slot property-price (type FLOAT) (default 1000.0)))

;;----------------- MAIN -----------------

(defmodule MAIN (export ?ALL))

(deffunction MAIN::ask-question (?question ?allowed-values)
  (printout t ?question)
  (bind ?answer (read))
  (if (lexemep ?answer) then
		                  (bind ?answer (lowcase ?answer)))
  ;;    (printout t (eq ?allowed-values (create$ free)) crlf)
  (if (eq ?allowed-values (create$ free)) then
		                                    (progn
			                                  (if (lexemep ?answer) then
				                                                      (bind ?answer (lowcase ?answer)))
			                                  (return ?answer))
   else
	 (while (not (member$ ?answer ?allowed-values)) do
			(printout t "[E] Valore errato, riprovare." crlf)
			(printout t ?question)
			(bind ?answer (read))
			(if (lexemep ?answer) then
				                    (bind ?answer (lowcase ?answer))))
	 (return ?answer)))

(deftemplate MAIN::attr
  "OAV tuples"
  (multislot name)
  (slot value)
  (slot cert (type FLOAT) (range 0.0 1.0) (default 1.0))
  )

(defrule MAIN::start
  (declare (salience 10000))
  ?i <- (initial-fact)
 =>
  (retract ?i)
  (set-fact-duplication TRUE)
  (focus QUESTIONS SELECTION ANSWERS)
)


(defrule MAIN::auto-pcerts
	"Automatically combine positive certainty factors"
	(declare (auto-focus TRUE))
	?fact1 <- (attr (name $?d) (value ?v) (cert ?C1&:(>= ?C1 0.0)))
	?fact2 <- (attr (name $?d) (value ?v) (cert ?C2&:(>= ?C2 0.0)))
	(test (neq ?fact1 ?fact2))
=>
	(retract ?fact1)
	(bind ?C3 (- (+ ?C1 ?C2) (* ?C1 ?C2)))
	(modify ?fact2 (cert ?C3))
)

(defrule MAIN::auto-ncerts
	"Automatically combine negative certainty factors"
	(declare (auto-focus TRUE))
	?fact1 <- (attr (name $?d) (value ?v) (cert ?C1&:(<= ?C1 0.0)))
	?fact2 <- (attr (name $?d) (value ?v) (cert ?C2&:(<= ?C2 0.0)))

	(test (neq ?fact1 ?fact2))
=>
	(retract ?fact1)
	(bind ?C3 (+ (+ ?C1 ?C2) (* ?C1 ?C2)))
	(modify ?fact2 (cert ?C3))
)

(defrule MAIN::auto-mcerts
	"Automatically combine mixed certainty factors"
	(declare (auto-focus TRUE))
	?fact1 <- (attr (name $?d) (value ?v) (cert ?C1))
	?fact2 <- (attr (name $?d) (value ?v) (cert ?C2))

	(test (neq ?fact1 ?fact2))
	(test (< (* ?C1 ?C2) 0.0))
=>
	(retract ?fact1)
	(bind ?C3 (/ (+ ?C1 ?C2) (- 1 (min (abs ?C1) (abs ?C2) ))))
	(modify ?fact2 (cert ?C3))
)

;;----------------- QUESTIONS -----------------

(defmodule QUESTIONS (import MAIN ?ALL) (export ?ALL))

(deftemplate QUESTIONS::question
	"Template for user-facing questions"
   (slot attribute (default ?NONE))
   (slot prompt (default ?NONE))
   (multislot valid-answers (default free))
   (slot ask-relevance (default TRUE))
   (slot already-asked (default FALSE))
   (multislot precursors (default ?DERIVE))
   (multislot features)
   (slot round (default 1)))

(deftemplate QUESTIONS::importance
  (slot id (default-dynamic (gensym*)))
  (slot by-price)
  (slot by-mq)
  (slot by-carboxmq)
  (slot by-city)
  (slot by-zone)
  (slot by-hood)
  (slot by-nrooms)
  (slot by-ntoilettes)
  (slot by-nlevels)
  (slot by-elevator)
  (slot by-renewables)
  (slot by-furniture)
  (slot by-fixtures)
  (slot by-netrank)
  (slot by-cityk)
  (slot by-nightlife)
  (slot by-elderly)
  (slot by-schools))

(deftemplate QUESTIONS::lock
  (slot id (type INTEGER) (default 1) (range 1 1))
  (slot turn (default TRUE)))

(defrule QUESTIONS::qnew-round
  ?r <- (round ?round &:(< ?round 3))
  (round-questions-asked FALSE)
  ?incremented <- (round-incremented FALSE)

  ?lock <- (lock
   (id 1)
   (turn TRUE))

 =>
  (printout t "---- New question round! ----" crlf)
  (set-strategy breadth)
  (retract ?r ?incremented)
  (assert (round (+ ?round 1)) (round-incremented TRUE)))

(defrule QUESTIONS::no-more-questions
  ?r <- (round ?curr-round)
  ;; Check that there aren't anymore questions for the current round
  (not
   (question (round ?round &:(eq ?round ?curr-round)) (already-asked FALSE)))
 =>
  (assert (round-questions-asked TRUE)))

(defrule QUESTIONS::reset-asked
  ?asked <- (round-questions-asked TRUE)
  ?incremented <- (round-incremented TRUE)

  ?lock <- (lock
   (id 1)
   (turn TRUE))
 =>
  (retract ?asked ?incremented)
  (assert (round-questions-asked FALSE) (round-incremented FALSE))
  (modify ?lock (turn FALSE))
  ;;(set-strategy depth)
  (focus SELECTION ANSWERS QUESTIONS))

(defrule QUESTIONS::ask-a-question
	"Helper rule to actually do the asking of a question to the user"
  ?r <- (round ?round)

  ?f <- (question (already-asked FALSE)
                  (ask-relevance ?ask-relevance)
                  (precursors)
                  (prompt ?prompt)
                  (attribute ?the-attribute)
                  (valid-answers $?valid-answers)
                  (round ?round))
 =>
  (bind ?v (ask-question ?prompt ?valid-answers))
  (if ?ask-relevance then
                       (bind ?c
                         (/ (ask-question "How much should I keep that into consideration? [1..5] > "
                                          (create$ 1 2 3 4 5)) 5))
                       (assert (attr (name ?the-attribute)
                                     (value ?v)
                                     (cert ?c)))
   else
     (if (eq ?valid-answers (create$ 1 2 3 4 5)) then
                                                   (assert (attr (name ?the-attribute)
                                                                 (value ?v)
                                                                 (cert (/ ?v 6))))
      else
        (assert (attr (name ?the-attribute)
                      (value ?v)
                      (cert 1.0)))))
  (modify ?f (already-asked TRUE)))

(defrule QUESTIONS::precursor-is-satisfied
	?f <- (question (already-asked FALSE)
					(precursors ?name is ?value $?rest))
		(attr (name ?name) (value ?value))
=>
	(if (eq (nth$ 1 ?rest) and)
	then (modify ?f (precursors (rest$ ?rest)))
	else (modify ?f (precursors ?rest))))

(defrule QUESTIONS::precursor-is-not-satisfied
	?f <- (question (already-asked FALSE)
					(precursors ?name is-not ?value $?rest))
		(attr (name ?name) (value ~?value))
=>
	(if (eq (nth$ 1 ?rest) and)
	then (modify ?f (precursors (rest$ ?rest)))
	else (modify ?f (precursors ?rest))))

(defrule QUESTIONS::precursor-greater-than-x
	?f <- (question (already-asked FALSE)
					(precursors ?name gt ?value $?rest))
		(attr (name ?name) (value ?v))
		(test (> ?v ?value))
=>
	(if (eq (nth$ 1 ?rest) and)
	then (modify ?f (precursors (rest$ ?rest)))
	else (modify ?f (precursors ?rest))))

(defrule QUESTIONS::precursor-lesser-than-x
	?f <- (question (already-asked FALSE)
					(precursors ?name lt ?value $?rest))
		(attr (name ?name) (value ?v))
		(test (< ?v ?value))
=>
	(if (eq (nth$ 1 ?rest) and)
	then (modify ?f (precursors (rest$ ?rest)))
	else (modify ?f (precursors ?rest))))

(defrule QUESTIONS::precursor-greater-or-equal-than-x
	?f <- (question (already-asked FALSE)
					(precursors ?name geq ?value $?rest))
		(attr (name ?name) (value ?v))
		(test (>= ?v ?value))
=>
	(if (eq (nth$ 1 ?rest) and)
	then (modify ?f (precursors (rest$ ?rest)))
	else (modify ?f (precursors ?rest))))

(defrule QUESTIONS::precursor-lesser-or-equal-than-x
	?f <- (question (already-asked FALSE)
					(precursors ?name leq ?value $?rest))
		(attr (name ?name) (value ?v))
		(test (<= ?v ?value))
=>
	(if (eq (nth$ 1 ?rest) and)
	then (modify ?f (precursors (rest$ ?rest)))
	else (modify ?f (precursors ?rest))))


;; ---------------- RULES ----------------
;; These rules don't belong to the domain, this module
;; only makes rule definition less tedious.

(defmodule _RULES (import MAIN ?ALL) (export ?ALL))

(deftemplate _RULES::rule
	(slot comment (type STRING))
	(slot certainty (default 1.0))
	(multislot if)
	(multislot then))

(defrule _RULES::throw-away-ands-in-antecedent
	?f <- (rule (if and $?rest))
=>
	(modify ?f (if ?rest)))

(defrule _RULES::throw-away-ands-in-consequent
	?f <- (rule (then and $?rest))
=>
	(modify ?f (then ?rest)))

(defrule _RULES::remove-is-condition-when-satisfied
	?f <- (rule (certainty ?c1)
				(if ?attr is ?value $?rest))
	(attr (name ?attr)
			 (value ?value)
			 (cert ?c2))
=>
	(modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule _RULES::remove-is-not-condition-when-satisfied
	?f <- (rule (certainty ?c1)
			(if ?attr is-not ?value $?rest))
	(attr (name ?attr) (value ~?value) (cert ?c2))
=>
	(modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule _RULES::remove-gt-condition-when-satisfied
	?f <- (rule (certainty ?c1)
			(if ?attr gt ?value $?rest))
	(attr (name ?attr) (value ?v) (cert ?c2))
	(test (> ?v ?value))
=>
	(modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule _RULES::remove-lt-condition-when-satisfied
	?f <- (rule (certainty ?c1)
			(if ?attr lt ?value $?rest))
	(attr (name ?attr) (value ?v) (cert ?c2))
	(test (< ?v ?value))
=>
	(modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule _RULES::remove-geq-condition-when-satisfied
	?f <- (rule (certainty ?c1)
			(if ?attr geq ?value $?rest))
	(attr (name ?attr) (value ?v) (cert ?c2))
	(test (>= ?v ?value))
=>
	(modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))

(defrule _RULES::remove-leq-condition-when-satisfied
	?f <- (rule (certainty ?c1)
			(if ?attr leq ?value $?rest))
	(attr (name ?attr) (value ?v) (cert ?c2))
	(test (<= ?v ?value))
=>
	(modify ?f (certainty (min ?c1 ?c2)) (if ?rest)))


(defrule _RULES::perform-rule-consequent-with-certainty
	?f <- (rule (certainty ?c1)
			(if)
			(then ?attr is ?value with certainty ?c2 $?rest))
=>
	(modify ?f (then ?rest))
	(assert (attr (name ?attr)
					(value ?value)
					(cert (/ (* ?c1 ?c2) 1.0)))))

(defrule _RULES::perform-rule-consequent-without-certainty
	?f <- (rule (certainty ?c1)
			(if)
			(then ?attr is ?value $?rest))
	(test (or (eq (length$ ?rest) 0)
			(neq (nth$ 1 ?rest) with)))
=>
	(modify ?f (then ?rest))
	(assert (attr (name ?attr) (value ?value) (cert ?c1))))

;; ---------------- SELECTION ----------------
(defmodule SELECTION
	(import _RULES ?ALL)
	(import QUESTIONS ?ALL)
	(import MAIN ?ALL))

(defrule SELECTION::main => (focus _RULES))

(defrule SELECTION::personal-price-importance
  "Update importance for price-negotiability"
  (attr
   (name house-negotiableness)
   (cert ?cert))
  ?importance <- (importance (id 1) (by-price nil))
 =>
  (modify ?importance (by-price (- 1 ?cert))))

(defrule SELECTION::house-vehicles-importance
  "Update importance for house-vehicles"
  (attr
   (name house-vehicles)
   (cert ?cert))
  ?importance <- (importance (id 1) (by-carboxmq nil))
 =>
  (modify ?importance (by-carboxmq ?cert)))

(defrule SELECTION::personal-diy-importance
  "Update importance for diy"
  (attr
   (name personal-diy)
   (cert ?cert))
  ?importance <- (importance (id 1) (by-furniture nil))
 =>
  (modify ?importance (by-furniture ?cert)))

(defrule personal-ambientalist-importance
  "Update importance for personal-ambientalist"
  (attr
   (name personal-ambientalist)
   (cert ?cert))
  ?importance <- (importance (id 1) (by-renewables nil))
 =>
  (modify ?importance (by-renewables ?cert)))

(defrule personal-mq-importance
  "Update importance for target-mq"
  (attr
   (name house-target-mq)
   (cert ?cert))
  ?importance <- (importance (id 1) (by-mq nil))
 =>
  (modify ?importance (by-mq ?cert)))

(defrule personal-cityk-importance
  "Update importance for city kind"
  (attr
   (name personal-cityk)
   (cert ?cert))
  ?importance <- (importance (id 1) (by-cityk nil))
 =>
  (modify ?importance (by-cityk ?cert)))

(defrule personal-previoushouse-importance
  "Update importance for prevhouse"
  (attr
   (name personal-previoushouse)
   (cert ?cert))
  ?importance <- (importance (id 1) (by-zone nil))
 =>
  (modify ?importance (by-zone ?cert)))


;; 10. personal diy rules

(defrule SELECTION::diy-furnished
  "If family likes DIY, probably will NOT need a furnished house"
  (attr
   (name personal-diy)
   (cert ?c))
  (test (> ?c 0.5))
 =>
  (assert
    (attr
     (name needs-furniture)
     (value y)
     (cert (- 1 ?c)))
    (attr
     (name needs-furniture)
     (value n)
     (cert ?c))))

(defrule SELECTION::house-carboxmqcalc
  (attr
   (name house-vehicles)
   (value ?v))
 =>
  (assert (attr
           (name least-carboxmq)
           (value (* ?v 5))
           (cert 0.8))
          (attr
           (name least-carboxmq)
           (value (* ?v 3))
           (cert 0.2))
          (attr
           (name most-carboxmq)
           (value (* ?v 7))
           (cert 0.8))
          (attr
           (name most-carboxmq)
           (value (* ?v 5))
           (cert 0.2))))

;; ---------------- ANSWERS ----------------
(defmodule ANSWERS
  (import DOMAIN ?ALL)
  (import MAIN ?ALL)
  (import QUESTIONS deftemplate lock importance question)
  (export ?ALL))

(deftemplate ANSWERS::eligible
  (slot id (default-dynamic (gensym*)))
  (slot treshold (type INTEGER) (default 5))
  (multislot by-price)
  (multislot by-mq)
  (multislot by-carboxmq)
  (multislot by-city)
  (multislot by-zone)
  (multislot by-hood)
  (multislot by-nrooms)
  (multislot by-ntoilettes)
  (multislot by-nlevels)
  (multislot by-elevator)
  (multislot by-renewables)
  (multislot by-furniture)
  (multislot by-fixtures)
  (multislot by-netrank)
  (multislot by-cityk)
  (multislot by-nightlife)
  (multislot by-elderly)
  (multislot by-schools))

(deffunction puts
  "Function made to debug stuff in the LHS of the rules"
  ($?rest)
  (printout t "[LOG]: " $?rest crlf)
  (return TRUE))

(deffunction ANSWERS::price-in-range
  "Checks wether a certain price is in a correct range of possible negotiability"
  (?red ?negotiability ?target-price)
  (bind ?price (* ?red 1000))
  (bind ?price-delta (* ?price ?negotiability))
  (bind ?price-hi (+ ?price ?price-delta))
  ;; (if (member$ log $?options) then
  ;; empirical knowledge: obviously a client that could spend $x
  ;; would be very willing to spend anything < $x.
  ;; Here, we just determine the upper bound of that
  ;; based on negotiability
  ;;(printout t "price " ?price ", must be <= " ?price-hi crlf))
  (return (and (<= ?target-price ?price-hi) (> 0 ?target-price))))

(deffunction ANSWERS::shall-continue
  "Asks the user if it's satisfied with the alternatives proposed or wants to continue"
  ()
  (printout t crlf
            "That's the best I got with the current data. "
            crlf
            "Should I keep looking? [y/n] > ")
  (bind ?answer (read))
  (while (not (member$ ?answer (create$ y n))) do
         (printout t "[E] Valore errato, riprovare." crlf)
         (printout t
                   "Should I keep looking? [y/n] > ")
         (bind ?answer (read))
         (if (lexemep ?answer) then
                                 (bind ?answer (lowcase ?answer))))
  (if (eq ?answer n) then
                       (halt))
  (return (eq ?answer y)))

(deffunction ANSWERS::weather-by-index
  "Gets the weather by an index value"
  (?idx)
  (bind ?weather (create$ freezing cold mild warm hot))
  (return (nth$ ?idx ?weather)))

(deffunction ANSWERS::reset-already-scored
  "Reset (already-scored) field value from houses"
  ($?already-scored-ms)
  (foreach ?house $?already-scored-ms
    (modify ?house (already-scored FALSE))))
;; (printout t "House has been scored: " (fact-slot-value ?house already-scored) crlf)
;; (printout t "House has been scored: "
;;          (fact-slot-value (modify ?house (already-scored FALSE)) already-scored) crlf)))

(deffunction ANSWERS::evaluate-house
  "Evaluate a house, considering the eligibles instance"
  (?house ?eligibles ?importance ?known-feats)
  ;;(bind $?eslots (create$ by-price by-mq by-carboxmq by-city
  ;;                        by-zone by-elevator by-renewables
  ;;                        by-furniture by-fixtures by-netrank
  ;;                        by-cityk by-nightlife by-elderly
  ;;                        by-schools))
  (bind $?satisfies (create$ ))
  (bind ?len (length$ ?known-feats))
  (bind ?score (fact-slot-value ?house score))
  (foreach ?eslot ?known-feats
;;     (printout t "id: " (fact-slot-value ?house id) " (in " ?eslot "):"
;;              (fact-slot-value ?eligibles ?eslot) crlf)
    (if (member$ (fact-slot-value ?house id)
                 (fact-slot-value ?eligibles ?eslot)) then
                                                        (bind ?imp (fact-slot-value ?importance ?eslot))
                                                        (bind $?satisfies (create$ $?satisfies ?eslot))

                                                        (if (neq ?imp nil) then
                                                                             ;; (printout t "house score: " (fact-slot-value ?house score) crlf)
                                                                             ;; (printout t "new (calculated) score: " (/ (+ (* ?imp 1) ?score) ?len) " | score: " ?score " len: " ?len " adding: " ?imp crlf)
                                                                             (bind ?score (+ ?score (/ (* ?imp 1) ?len)))
                                                         else
                                                                             ;; If you don't know the importance, assume 50/50
                                                                             (bind ?score (+ ?score (/ 0.5 ?len)))
                                                           ;;(printout t "house score: " (fact-slot-value ?house score) crlf)
                                                           ;;(printout t "new (calculated) score: " ?score " | score: " ?score " len: " ?len " adding: " 0 crlf))
)))
  (printout t crlf)

  (if (> ?score 0) then
                     (printout t crlf "-------- I think I got the house for you ---------------------" crlf)
                     (printout t "satisfied constraints: " $?satisfies crlf)
                     (foreach ?hslot (create$ id mq nrooms ntoilettes nlevels
                                              weather city zone hood elevator
                                              renewables furnished carbox carboxmq
                                              fixtures-rank internet-rank price
                                              nearest-club nearest-school nearest-phisician)
                       (if (neq ?hslot score) then
                                                (printout t ?hslot ": " (fact-slot-value ?house ?hslot) crlf)))
                     (printout t "Scores: " (* ?score 100)
                               "% --------------------------------" crlf crlf))
  (bind ?nf (modify ?house (score ?score)
                    (scoring-round (+ (fact-slot-value ?house scoring-round) 1))))
  (return ?nf))

(defrule ANSWERS::estimate-prices
  (declare (salience 2))
  ?h <- (house
         (mq ?mqs)
         (city ?city)
         (hood ?hood)
         (price 0))

  (city
   (handle ?city))

  (hood
   (handle ?hood)
   (city ?city)
   (rent-price ?rent-price)
   (property-price ?prop-price))

 =>
  (modify ?h (price (* ?mqs ?prop-price))))

(defrule ANSWERS::estimate-netrank
  (declare (salience 2))
  ?h <- (house
         (mq ?mqs)
         (city ?city)
         (hood ?hood)
         (internet-rank 0))

  (city
   (handle ?city)
   (internet-rank ?rank))
 =>
  (modify ?h (internet-rank ?rank)))

(defrule ANSWERS::estimate-weather
  (declare (salience 2))
  ?h <- (house
         (mq ?mqs)
         (city ?city)
         (hood ?hood)
         (weather unknown))

  (city
   (handle ?city)
   (weather ?weather))
 =>
  (modify ?h (weather ?weather)))

(defrule ANSWERS::generate-pitches-by-price
  (declare (salience 1))
  (house
   (id ?id)
   (price ?price))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-price $?by-price))

  (attr
   (name house-price)
   (value ?red))

  (attr
   (name house-negotiableness)
   (cert ?negotiableness))

  (test (price-in-range ?red ?negotiableness ?price))
  (test (not (member$ ?id $?by-price)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-price: " ?by-price crlf)
                                (printout t "found eligible house by price: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-price ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by price: " ?new-eligibles crlf))
  (modify ?eligible
    (by-price ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-carboxmq
  (declare (salience 1))
  (house
   (id ?id)
   (carbox ?carbox)
   (carboxmq ?carboxmq))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-carboxmq $?by-carboxmq))

  (attr
   (name needs-carbox)
   (value y))

  (attr
   (name least-carboxmq)
   (value ?least-carboxmq)
   (cert ?least-cert))

  (attr
   (name most-carboxmq)
   (value ?most-carboxmq)
   (cert ?most-cert))

  (test (and
         (> ?most-cert 0.5)
         (> ?least-cert 0.5)
         (eq ?carbox TRUE)
         (>= ?most-carboxmq ?carboxmq)
         (<= ?least-carboxmq ?carboxmq)))
  (test (not (member$ ?id $?by-carboxmq)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-carboxmq: " ?by-carboxmq crlf)
                                (printout t "found eligible house by car box: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-carboxmq ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by carbox square meters: " ?new-eligibles crlf))
  (modify ?eligible
    (by-carboxmq ?new-eligibles)
    (treshold (- ?treshold 1))))

;; when the user has preference on mqs
(defrule ANSWERS::generate-pitches-by-mq-wpref
  (declare (salience 1))

  (house
   (id ?id)
   (mq ?mq))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-mq $?by-mq))

  (attr
   (name house-target-mq)
   (value ?target-mq)
   (cert ?target-cert))

  (test (and
         (>= ?mq (- ?mq (* ?mq (- 1 ?target-cert))))
         (<= ?mq (+ ?mq (* ?mq (- 1 ?target-cert))))))
  (test (not (member$ ?id $?by-mq)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-mq: " ?by-mq crlf)
                                (printout t "found eligible house by square meters: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-mq ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by square meters: " ?new-eligibles crlf))
  (modify ?eligible
    (by-mq ?new-eligibles)
    (treshold (- ?treshold 1))))

;; when the user hasn't any preference on mqs
(defrule ANSWERS::generate-pitches-by-mq
  (declare (salience 1))
  (house
   (id ?id)
   (mq ?mq))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-mq $?by-mq))

  (attr
   (name least-mq)
   (value ?least-mq)
   (cert ?least-cert))

  (attr
   (name most-mq)
   (value ?most-mq)
   (cert ?most-cert))

  (test (and
         (> ?most-cert 0.5)
         (> ?least-cert 0.5)
         (>= ?most-mq ?mq)
         (<= ?least-mq ?mq)))
  (test (not (member$ ?id $?by-mq)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-mq: " ?by-mq crlf)
                                (printout t "found eligible house by square meters: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-mq ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by square meters: " ?new-eligibles crlf))
  (modify ?eligible
    (by-mq ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-city
  (declare (salience 1))
  (house
   (id ?id)
   (city ?city))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-city $?by-city))

  (attr
   (name work-location)
   (value ?work-location))

  (attr
   (name remote-worker)
   (value n))

  (test (eq ?city ?work-location))
  (test (not (member$ ?id $?by-city)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-city: " ?by-city crlf)
                                (printout t "found eligible house by city: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-city ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by city: " ?new-eligibles crlf))
  (modify ?eligible
    (by-city ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-remote-work
  (declare (salience 1))
  (house
   (id ?id)
   (internet-rank ?internet-rank))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-netrank $?by-netrank))

  (attr
   (name remote-worker)
   (value y)
   (cert ?c))

  (test (>= (/ ?internet-rank 5) (- 1 ?c)))
  (test (not (member$ ?id $?by-netrank)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-netrank (remote work): " ?by-netrank crlf)
                                (printout t "found eligible house by city (remote work): " ?id crlf))
  (bind ?new-eligibles (create$ $?by-netrank ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by remote work & location: " ?new-eligibles crlf))
  (modify ?eligible
    (by-netrank ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-nrooms
  (declare (salience 1))
  (house
   (id ?id)
   (nrooms ?nrooms))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-nrooms $?by-nrooms))

  (attr
   (name least-nrooms)
   (value ?least-nrooms)
   (cert ?least-cert))

  (attr
   (name most-nrooms)
   (value ?most-nrooms)
   (cert ?most-cert))

  (test (and
         (> ?most-cert 0.5)
         (> ?least-cert 0.5)
         (>= ?most-nrooms ?nrooms)
         (<= ?least-nrooms ?nrooms)))
  (test (not (member$ ?id $?by-nrooms)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-nrooms: " ?by-nrooms crlf)
                                (printout t "found eligible house by #rooms: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-nrooms ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by #rooms: " ?new-eligibles crlf))
  (modify ?eligible
    (by-nrooms ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-ntoilettes
  (declare (salience 1))
  (house
   (id ?id)
   (ntoilettes ?ntoilettes))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-ntoilettes $?by-ntoilettes))

  (attr
   (name least-ntoilettes)
   (value ?least-ntoilettes)
   (cert ?least-cert))

  (attr
   (name most-ntoilettes)
   (value ?most-ntoilettes)
   (cert ?most-cert))

  (test (and
         (> ?most-cert 0.5)
         (> ?least-cert 0.5)
         (>= ?most-ntoilettes ?ntoilettes)
         (<= ?least-ntoilettes ?ntoilettes)))
  (test (not (member$ ?id $?by-ntoilettes)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-ntoilettes: " ?by-ntoilettes crlf)
                                (printout t "found eligible house by #toilettes: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-ntoilettes ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by #toilettes: " ?new-eligibles crlf))
  (modify ?eligible
    (by-ntoilettes ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-nlevels
  (declare (salience 1))
  (house
   (id ?id)
   (nlevels ?nlevels))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-nlevels $?by-nlevels))

  (attr
   (name least-nlevels)
   (value ?least-nlevels)
   (cert ?least-cert))

  (attr
   (name most-nlevels)
   (value ?most-nlevels)
   (cert ?most-cert))

  (test (and
         (> ?most-cert 0.5)
         (> ?least-cert 0.5)
         (>= ?most-nlevels ?nlevels)
         (<= ?least-nlevels ?nlevels)))
  (test (not (member$ ?id $?by-nlevels)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-nlevels: " ?by-nlevels crlf)
                                (printout t "found eligible house by #levels: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-nlevels ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by #levels: " ?new-eligibles crlf))
  (modify ?eligible
    (by-nlevels ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-elevator
  (declare (salience 1))
  (house
   (id ?id)
   (elevator TRUE))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-elevator $?by-elevator))

  (attr
   (name needs-elevator)
   (value y)
   (cert ?c))

  (test (> ?c 0.5))
  (test (not (member$ ?id $?by-elevator)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-elevator: " ?by-elevator crlf)
                                (printout t "found eligible house by elevator: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-elevator ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by elevator: " ?new-eligibles crlf))
  (modify ?eligible
    (by-elevator ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-renewables
  (declare (salience 1))
  (house
   (id ?id)
   (renewables TRUE))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-renewables $?by-renewables))

  (attr
   (name personal-ambientalist)
   (cert ?c))

  (test (> ?c 0.5))
  (test (not (member$ ?id $?by-renewables)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-renewables: " ?by-renewables crlf)
                                (printout t "found eligible house by renewables: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-renewables ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by renewables: " ?new-eligibles crlf))
  (modify ?eligible
    (by-renewables ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-furniture
  (declare (salience 1))
  (house
   (id ?id)
   (furnished TRUE))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-furniture $?by-furniture))

  (attr
   (name personal-diy)
   (cert ?c))

  (test (< ?c 0.5))
  (test (not (member$ ?id $?by-furniture)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-furniture: " ?by-furniture crlf)
                                (printout t "found eligible house by furniture: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-furniture ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by furniture: " ?new-eligibles crlf))
  (modify ?eligible
    (by-furniture ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-fixtrank
  (declare (salience 1))
  (house
   (id ?id)
   (weather ?weather)
   ;;  (zone ?zone)
   ;;  (hood ?hood)
   (fixtures-rank ?fixt-rank))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-fixtures $?by-fixtures))

  (attr
   (name personal-weather)
   (value ?v)
   (cert ?c))

  (test (and
         (> ?fixt-rank (- 5 ?v))
         (eq (weather-by-index ?v) ?weather)))
  (test (not (member$ ?id $?by-fixtures)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-fixtures: " $?by-fixtures crlf)
                                (printout t "found eligible house by fixtures: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-fixtures ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by fixtures: " ?new-eligibles crlf))
  (modify ?eligible
    (by-fixtures ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-previoushouse
  (declare (salience 1))
  (house
   (id ?id)
   (zone ?zone))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-zone $?by-zone))

  (attr
   (name target-zone)
   (value ?zone)
   (cert ?c))

  (test (> ?c 0.5))
  (test (not (member$ ?id $?by-zone)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-zone: " $?by-zone crlf)
                                (printout t "found eligible house by previous house: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-zone ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by previous house: " ?new-eligibles crlf))
  (modify ?eligible
    (by-zone ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-cityk
  (declare (salience 1))
  (house
   (id ?id)
   (city ?city))

  (city
   (handle ?city)
   (kind ?kind))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-cityk $?by-cityk))

  (attr
   (name target-kind)
   (value ?kind)
   (cert ?c))

  (test (> ?c 0.5))
  (test (not (member$ ?id $?by-cityk)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-cityk: " $?by-cityk crlf)
                                (printout t "found eligible house by city kind: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-cityk ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by city kind: " ?new-eligibles crlf))
  (modify ?eligible
    (by-cityk ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-nightlife
  (declare (salience 1))

  (house
   (id ?id)
   (nearest-club ?club-km &: (> ?club-km 0)))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-nightlife $?by-nightlife &:(not (member$ ?id $?by-nightlife))))

  (attr (name near-unit)
        (value ?nunit))

  (attr
   (name personal-nightlife)
   (value ?nl-enjoyment &:(> ?nl-enjoyment 0))
   (cert ?nl-importance))

  (test (<= ?club-km (* ?nl-enjoyment ?nunit)))
 =>
  (if (member$ log $?options) then
                                (printout t "Personal Nightlife Enjoyment: " ?nl-enjoyment " imp: " ?nl-importance crlf)
                                (printout t "check by-nightlife: " $?by-nightlife crlf)
                                (printout t "found eligible house by night life: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-nightlife ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by night life: " ?new-eligibles crlf))
  (modify ?eligible
    (by-nightlife ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-schools
  (declare (salience 1))

  (house
   (id ?id)
   (nearest-school ?school-km &: (> ?school-km 0)))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-schools $?by-schools &:(not (member$ ?id $?by-schools))))

  (attr (name near-unit)
        (value ?nunit))

  (attr
   (name family-students)
   (value y))

  (test (<= ?school-km (* 2 ?nunit)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-schools: " $?by-schools crlf)
                                (printout t "found eligible house by schools: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-schools ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by schools: " ?new-eligibles crlf))
  (modify ?eligible
    (by-schools ?new-eligibles)
    (treshold (- ?treshold 1))))

(defrule ANSWERS::generate-pitches-by-elderly
  (declare (salience 1))

  (house
   (id ?id)
   (nearest-phisician ?phisician-km &: (> ?phisician-km 0)))

  (options $?options)

  ?eligible <- (eligible
                (id 1)
                (treshold ?treshold)
                (by-elderly $?by-elderly &:(not (member$ ?id $?by-elderly))))

  (attr (name near-unit)
        (value ?nunit))

  (attr
   (name family-elderly)
   (value y))

  (test (<= ?phisician-km (* 2 ?nunit)))
 =>
  (if (member$ log $?options) then
                                (printout t "check by-elderly: " $?by-elderly crlf)
                                (printout t "found eligible house by elderly: " ?id crlf))
  (bind ?new-eligibles (create$ $?by-elderly ?id))
  (if (member$ log $?options) then
                                (printout t "eligible houses by elderly: " ?new-eligibles crlf))
  (modify ?eligible
    (by-elderly ?new-eligibles)
    (treshold (- ?treshold 1))))

(deffunction house> (?h ?h1)
  (> (fact-slot-value ?h score) (fact-slot-value ?h1 score)))

(defrule ANSWERS::anew-round
  ?r <- (round ?round &:(< ?round 3))

  (lock
   (id 1)
   (turn FALSE))

  (round-houses-scored FALSE)
  ?incremented <- (round-incremented FALSE)
 =>
  (retract ?r ?incremented)
  (assert (round (+ ?round 1)) (round-incremented TRUE))
)

(defrule ANSWERS::no-more-scoring
  ?r <- (round ?curr-round)
  (round-incremented TRUE)
  ?scored <- (round-houses-scored FALSE)
  ;; Check that there aren't anymore houses to score for the current round
  (not
   (house
    (scoring-round ?round &:(neq ?round ?curr-round))))

  ?kf <- (known-feats $?feats)
 =>
  (retract ?scored ?kf)
  (assert (round-houses-scored TRUE) (known-feats ))
)

(deffunction intersection
  "determine set intersection"
  (?set1 ?set2)
  (bind ?res (create$ ))
  (foreach ?s ?set2
    (printout t ?s crlf)
    (if (member$ ?s ?set1) then
                             (bind ?res (insert$ ?res 1 ?s))))
  ;; (printout t "intersection -- s1: " ?set1 "; set2: " ?set2 "; res: " ?res crlf)
  (return ?res))

(deffunction union
  "union of 2 sets"
  (?set1 ?set2)
  (bind ?res ?set1)
  (foreach ?s ?set2
    (if (not (member$ ?s ?res)) then
                                  (bind ?res (insert$ ?res 1 ?s))))
  ;; (printout t "union -- s1: " ?set1 "; set2: " ?set2 "; res: " ?res crlf)
  (return ?res))

(deffunction is-same-set
  "eq between sets"
  (?set1 ?set2)
  (bind ?res TRUE)
  (foreach ?s ?set1
    (bind ?res (and ?res (member$ ?s ?set2))))
  (foreach ?s ?set2
    (bind ?res (and ?res (member$ ?s ?set1))))
  (return ?res))

(deffunction is-subset
  "is ?set1 subset of ?set2?"
  (?set1 ?set2)
  (bind ?res TRUE)
  (foreach ?s ?set1
    (bind ?res (and ?res (member$ ?s ?set2))))
  (return ?res))

(defrule ANSWERS::determine-divisor
  (declare (salience 1))
  ?kf <- (known-feats $?f)

  (question
   (already-asked TRUE)
   (features $?feats &:(not (is-subset $?feats $?f))))
 =>
  (retract ?kf)
  (assert (known-feats (union $?f $?feats))))

(defrule ANSWERS::reset-scored
  ?asked <- (round-houses-scored TRUE)
  ?incremented <- (round-incremented TRUE)

  ?lock <- (lock
            (id 1)
            (turn FALSE))

  (test (shall-continue))
 =>
  (retract ?asked ?incremented)
  (assert (round-houses-scored FALSE) (round-incremented FALSE))
  (modify ?lock (turn TRUE))
  (focus QUESTIONS SELECTION ANSWERS))

(defrule ANSWERS::score-house
  (round ?round)
  (round-incremented TRUE)
  (round-houses-scored FALSE)

  ?h <- (house
         (id ?id)
         (scoring-round ?r &:(eq ?r (- ?round 1))))

  ?eligibles <- (eligible (id 1))

  ?importances <- (importance (id 1))

  (known-feats $?new-feats &:(> (length$ $?new-feats) 0))
 =>
  (evaluate-house ?h ?eligibles ?importances $?new-feats))
