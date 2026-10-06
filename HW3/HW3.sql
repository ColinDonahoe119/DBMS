use hw;
-- Fix text columns so they can be keys
ALTER TABLE countries    MODIFY countrycode VARCHAR(3);
ALTER TABLE operators    MODIFY headquarterscountry VARCHAR(3);
ALTER TABLE power_plants MODIFY countrycode VARCHAR(3);

-- Primary keys
ALTER TABLE countries          ADD PRIMARY KEY (countrycode);
ALTER TABLE operators          ADD PRIMARY KEY (operatorid);
ALTER TABLE fuel_types         ADD PRIMARY KEY (fuelid);
ALTER TABLE power_plants       ADD PRIMARY KEY (plantid);
ALTER TABLE generation_records ADD PRIMARY KEY (plantid, year);
ALTER TABLE emission_metrics   ADD PRIMARY KEY (plantid, year);

-- Foreign keys
ALTER TABLE operators
  ADD FOREIGN KEY (headquarterscountry) REFERENCES countries(countrycode);
ALTER TABLE power_plants
  ADD FOREIGN KEY (countrycode) REFERENCES countries(countrycode),
  ADD FOREIGN KEY (operatorid)  REFERENCES operators(operatorid),
  ADD FOREIGN KEY (fuelid)      REFERENCES fuel_types(fuelid);
ALTER TABLE generation_records
  ADD FOREIGN KEY (plantid) REFERENCES power_plants(plantid);
ALTER TABLE emission_metrics
  ADD FOREIGN KEY (plantid) REFERENCES power_plants(plantid);

select power_plants.plantname,
       countries.countryname,
       operators.operatorname,
       fuel_types.fuelcategory,
       fuel_types.fuelname,
       power_plants.capacitymw,
       power_plants.commissionyear
from power_plants
join countries on power_plants.countrycode = countries.countrycode
join operators on power_plants.operatorid = operators.operatorid
join fuel_types on power_plants.fuelid = fuel_types.fuelid
ORDER BY power_plants.capacitymw DESC;

SELECT power_plants.plantname,
       power_plants.countrycode,
       generation_records.year,
       generation_records.generationgwh
FROM power_plants
JOIN generation_records ON power_plants.plantid = generation_records.plantid
WHERE generation_records.year = 2024
ORDER BY generation_records.generationgwh DESC;

SELECT power_plants.plantname,
       power_plants.countrycode,
       generation_records.year,
       generation_records.generationgwh,
       emission_metrics.co2emissionstonnes
FROM power_plants
JOIN generation_records ON power_plants.plantid = generation_records.plantid
JOIN emission_metrics   ON generation_records.plantid = emission_metrics.plantid
                       AND generation_records.year    = emission_metrics.year
WHERE generation_records.year = 2024
ORDER BY emission_metrics.co2emissionstonnes ASC;

WITH operator_generation AS (
    SELECT power_plants.operatorid,
           SUM(generation_records.generationgwh) AS total_generation_gwh
    FROM power_plants
    JOIN generation_records ON power_plants.plantid = generation_records.plantid
    GROUP BY power_plants.operatorid
)
SELECT operators.operatorname,
       operators.headquarterscountry,
       operator_generation.total_generation_gwh
FROM operators
JOIN operator_generation ON operators.operatorid = operator_generation.operatorid
ORDER BY operator_generation.total_generation_gwh DESC;

WITH country_generation AS (
    SELECT power_plants.countrycode,
           SUM(generation_records.generationgwh) AS total_generation_gwh
    FROM power_plants
    JOIN generation_records ON power_plants.plantid = generation_records.plantid
    GROUP BY power_plants.countrycode
),
country_emissions AS (
    SELECT power_plants.countrycode,
           SUM(emission_metrics.co2emissionstonnes) AS total_co2_tonnes
    FROM power_plants
    JOIN emission_metrics ON power_plants.plantid = emission_metrics.plantid
    GROUP BY power_plants.countrycode
)
SELECT countries.countryname,
       country_generation.total_generation_gwh,
       country_emissions.total_co2_tonnes
FROM countries
JOIN country_generation ON countries.countrycode = country_generation.countrycode
JOIN country_emissions  ON countries.countrycode = country_emissions.countrycode
ORDER BY country_generation.total_generation_gwh DESC;