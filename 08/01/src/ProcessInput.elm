module ProcessInput exposing (process)

import Dict exposing (empty, update, insert)
import Regex exposing (regex, split)
import Maybe exposing (withDefault)


toRecord vals =
    { register = withDefault "" (List.head vals)
    , operation = withDefault "" (List.head (List.reverse (List.take 2 vals)))
    , value =
        withDefault "" (List.head (List.reverse (List.take 3 vals)))
            |> String.toInt
            |> Result.withDefault 0
    , condRegister = withDefault "" (List.head (List.reverse (List.take 5 vals)))
    , condOperation = withDefault "" (List.head (List.reverse (List.take 6 vals)))
    , condValue =
        (withDefault "" (List.head (List.reverse (List.take 7 vals))))
            |> String.toInt
            |> Result.withDefault 0
    }


lookup key dict =
    withDefault 0 (Dict.get key dict)


evalCond leftOperand op rightOperand =
    case op of
        "==" ->
            leftOperand == rightOperand

        "!=" ->
            leftOperand /= rightOperand

        ">=" ->
            leftOperand >= rightOperand

        "<=" ->
            leftOperand <= rightOperand

        "<" ->
            leftOperand < rightOperand

        ">" ->
            leftOperand > rightOperand

        _ ->
            True


updateState instruct state =
    let
        condVal =
            lookup instruct.condRegister state

        cond =
            evalCond condVal instruct.condOperation instruct.condValue

        curVal =
            lookup instruct.register state
    in
        if not cond then
            state
        else
            case instruct.operation of
                "inc" ->
                    Dict.insert instruct.register (curVal + instruct.value) state

                "dec" ->
                    Dict.insert instruct.register (curVal - instruct.value) state

                _ ->
                    state


process_ instructions state =
    case instructions of
        [] ->
            state

        head :: tail ->
            process_ tail (updateState head state)


process : List String -> Int
process input =
    let
        instructions =
            List.map toRecord
                (List.map (\line -> split Regex.All (regex " ") line) input)

        result =
            process_ instructions Dict.empty
    in
        Dict.foldl
            (\k v acc ->
                if v > acc then
                    v
                else
                    acc
            )
            0
            result
