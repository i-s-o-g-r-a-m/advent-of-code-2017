module ProcessInput exposing (process)

import Debug exposing (..)
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
            ( state, curVal )
        else
            case instruct.operation of
                "inc" ->
                    let
                        newVal =
                            curVal + instruct.value
                    in
                        ( (Dict.insert instruct.register newVal state), newVal )

                "dec" ->
                    let
                        newVal =
                            curVal - instruct.value
                    in
                        ( (Dict.insert instruct.register newVal state), newVal )

                _ ->
                    ( state, 0 )


getCurrentMax dict =
    let
        r =
            Dict.foldl
                (\k v acc ->
                    if v > acc then
                        v
                    else
                        acc
                )
                0
                dict

        dbg =
            Debug.log "currentMax" r
    in
        r


process_ instructions state maxVal =
    case instructions of
        [] ->
            ( state, maxVal )

        head :: tail ->
            let
                ( newState, newVal ) =
                    (updateState head state)

                newMax =
                    if newVal > maxVal then
                        newVal
                    else
                        maxVal
            in
                process_ tail newState newMax


process : List String -> ( Int, Int )
process input =
    let
        instructions =
            List.map toRecord
                (List.map (\line -> split Regex.All (regex " ") line) input)

        ( result, maxVal ) =
            process_ instructions Dict.empty 0
    in
        ( (Dict.foldl
            (\k v acc ->
                if v > acc then
                    v
                else
                    acc
            )
            0
            result
          )
        , maxVal
        )
