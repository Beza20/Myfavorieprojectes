#lang typed/racket
(require typed/test-engine/racket-tests)

(require "../include/cs151-core.rkt")
(require "../include/cs151-image.rkt")
(require "../include/cs151-universe.rkt")
(define-type (Option A)
  (U 'None (Some A)))

(define-struct (Some A)
  ([value : A]))

(define-struct Click
  ([displacement-horizontal : Integer]
   [displacement-vertical   : Integer]))

(define-struct Style
  ([text-area-width  : Integer]
   [text-area-height : Integer]
   [spacer-height    : Integer]
   [text-background-color : Image-Color]
   [spacer-color          : Image-Color]))

(define-type Label
  (U 'A 'B 'C 'D))

(define-struct QuizWorld
  ([mode : (U 'Welcome 'Quiz 'Done 'Review)]
   [style : Style]
   [title : String]
   [authors : String]
   [to-ask : Quiz]
   [asked : Quiz]
   [answers : Answers]
   [current-answer : (Option Label)]))

(define-struct SetQuestion
  ([question-text : String]
   [correct : String]
   [incorrect : (Listof String)]
   [source : String]))

(define-struct Question
  ([question-text : String]
   [choiceA : String]
   [choiceB : String]
   [choiceC : String]
   [choiceD : String]
   [correct-choice : Label]
   [source : String]))

(define-type Quiz
(Listof Question))

(define-type Answers
  (Listof Label))

;(: filtaration : String -> Boolean)
;(define (filtaration str)
;  (not (string=? str "")))
      
 
(: drop-tags : String -> String)
;; This function removes identifying tags used in the qzf or qzs file to 
;; differentiate between the questions, choices and source
(define (drop-tags filename)
  (cond
    [(string-contains? filename "**question ")
     (string-replace filename "**question " "")]
    [(string-contains? filename "**A ")
     (string-replace filename "**A " "")]
    [(string-contains? filename "**B ")
     (string-replace filename "**B " "")]
    [(string-contains? filename "**C ")
     (string-replace filename "**C " "")]
    [(string-contains? filename "**D ")
     (string-replace filename "**D " "")]
    [(string-contains? filename "**correct ")
     (string-replace filename "**correct " "")]
    [(string-contains? filename "**authors ")
     (string-replace filename "**authors " "")]
    [(string-contains? filename "**quiz ")
     (string-replace filename "**quiz " "")]
    [(string-contains? filename "**source ")
     (string-replace filename "**source " "")]
    [(string-contains? filename "**incorrect ")
     (string-replace filename "**incorrect " "")]
    [else (error "no tags")]))

(check-expect (drop-tags "**question ") "")
(check-expect (drop-tags "**source ") "")
(check-error (drop-tags "abc") "no tags")

(: check-tag : String String Integer -> Boolean)
;;this function checks if the element of the list of strings is a question
;;a choice or a correct answer to make the list of question struct
(define (check-tag filname str int)
  (string-prefix? (list-ref (file->lines filname) int) str))

(check-expect (check-tag "wimbledon.qzf" "**question" 0) #f)
(check-expect (check-tag "wimbledon.qzf" "**question" 3) #t)
(check-expect (check-tag "wimbledon.qzf" "**A" 4) #t)

(: listof-tags : String String Integer -> (Listof String))
;;this function makes a list of string according to the prefix attached
(define (listof-tags str filname int)
  (cond
    [(>= int (length (file->lines filname))) '()]
    [(check-tag filname str int)(cons (list-ref (file->lines filname) int)
                              (listof-tags str filname (+ int 1)))]
    [else (listof-tags str filname (+ int 1))]))

(check-expect
 (listof-tags "**question" "wimbledon.qzf" 0)
 '("**question Who won the women's singles title at Wimbledon in 2019?"
   "**question Who won the men's singles title at Wimbledon in 2016?"
   "**question Who won the women's singles title at Wimbledon in 1988?"
   "**question Who won the men's singles title at Wimbledon in 1980?"))

(: turnlabel-tostring : Label -> String)
;; this function changes a label type to a string
(define (turnlabel-tostring lab)
  (match lab
    ['A "A"]
    ['B "B"]
    ['C "C"]
    ['D "D"]
    [_ (error "none")]))

(check-expect (turnlabel-tostring 'B) "B")
(check-expect (turnlabel-tostring 'C) "C")

(: labeling : String -> Label)
;;this function changes a tring into a Label-type 
(define (labeling str)
  (match str
    ["A" 'A]
    ["B" 'B]
    ["C" 'C]
    ["D" 'D]))

(check-expect (labeling "A") 'A)
(check-expect (labeling "D") 'D)


(: correct? : String Integer -> Boolean)
;;this fucntion checks if the element in the list of strings is the one
;;that tells us the correct answer
(define (correct? filename int)
  (string-prefix? (list-ref (file->lines filename) int) "**correct"))

(check-expect (correct? "wimbledon.qzf" 0) #f)
(check-expect (correct? "wimbledon.qzf" 8) #t)

(: listof-correct : String Integer -> (Listof Label))
;;this function makes a list of the label of all the correct answers 
;;in the file
(define (listof-correct str int)
  (cond
    [(>= int (length (file->lines str))) '()]
    [(and (string-contains? str ".qzf")(correct? str int))
     (cons (labeling (drop-tags(list-ref
                                                  (file->lines str) int)))
                             (listof-correct str (+ int 1)))]
    [else (listof-correct str (+ int 1))]))

(check-expect (listof-correct "wimbledon.qzf" 0)
              '(A C B A))
     
(: listofstringed-correct : String Integer ->(Listof String))
;;this function makes a list of the correct answers of all the questions
;;in the qzs file
(define (listofstringed-correct str int)
  (cond
    [(>= int (length (file->lines str))) '()]
    [(and (correct? str int)(string-contains? str ".qzs"))
        (cons (drop-tags (list-ref (file->lines str) int))
              (listofstringed-correct str (+ int 1)))]
       
    [else (listofstringed-correct str (+ int 1))]))

(check-expect (listofstringed-correct "Oscars.qzs" 0)
              '("The Shape of Water"
  "Gary Oldman, Darkest Hour"
  "Frances McDormand, Three Billboards Outside Ebbing, Missouri"
  "Sam Rockwell, Three Billboards Outside Ebbing, Missouri"
  "Allison Janney, I, Tonya"
  "Spotlight"
  "No Country for Old Men"))

(: listof-incorrects : String Integer -> (Listof String))
;;this function makes a list of all the incorrect options of one question
(define (listof-incorrects file n)
  (cond
    [(check-tag file "**source" n) '()]
    [(check-tag file "**incorrect"  n)
      (cons (drop-tags(list-ref (file->lines file) n))
            (listof-incorrects file (+ n 1)))]
     [else (listof-incorrects  file (+ 1 n))]))
(check-expect (listof-incorrects "Oscars.qzs" 0)
              '("Call Me by Your Name"
  "Darkest Hour"
  "Dunkirk"
  "Get Out"
  "Lady Bird"
  "Phantom Thread"
  "The Post"
  "Three Billboards Outside Ebbing, Missouri"))


(: listof-allincorrects : String Integer -> (Listof (Listof String)))
;; this function recursively calls on the previous function and makes a list of
;; all the incorrect answers 
(define (listof-allincorrects filename int)
  (cond
    [(<= (length (file->lines filename)) int) '()]
    [(check-tag filename "**question" int)
     (cons (listof-incorrects filename int)
           (listof-allincorrects filename (+ int 1)))]
    [else (listof-allincorrects filename (+ int 1))]))
(check-expect (listof-allincorrects "Oscars.qzs" 0)
              '(("Call Me by Your Name"
   "Darkest Hour"
   "Dunkirk"
   "Get Out"
   "Lady Bird"
   "Phantom Thread"
   "The Post"
   "Three Billboards Outside Ebbing, Missouri")
  ("Timothee Chalamet, Call Me by Your Name"
   "Daniel Day-Lewis, Phantom Thread"
   "Daniel Kaluuya, Get Out"
   "Denzel Washington, Roman J. Israel, Esq.")
  ("Sally Hawkins, The Shape of Water"
   "Margot Robbie, I, Tonya"
   "Saoirse Ronan, Lady Bird"
   "Meryl Streep, The Post")
  ("Willem Dafoe, The Florida Project"
   "Woody Harrelson, Three Billboards Outside Ebbing, Missouri"
   "Richard Jenkins, The Shape of Water"
   "Christopher Plummer, All the Money in the World")
  ("Mary J. Blige, Mudbound"
   "Lesley Manville, Phantom Thread"
   "Laurie Metcalf, Lady Bird"
   "Octavia Spencer, The Shape of Water")
  ("The Big Short"
   "Bridge of Spies"
   "Brooklyn"
   "Mad Max: Fury Road"
   "The Martian"
   "The Revenant"
   "Room")
  ("Atonement"
   "Juno"
   "Michael Clayton"
   "There Will Be Blood")))


(: build-setquestion : String Integer -> (Listof SetQuestion))
;; this makes a list of the SetQuestion struct 
(define (build-setquestion filename int)
  (cond
  [(>= int (length (listof-tags "**question" filename 0))) '()]
  [else
(cons
  (SetQuestion
   (drop-tags(list-ref (listof-tags "**question" filename 0) int))
   (drop-tags(list-ref (listof-tags "**correct" filename 0) int))
   (list-ref (listof-allincorrects filename 0) int)
   (drop-tags(list-ref(listof-tags "**source" filename 0) int)))
  (build-setquestion filename (+ int 1)))]))



(: listof-options : SetQuestion -> (Listof String))
;; this function takes 3 of the options from a shuffled list of incorrect
;;answers; this function cannot have a check-expect 
(define (listof-options sq)
 (take 3 (shuffle (SetQuestion-incorrect sq))))


(: listof-options# : SetQuestion -> (Listof String))
;;this function inserts the correct option and shuffles it again
;;this function checks 
(define (listof-options# sq)
  (shuffle (cons (SetQuestion-correct sq)(listof-options sq))))


(: question : String Integer -> Quiz)
;;this function builds a list of the question struct consisting of the question 
;;choices, the correct answer and source
;;check-expect cannot be wrriten for a qzs file
(define (question str int)   
  (cond
    [(>= int (length (listof-tags "**question" str 0))) '()]
    [(string-contains? str ".qzs")
     (local [(define ls (listof-options# (list-ref (build-setquestion str 0)
                                                   int)))
             (define xs (listofstringed-correct str 0))] 
       (cons (Question
              (drop-tags (list-ref (listof-tags "**question" str 0) int))
              (list-ref ls 0)
              (list-ref ls 1)
              (list-ref ls 2)
              (list-ref ls 3)
              (cond
                [(string=? (list-ref xs int)
                           (list-ref ls 0)) (labeling "A")]
                [(string=? (list-ref xs int)
                           (list-ref ls 1)) (labeling "B")]
                [(string=? (list-ref xs int)
                           (list-ref ls 2)) (labeling "C")]
                [(string=? (list-ref xs int)
                           (list-ref ls 3)) (labeling "D")]
                [else (error "not possible")])
              (list-ref (listof-tags "**source" str 0) int))
             (question str (+ int 1))))]        
    [else
     (cons (Question
            (drop-tags (list-ref (listof-tags "**question" str 0) int))
            (drop-tags (list-ref (listof-tags "**A" str 0) int))
            (drop-tags (list-ref (listof-tags "**B" str 0) int))
            (drop-tags (list-ref (listof-tags "**C" str 0) int))
            (drop-tags (list-ref (listof-tags "**D" str 0) int))
            (labeling (drop-tags (list-ref (listof-tags "**correct" str 0)
                                           int))) 
            (list-ref (listof-tags "**source" str 0) int))
           (question str (+ int 1)))]))

(: take : All (A) Int (Listof A) -> (Listof A))
;; take n items from the front of the list
;; this function was taken 
(define (take n xs)
  (cond
    [(and (zero? n) (empty? xs)) '()]
    [(and (zero? n) (cons? xs)) '()]
    [(and (positive? n) (empty? xs)) (error "empty")]
    [(and (positive? n) (cons? xs)) (cons (first xs) (take (sub1 n) (rest xs)))]
    [else (error "negative")]))

(check-expect (take 2 '(a b c d e)) '(a b))

(: asked-list : Quiz -> Quiz)
;; this function makes the list of the question already asked
(define (asked-list q)
  (take 1 q))

(: drop : All (A) Int (Listof A) -> (Listof A))
;; drop n items from the front of the list
;;this function was taken from notes on piazza
(define (drop n xs)
  (cond
    [(and (zero? n) (empty? xs)) '()]
    [(and (zero? n) (cons? xs)) xs]
    [(and (positive? n) (empty? xs)) (error "empty")]
    [(and (positive? n) (cons? xs)) (drop (sub1 n) (rest xs))]
    [else (error "negative")]))

(check-expect (drop 2 '(a b c d e)) '(c d e))

(: ask-list : Quiz -> Quiz)
;; this function updates the list of questions to be asked
(define (ask-list q)
  (drop 1 q))

(: between? : Int Int Int -> Bool)
;; test if first number is between the second two, inclusive
;; this function was taked from piazza
(define (between? n lower upper)
  (and (<= lower n) (<= n upper)))

(check-expect (between? 0 1 5) #f)
(check-expect (between? 1 1 5) #t)
(check-expect (between? 2 1 5) #t)
(check-expect (between? 5 1 5) #t)
(check-expect (between? 6 1 5) #f)

(: choice-clicked : Click Style -> (Option Label))
;; calculate the choice clicked upon, (Some 'A) through (Some 'D),
;; and return 'None if no choice is clicked upon
;; this function was taken from piazza
(define (choice-clicked c vs)
  (local
    {(: region->sym : Int -> Label)
     (define (region->sym r)
       (list-ref '(A B C D) r))}
  (match* (c vs)
    [((Click x y) (Style w h sp _ _))
     (local
       {(define region (quotient y (+ h sp)))}
       (if (and (<= 0 x w)
                (<= 1 region 4)
                (<= (remainder y (+ h sp)) h))
           (Some (region->sym (sub1 region)))
           'None))])))

(: turntolabel : Integer -> (Option Label))
;; this function changes an integer into an option label
(define (turntolabel n)
  (match n
    [1 (Some 'A)]
    [2 (Some 'B)]
    [3 (Some 'C)]
    [4 (Some 'D)]
    [_ 'None]))

(check-expect (turntolabel 1) (Some 'A))
(check-expect (turntolabel 5) 'None)

(: turn-to-string : (Option Label) -> String)
;;this function changes an option label to a string
(define (turn-to-string opt)
  (match opt
    [(Some 'A) "A"]
    [(Some 'B) "B"]
    [(Some 'C) "C"]
    [(Some 'D) "D"]
    [_ "None"]))

(check-expect (turn-to-string (Some 'A)) "A")

(: turnstring-tolabel : String -> Label)
;;this function changes string to label
(define (turnstring-tolabel str)
  (match str
    ["A" 'A]
    ["B" 'B]
    ["C" 'C]
    ["D" 'D]
    [_ (error "none")]))

(check-expect (turnstring-tolabel "A") 'A)

  
(: num : String String -> String)
;; create a numbered (**letterd) string
;; ex: (num 2 "apple") --> "2. apple")
;;this function was taken from piazza and adjusted

(define (num i s)
  (cat i ". " s))

(check-expect (num "A" "hello")  "A. hello")
(check-expect (num "B" "purple") "B. purple")

;; ================================ std-text
;
(: std-text : String -> Image)
;; draw text font size 16 and black
;; this function was taken from piazza
(define (std-text s)
  (text s 16 "black"))

(: sym : Symbol String -> String)
;; create a labeled string
;; ex: (sym 'A "apple") --> "A) apple")
;; this function was taken from piazza
(define (sym s choice)
  (cat (sym$ s) ") " choice))

(check-expect (sym 'A "hello")  "A) hello")
(check-expect (sym 'D "purple") "D) purple")

(: duplicate-beside : Integer Image -> Image)
;; given: number of duplicates, image to duplicate
;; This function displays an image that duplicated to the number of times given
;; taken from hw3

(define (duplicate-beside int img)
  (cond
    [(<= int 0) empty-image]
    [else (beside img (duplicate-beside (- int 1) img))]))

(: progress-bar : QuizWorld -> Image)
;; this function produces an image using the above function according to the
;; number of questions and the number of questions already asked
(define (progress-bar qw)
  (match qw
    [(QuizWorld _ styl _ _ to-ask asked _ _)
     (match styl
       [(Style w h sp text-bg sp-bg)
        (local [(define width (/ w (+ (length to-ask) (length asked))))]
  (beside 
          (duplicate-beside (length asked)
                                     (frame(rectangle width h 'solid 'blue)))
          (duplicate-beside (length to-ask)
                    (rectangle width h 'outline 'black))))]
    [_ empty-image])]
     [_ empty-image]))

(: display-question : Style Question QuizWorld -> Image)
;; display multiple choice question with given style
;; and puts up a frame around it when the mouse event later on
;; hovers over it and also changes the progress bar according to
;; the number of questions the user is on at the moment

(define (display-question style mc qw)
  (match style
    [(Style w h sp text-bg spc-bg)
     (match mc
       [(Question q chA chB chC chD _ _)
        (local
          {(define spacer (rectangle w sp "solid" spc-bg))
           (define text-area (rectangle w h "solid" text-bg))}
        (match qw
          [(QuizWorld 'Quiz sty tit auth to ad ans CuAnsw) 
          (above (overlay (std-text q) text-area)
                 spacer
                 (cond
                   [(string=? (turn-to-string CuAnsw) "A")
                    (frame(overlay (std-text (sym 'A chA)) text-area))]
                    [else (overlay (std-text (sym 'A chA)) text-area)])
                 spacer
                 (cond
                   [(string=? (turn-to-string CuAnsw) "B")
                    (frame (overlay (std-text (sym 'B chB)) text-area))]
                    [else (overlay (std-text (sym 'B chB)) text-area)])
                 spacer
                 (cond
                   [(string=? (turn-to-string CuAnsw) "C")
                    (frame (overlay (std-text (sym 'C chC)) text-area))]
                    [else (overlay (std-text (sym 'C chC)) text-area)])
                 spacer
                 (cond
                   [(string=?  (turn-to-string CuAnsw) "D")
                    (frame (overlay (std-text (sym 'D chD)) text-area))]
                    [else (overlay (std-text (sym 'D chD)) text-area)])
                 spacer
                 (progress-bar qw))]))])]))

(: num-correct : QuizWorld -> Int)
;; compute the number of correct answers
;; this function was taken from piazza 
(define (num-correct qw)
  (match qw
    [(QuizWorld _ _ _ _ _ asked ans _)
     (local
       {(: lp : Quiz (Listof Label) -> Int)
        (define (lp asked ans)
          (match* (asked ans)
            [('() '()) 0]
            [((cons (Question _ _ _ _ _ correct _) tail1) (cons head2 tail2))
             (if (symbol=? correct head2)
                 (add1 (lp tail1 tail2))
                 (lp tail1 tail2))]
            [(_ _) (error "length mismatch")]))}
       (lp asked ans))]))

(: num-correct-review : QuizWorld -> Int)
;; this function allows the number of correct answers to be calculated
;; from the to-ask list
(define (num-correct-review qw)
  (match qw
    [(QuizWorld _ _ _ _ task _ ans _)
     (local
       {(: lp : Quiz (Listof Label) -> Int)
        (define (lp task ans)
          (match* (task ans)
            [('() '()) 0]
            [((cons (Question _ _ _ _ _ correct _) tail1) (cons head2 tail2))
             (if (symbol=? correct head2)
                 (add1 (lp tail1 tail2))
                 (lp tail1 tail2))]
            [(_ _) (error "length mismatch")]))}
       (lp task ans))]))


(: review-image : Question QuizWorld -> Image)
;; draws the image when the world is in the review mode
;; to indicate what the correct answer is and what the user answered
;; a frame is drawn arround the correct answer and a text indicates what the
;; user answered

(define (review-image mc qw)
  (match qw
   [(QuizWorld _ style _ _ _ _ answ ca) 
  (match* (style answ)
    [( (Style w h sp text-bg spc-bg) (cons head tail))
     (match mc
       [(Question q chA chB chC chD cc _)
        (local
          {(define spacer (rectangle w sp "solid" spc-bg))
           (define text-area (rectangle w h "solid" text-bg))
           (define correct-text-area (rectangle w h 'solid 'green))}
          (above (above (overlay (std-text q) text-area)
                 spacer
                 (cond
                   [(symbol=? cc 'A)
                 (frame(overlay (std-text (sym 'A chA)) correct-text-area))]
                 [else (overlay (std-text (sym 'A chA)) text-area)])
                 
                 spacer
                 (cond
                   [(symbol=? cc 'B)
                (frame (overlay (std-text (sym 'B chB)) correct-text-area))]
                 [else(overlay (std-text (sym 'B chB)) text-area)])
                 spacer
                 (cond
                   [(symbol=? cc 'C)
                (frame (overlay (std-text (sym 'C chC)) correct-text-area))]
                 [else(overlay (std-text (sym 'C chC)) text-area)])
                 spacer
           
                 (cond
                   [(symbol=? cc 'D)
                (frame (overlay (std-text (sym 'D chD)) correct-text-area))]
                 [else(overlay (std-text (sym 'D chD)) text-area)]))
                 (progress-bar qw)
                 (square 10 'solid 'white)
                 (text (cat "You Selected " (turnlabel-tostring (last answ))
                " and the correct answer is " (turnlabel-tostring cc))
                       20 'black)))])])]
  [_ (error "not in review mode")]))

(: appendlast-tobeginning : (Listof Label) -> (Listof Label))
;; moves the last element in a list to the front of the list
;; without losing any elements of the list
(define (appendlast-tobeginning answ)
  (cons (last answ) (take (- (length answ) 1) answ )))

(check-expect (appendlast-tobeginning '(A B C D)) '(D A B C))
(check-expect (appendlast-tobeginning '(D A C B)) '(B D A C))

   
(: draw : QuizWorld -> Image)
;; draws the world according the mode and mouse events
(define (draw qw)
  (match qw
    [(QuizWorld 'Welcome styl ttle auth task asked answ curansw)
     (overlay
      (above (text "Hello! Couterite, let's play." 20 'black  )
             (text ttle 20 'black)
             (text auth 20 'black))
      (rectangle (Style-text-area-width styl)
                 (+ 120 (* 5 (Style-text-area-height styl))
                    (* 4 (Style-spacer-height styl))) 'solid 'white))]

    [(QuizWorld 'Quiz styl ttle auth (cons q r) asked answ curansw)
     (overlay/align "left" "top"
                    (above (display-question styl q qw)
                           (text (string-append "Current Answer Choice: "
                                                (match curansw
                                                  ['None "None"]
                                                  [_ (turn-to-string curansw)]))
                                 20 'black))     
                    (rectangle (Style-text-area-width styl)
                               (+ 120 (* 5 (Style-text-area-height styl))
                                  (* 5 (Style-spacer-height styl))) 'solid
                                                                    'white))]
     
    [(QuizWorld 'Done styl ttle auth task asked answ curansw)
     (overlay
      (above (above (text "Thank You For Playing!" 20 'black)
                    (text
                     (string-append
                      (num$ (if (empty? asked) (num-correct-review qw)
                                (num-correct qw)))" Out of "
                                            (num$ (length answ))) 20 'black)) 
             (text "Click to Review" 20 'black))
      (rectangle (Style-text-area-width styl)
                 (+ 120 (* 5 (Style-text-area-height styl))
                    (* 5 (Style-spacer-height styl))) 'solid 'white))]

    [(QuizWorld 'Review styl ttle auth (cons q r) asked (cons h t) curansw)
     (review-image q qw)]                     

    [_ (overlay (text "Something went Wrong" 20 'black)
                (rectangle 200 200 'solid 'white))]))

(: react-to-mouse : QuizWorld Integer Integer Mouse-Event -> QuizWorld)
;; this function produces images in the world according to the mouse events
;; when mouse hovers over the options a frames is made around the option
;; rectangles and when it runs out of questions moves to the done mode
;; and then when clicked it goes to review mode and infinitely goes through
;; review mode

(define (react-to-mouse qw x y me)
     (match qw
       [(QuizWorld 'Welcome styl ttle auth task asked answ 'None)
       (match me
         ["button-down"
        (QuizWorld 'Quiz styl ttle auth task asked answ 'None)]
         [_ qw])]
       
       [(QuizWorld 'Quiz styl ttle auth (cons q r) asked answ curansw)
        (match me
          ["button-down"
        (match curansw
          ['None qw]
          [(Some label)
      (QuizWorld (if (empty? r) 'Done 'Quiz)
       styl ttle auth r (cons q asked) (cons label answ) 'None )])]
                
        ["move"
     (QuizWorld 'Quiz styl ttle auth (cons q r) asked answ 
                                          (choice-clicked (Click x y) styl))]
          [_ qw])]

       [(QuizWorld 'Done styl ttle auth task asked answ c-ans)
        (match me
          ["button-down"
          (QuizWorld 'Review styl ttle auth (reverse asked) task  answ c-ans)]
          ["move"
           (QuizWorld 'Done styl ttle auth task asked answ c-ans)]
          [_ qw])]

       [(QuizWorld 'Review styl ttle auth (cons q r) asked answ c-ans)
        (match me
          ["button-down"
           (QuizWorld (if (empty? r) 'Done 'Review) styl ttle auth r
                      (cons q asked) (appendlast-tobeginning answ) c-ans)]
          ["move"
           (QuizWorld 'Review styl ttle auth (cons q r) asked answ c-ans)]
          [_ qw])]

       [_ qw]))

(: run : Style String -> QuizWorld)
;;this function finally creates the world of the trivia
(define (run sty str)
  (big-bang (QuizWorld 'Welcome sty (drop-tags (list-ref (file->lines str) 0))
                       (drop-tags (list-ref (file->lines str) 1))
                       (shuffle (question str 0)) '()
                       '() 'None) : QuizWorld
    [to-draw draw]
    [on-mouse react-to-mouse]))
(run (Style 500 40 30 'blue 'white) "coulter.qzf")
;;ideas were exchanged with multiple students when writing this code
(test)

