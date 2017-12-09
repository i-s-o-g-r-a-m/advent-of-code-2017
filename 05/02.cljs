#!/usr/bin/env planck


(require '[clojure.string :as s])
(require '[planck.core :as c])


(def input
  (let [raw (c/slurp "input.txt")]
    (mapv js/parseInt (s/split-lines raw))))

(defn out-of-bounds
  [v idx]
  (or (< idx 0) (> (+ idx 1) (count v))))

(defn jump
  [v idx]
  (let
    [value (nth v idx)
     new-value (if (> value 2) (- value 1) (+ value 1))]
    {:v (assoc v idx new-value) :idx (+ idx value)}))

(defn start
  ([v] (start v 0 1))
  ([v idx iteration]
    (let
      [{new-idx :idx, new-v :v} (jump v idx)]
      (if
        (out-of-bounds v new-idx)
        iteration
        (recur new-v new-idx (+ iteration 1))))))


(def result (start input))
(println result)
(assert (= result 28178177))
