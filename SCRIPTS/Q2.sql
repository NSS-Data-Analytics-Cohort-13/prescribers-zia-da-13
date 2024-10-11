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
	