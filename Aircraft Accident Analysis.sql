--This project employs data from: https://www.ntsb.gov/safety/data/Pages/Data_Stats.aspx
--Utilizing SQL to transform and organize data, no prior cleaning performed(removing NULLS) prior to importing the datasets. 
--Aircraft damage and condition
SELECT 
	a.ev_id,
	a.damage,
	a.acft_fire,
	a.acft_expl
FROM aircraft AS a;

--Counting aircraft damage grouped by damage type and excluding the nulls
SELECT 
	a.damage,
	COUNT(a.damage) AS damage_type_count
FROM aircraft AS a
WHERE a.damage IS NOT NULL
GROUP BY a.damage;

--Damage count per aircraft make
SELECT
	a.acft_make,
	SUM(CASE WHEN a.damage = 'MINR' THEN 1 ELSE 0 END) AS minor,
	SUM(CASE WHEN a.damage = 'SUBS' THEN 1 ELSE 0 END) AS substantial,
	SUM(CASE WHEN a.damage = 'DEST' THEN 1 ELSE 0 END) AS destroyed,
	SUM(CASE WHEN a.damage IS NOT NULL then 1 ELSE 0 END) AS total_damage_count
FROM dbo.aircraft AS a
GROUP BY a.acft_make
ORDER BY total_damage_count DESC;


--Accident related aircraft make count in descending order
SELECT 
    a.acft_make,
    COUNT(*) AS make_count
FROM dbo.aircraft AS a
WHERE a.acft_make IS NOT NULL
GROUP BY a.acft_make
ORDER BY make_count DESC;

--Accident related aircraft model count in descending order
SELECT
    MAX(a.acft_make) ASacft_make,   
    a.acft_model,
    COUNT(a.acft_model) AS model_count
FROM dbo.aircraft AS a
WHERE a.acft_model IS NOT NULL
GROUP BY a.acft_model
ORDER BY model_count DESC;

--Model count with damage count. This helps us identify which models have the most accidents.
SELECT
	MAX(a.acft_make) AS acft_make,
	a.acft_model,
	COUNT(a.acft_model) AS model_count,
	SUM(CASE WHEN a.damage = 'MINR' THEN 1 ELSE 0 END) AS minor_damage,
	SUM(CASE WHEN a.damage = 'SUBS' THEN 1 ELSE 0 END) AS substantial_damage,
	SUM(CASE WHEN a.damage = 'DEST' THEN 1 ELSE 0 END) AS destroyed,
	SUM(CASE WHEN a.damage IS NOT NULL THEN 1 ELSE 0 END) AS total_damage
FROM dbo.aircraft AS a
WHERE a.acft_model IS NOT NULL
GROUP BY acft_model
ORDER BY model_count DESC;

--Analysis of flight phases linked to aircraft damage
SELECT 
	a.acft_make,
	es.ev_id,
	es.phase_no
FROM dbo.Events_Sequence AS es
	JOIN dbo.aircraft as a
	ON es.ev_id = a.ev_id

--extracing phase of flight from the dictionary
SELECT
    d.[Column] AS code_type,
    d.code_iaids AS code,
    d.meaning
FROM dbo.eADMSPUB_DataDictionary AS d
WHERE 
    (
        d.[Column] = N'Occurrence_Code' 
        AND d.code_iaids LIKE N'%xxx'      -- only grab the xxx codes
    )
    OR d.[Column] = N'Phase_of_Flight'     -- include all Phase_of_Flight codes
    AND d.code_iaids IS NOT NULL
ORDER BY code_type, code;

--now lets try linking witht he events

--Adding flight phase for later. We want to figure out which flight phase has the most events. This can help us identify common issues as well.
--Sentiment analysis will provide clues on common causes of damages. 
--Map of events can help provide areas that are prone to aviation accidents or mishaps. 


--Review later
SELECT 
    a.damage,
    d.meaning AS phase_of_flight,
    COUNT(*) AS damage_count
FROM dbo.Events_Sequence AS es
JOIN dbo.aircraft AS a
    ON es.ev_id = a.ev_id
JOIN dbo.eADMSPUB_DataDictionary AS d
    ON d.code_iaids = es.phase_no
    AND d.[Column] = N'Phase_of_Flight'
WHERE a.damage IS NOT NULL
GROUP BY a.damage, d.meaning
ORDER BY d.meaning, damage_count DESC;
