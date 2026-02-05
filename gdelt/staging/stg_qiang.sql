{{ config(materialized='table') }}
SELECT
STR_TO_DATE(LEFT(`datetime`, 19), '%Y-%m-%d %H:%i:%s') AS datetime,
`Average Tone` AS average_tone,
entity
FROM `gdelt_db`.`gdelt`
WHERE entity = 'Li Qiang'