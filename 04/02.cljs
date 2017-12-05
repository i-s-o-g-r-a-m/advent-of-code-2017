#!/usr/bin/env planck


(require '[clojure.string :as s])
(require '[planck.core :as c])


(def lines
  (let [raw (c/slurp "input.txt")]
    (s/split-lines raw)))

(defn lexsorted [words]
  (map #(apply str (sort %1)) words))

(defn no-anagrams [line]
  (let [words (s/split line " ")]
    (= (count words) (count (distinct (lexsorted words))))))

(def result (count (filter no-anagrams lines)))
(println result)
(assert (= result 231))
