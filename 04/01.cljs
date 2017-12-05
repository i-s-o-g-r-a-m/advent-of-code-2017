#!/usr/bin/env planck


(require '[clojure.string :as s])
(require '[planck.core :as c])


(def lines
  (let [raw (c/slurp "input.txt")]
    (s/split-lines raw)))

(defn no-dupe-words [line]
  (let [words (s/split line " ")]
    (= (count words) (count (distinct words)))))

(def result (count (filter no-dupe-words lines)))
(println result)
(assert (= result 337))
