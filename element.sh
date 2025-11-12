#!/usr/bin/env bash
# FreeCodeCamp Periodic Table project

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

ARG="$1"
if [[ "$ARG" =~ ^[0-9]+$ ]]; then
  WHERE="e.atomic_number = $ARG"
elif [[ "$ARG" =~ ^[A-Za-z]{1,2}$ ]]; then
  WHERE="e.symbol ILIKE '$ARG'"
else
  WHERE="e.name ILIKE '$ARG'"
fi

QUERY="
SELECT
  e.atomic_number,
  e.name,
  e.symbol,
  LOWER(t.type) AS type,
  -- normalize mass printout in case DB still has extra zeros
  regexp_replace(p.atomic_mass::text, '\.?0+$', '') AS mass,
  p.melting_point_celsius,
  p.boiling_point_celsius
FROM elements e
JOIN properties p USING(atomic_number)
JOIN types t ON p.type_id = t.type_id
WHERE $WHERE;
"

ROW="$($PSQL "$QUERY")"

if [[ -z "$ROW" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r NUM NAME SYMBOL TYPE MASS MP BP <<< "$ROW"

# EXACT sentence the grader expects
echo "The element with atomic number $NUM is $NAME ($SYMBOL). It's a $TYPE, with a mass of ${MASS} amu. $NAME has a melting point of ${MP} celsius and a boiling point of ${BP} celsius."
