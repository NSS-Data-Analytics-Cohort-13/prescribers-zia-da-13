SELECT * 
FROM cbsa;
SELECT * 
FROM drug;
SELECT * 
FROM fips_county;
SELECT * 
FROM overdose_deaths;
SELECT * 
FROM population;
SELECT * 
FROM prescriber;
SELECT * 
FROM prescription;
SELECT * 
FROM zip_fips;


-- 1. 
    -- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims?

	SELECT Prescriber.npi,
	SUM(prescription.total_claim_count) AS total_claims
	FROM prescriber AS prescriber 
	INNER JOIN prescription AS prescription 
	ON prescriber.npi = prescription.npi
	GROUP BY prescriber.npi
	ORDER BY total_claims DESC
	LIMIT 1;


	SELECT npi,
	 SUM(total_claim_count) AS total_claims 
	 FROM prescription 
	 GROUP BY npi
	 ORDER BY total_claims DESC;
	 

  -- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

  SELECT Prescriber.npi,
         prescriber.nppes_provider_first_name,
		 prescriber.nppes_provider_last_org_name,
		 prescriber.specialty_description,
	SUM(prescription.total_claim_count) AS total_claims
	FROM prescriber AS prescriber 
	INNER JOIN prescription AS prescription 
	ON prescriber.npi = prescription.npi
	GROUP BY prescriber.npi,prescriber.nppes_provider_first_name,
		 prescriber.nppes_provider_last_org_name,
		 prescriber.specialty_description
	ORDER BY total_claims DESC
	LIMIT 1;



-- 2. 
    -- a. Which specialty had the most total number of claims (totaled over all drugs)?
	
	SELECT prescriber.specialty_description,
	       SUM(prescription.total_claim_count) AS total_claim
           FROM prescriber
		INNER JOIN prescription 
		ON prescriber.npi = prescription.npi
		GROUP BY prescriber.specialty_description
		ORDER BY total_claim DESC;

		
-- b. Which specialty had the most total number of claims for opioids?
 
 SELECT prescriber.specialty_description,
	       SUM(prescription.total_claim_count) AS total_claim
           FROM prescriber
		INNER JOIN prescription 
		ON prescriber.npi = prescription.npi
		INNER JOIN drug 
		ON prescription.drug_name = drug.drug_name 
		WHERE drug.opioid_drug_flag = 'Y'
		GROUP BY prescriber.specialty_description
		ORDER BY total_claim DESC;
		
  -- 3. 
    -- a. Which drug (generic_name) had the highest total drug cost?
  SELECT drug.generic_name, 
         SUM(total_drug_cost) AS total_cost 
		 FROM drug 
		 INNER JOIN prescription 
		 ON drug.drug_name = prescription.drug_name
		 GROUP BY drug.generic_name
		 ORDER BY total_cost DESC;

	b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**


	SELECT drug.generic_name,
	   ROUND(SUM(prescription.total_drug_cost)/ SUM(prescription.total_day_supply),2) cost_per_day
	   FROM drug 
	   INNER JOIN prescription
	   ON drug.drug_name = prescription.drug_name
	   GROUP BY drug.generic_name
	   ORDER BY cost_per_day DESC
	   LIMIT 1;

	   -- ANSWER c1 esterase inhibitor 3495.22


	   -- 4. 
    -- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 


	SELECT 
	drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type
	FROM drug;
	-- ANSWER RUN the Query 

	-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.


	SELECT drug_type, SUM(total_drug_cost)::MONEY AS total_cost 
	FROM (SELECT drug.drug_name ,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
    ELSE 'neither'
	END AS drug_type , total_drug_cost 
	 
	FROM drug AS drug
	INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name ) AS drug_cost 
	WHERE drug_type IN ('opioid','antibiotic')
	GROUP BY drug_type;

	-- ANSWER run the query 



	-- 5. 
    -- a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

		SELECT COUNT (DISTINCT cbsa) AS number_of_cbsas
		FROM cbsa
		INNER JOIN fips_county ON cbsa.fipscounty = fips_county.fipscounty 
		WHERE fips_county.state = 'TN';

		 -- Other way of doing it 
        SELECT  cbsa
		FROM cbsa
		INNER JOIN fips_county 
		USING (fipscounty )
		WHERE state = 'TN'
		-- ANSWER 10
		  b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
	SELECT cbsa.cbsa,
	       cbsa.cbsaname,
		   SUM(population.population) AS total_population 
		   FROM cbsa
		   INNER JOIN population
		   ON cbsa.fipscounty = population.fipscounty
		
		   GROUP BY cbsa.cbsa, cbsa.cbsaname
		   ORDER BY total_population ASC
		   LIMIT 1;
		    -- ORDER BY total_population DESC;
			-- ANSWER run the query

		   -- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
		   SELECT  fc.county,
		           p.population
		          
		          FROM population  AS p
				  INNER JOIN fips_county AS fc
				  ON p.fipscounty = fc.fipscounty
				  LEFT JOIN cbsa
				  ON fc.fipscounty = cbsa.fipscounty 
				  WHERE cbsa.cbsa IS NULL
				  ORDER BY p.population DESc

				  
				  ANSWER largest county is sevier in terms of population 

L
                  
		  -- 6. 
    -- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

	SELECT drug_name,total_claim_count 
	FROM prescription
	WHERE total_claim_count >= 3000
	
   -- ANSWER total of 9 rows with drug name and total of cliams run query for result 

 -- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
   
	SELECT d.drug_name,
	       p.total_claim_count,d.opioid_drug_flag,
	 CASE
	 WHEN d.opioid_drug_flag = 'Y' THEN 'YES'
	 ELSE 'NO'
	 END AS is_opioid
	 FROM prescription P
	 INNER JOIN drug AS d
	 ON p.drug_name = d.drug_name
	WHERE total_claim_count >= 3000;

	-- ANSWER out of 9 rows only 2 rows has opioid



	
	    -- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

		SELECT p.drug_name,
		       p.total_claim_count,
			   CASE  WHEN d.opioid_drug_flag = 'Y' THEN 'YES'
			   ELSE 'NO'
			   END AS is_opioid,
			   pr.nppes_provider_first_name AS prescriber_first_name,
			   pr.nppes_provider_last_org_name AS prescriber_last_name
			   FROM prescription AS p
			   INNER JOIN drug AS d
			   ON p.drug_name = d.drug_name
			   INNER JOIN prescriber AS pr 
			   on p.npi = pr.npi
			   WHERE p.total_claim_count >= 3000;
		
			   -- ANSWER run the query to see the result 



-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

    -- a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


SELECT 	prescriber.npi
	, 	drug.drug_name
FROM prescriber  
CROSS JOIN drug 
	WHERE 	prescriber.specialty_description ='Pain Management' 
	AND 	prescriber.nppes_provider_city = 'NASHVILLE' 
	AND 	drug.opioid_drug_flag = 'Y'


-- ANSWER for result run the query 



   -- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count)

   SELECT pr.npi
	,	d.drug_name
FROM prescriber AS pr
	INNER JOIN drug AS d 
		ON d.opioid_drug_flag = 'Y'
WHERE pr.specialty_description = 'Pain Management' 
    AND pr.nppes_provider_city = 'NASHVILLE';

	-- OTHER way
	SELECT prescriber.npi
		,	drug.drug_name
		,	SUM(prescription.total_claim_count) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;

	-- ANSWER to see the all records run the query

 -- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
 
SELECT prescriber.npi
		,	drug.drug_name
		,	COALESCE(SUM(prescription.total_claim_count), 0) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;


 