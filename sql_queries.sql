/*  Project Name: Istanbul 
    By: Ercan Sen
    Date: 12-10-2020
    Does: Aggregates the ballot box data into a neighborhood-wise election results and political features database,
          using a series of SQL queries 
*/



-- As scraped from the web, the results for the 7 elections in our analysis are in 7 csv files, with each ballot box as a row of the dataset
-- The column names differ from one election to the other, since participating candidates/parties/proposals change
-- In this sequence of SQL queries, the purpose is to create a database with tables for districts, neighborhoods, and neighborhood-wise election results
--   (obtained after aggregation)


/* STEP 1: Temporary Tables for Ballot Box Data */

-- Creates the temporary tables with the same columns as the raw csv file for each corresponding election, 
--   in order to import the raw (unaggregated) election results
-- Columns (semantically) and their corresponding data types need to be congruent as the csv file for every election
-- Common columns that appear every time are district (shorter VARCHAR), neighborhood (longer VARCHAR), registered, voted, valid (all INTEGERs)
-- Next, copies the data in csv files into the temporary tables



/* STEP 2:  districts and neighborhoods Tables */

-- First, creates the districts table, using the unique district names in the most recent (2019-06) election. Assigns unique IDs for each district,
--   multiples of 100, i.e. 100, 200, 300, …
-- Neighborhood IDs are designed so that they all start with the ID of the district they belong in, 
--   and neighborhoods are identified using sequential two-digit numbers for their IDs
-- Next, creates the neighborhoods table, using unique district-neighborhood pairs
-- Assigns the ID values using RANK() OVER PARTITION, with the neighborhoods within each district ordered alphabetically

-- Note that neighborhood is the sub-division of district, and district is the sub-division of the city (Istanbul in our case)
-- Note that the maximum number of neighborhoods in a district is 62, in the district 'SILE', 
--   so my design of the database with 100-fold district IDs and 2-digit neighborhood IDs is an accurate and consistent representation
-- Note that neighborhood names don't have to be unique between districts, 
--   but they are unique within each district, hence we use the unique district-neighborhood pairs



/* STEP 3:  Aggregating the Data, Migrating to Final Tables, Engineering New Features */

-- Aggregates the data to obtain neighborhood-wise election results
-- Migrates aggregated data into the final tables in the database
-- Engineers additional political features that will be utilized for more accurate forecasts and creating clusters based on political parameters





/* STEP 1 begins */

/* LEGEND for Columns

Parties: 

    akp - ruling Justice and Development Party, lead by Erdogan, stands for conservatism, Islamism, ideologically right
    mhp - supports the government bloc, Nationalist Movement Party, right-wing, Turkish nationalism
    cumhur - formal name of the government bloc, means 'the public, people', in MP elections in 2018-06 voters were able to vote for the whole bloc

    chp - main opposition, Republican People's Party, Istanbul mayor Imamoglu's party, social-democratic but currently an umbrella for the whole opposition
    iyip - Good Party, split from 'mhp' when they joined government ('cumhur') bloc, center to right-wing
    sp - Felicity Party, ideologically similar to 'akp' (Islamism, conservatism), 
         yet opposes Erdogan's unquestionable authority and favors parliamentary system, instead of presidential
    millet - formal name of the opposition bloc, also means 'the nation, people'

    hdp - Peoples' Democratic Party, not formally a member of the 'millet' bloc but sometimes gives support from outside, 
          pro-Kurdish, social-democratic/left-wing


Candidates: 

    rte - stands for 'Recep Tayyip Erdogan', president, in power since 2003 (including time as prime minister), 
          changed constitution to increase his presidential authority, created a highly polarized nation to hold on to power

    ince - 'Muharrem Ince', 'chp's candidate for president in 2018-06 election, caused major hype in metropolitan areas and large cities, 
           yet could not keep it up as Erdogan secured presidency in first round
    aksener - 'Meral Aksener', 'iyip's leader and presidential candidate in 2018-06, has appeal to secular and centrist voters, 
              trying to forge an identity as the center-right leader of Turkey, yet as a former member of right-wing 'mhp' it is not as easy
    karamolla - 'Temel Karamollaoglu', 'sp's leader and presidential candidate, an old school Islamist 
                who is trying to shift his party's base away from Erdogan, toward the pro-democracy coalition

    selo - 'Selahattin Demirtas', 'hdp's former leader and presidential candidate in both presidential elections in 2018 and 2014, 
           imprisoned since 2016, very popular among Kurds, leftists, young voters

    gulenist - In 2015-06 elections, about a year before the coup d'etat attempt, 3 independent candidates for MP, who are 
               supporters of Gulen's Islamist cult, ran for election
    
    (Disclaimer: The inclusion of these candidates in this analysis is not an endorsement of any kind. Gulen's movement is a terrorist organization
                 who murdered thousands of civilians and threatened Turkey's regime during 2016 coup attempt. These candidates are included, 
                 in order to test the government's accusations that prominent opposition figures, or even ordinary citizens with opposing ideas, 
                 are pro-Gulen, although ironically Gulen and Erdogan used to be allies until very recently.)


Options:

    yes - a vote of 'yes', i.e. approval, in the 2017 constitutional referendum that proposed the parliamentary regime to tun into presidential, 
          allowing the president immense, unrestricted powers
    no - a vote of 'no', i.e. rejection, in the 2017 constitutional referendum

*/


-- ELECTION 1: June 23, 2019 (Mayoral Election Rerun)


-- Creates the temp table, names the columns and chooses the dtypes
-- Note that neighborhood names tend to be longer, hence the greater VARCHAR length 

CREATE TABLE reelect_2019 (
    district VARCHAR (50),
    neighborhood VARCHAR (100),
    registered INTEGER,
    voted INTEGER,
    valid INTEGER,
    akp INTEGER,
    chp INTEGER,
    sp INTEGER
);

-- Copies the data from the raw csv file and inserts the ballot box records into the temporary table

COPY reelect_2019
FROM '/Users/ercansen/Dropbox/apps/istanbul/2019-06/2019-06.csv' DELIMITER ',' CSV HEADER;



-- ELECTION 2: March 31, 2019 (Local)


-- Creates the temp table, names the columns and chooses the dtypes
-- Note that neighborhood names tend to be longer, hence the greater VARCHAR length 

CREATE TABLE local_2019 (
    district VARCHAR (50),
    neighborhood VARCHAR (100),
    registered INTEGER,
    voted INTEGER,
    valid INTEGER,
    akp INTEGER,
    chp INTEGER,
    sp INTEGER
);

-- Copies the data from the raw csv file and inserts the ballot box records into the temporary table

COPY local_2019
FROM '/Users/ercansen/Dropbox/apps/istanbul/2019-03/2019-03.csv' DELIMITER ',' CSV HEADER;



-- ELECTION 3: June 24, 2018  (General - MP)


-- Creates the temp table, names the columns and chooses the dtypes
-- Note that neighborhood names tend to be longer, hence the greater VARCHAR length 

CREATE TABLE mp_2018 (
    district VARCHAR (50),
    neighborhood VARCHAR (100),
    registered INTEGER,
    voted INTEGER,
    valid INTEGER,
    akp INTEGER,
    chp INTEGER,
    mhp INTEGER,
    iyip INTEGER,
    hdp INTEGER,
    sp INTEGER,
    cumhur INTEGER,
    millet INTEGER
);

-- Copies the data from the raw csv file and inserts the ballot box records into the temporary table

COPY mp_2018
FROM '/Users/ercansen/Dropbox/apps/istanbul/2018-06-MP/2018-06-MP.csv' DELIMITER ',' CSV HEADER;



-- ELECTION 4: June 24, 2018 (General - President)


-- Creates the temp table, names the columns and chooses the dtypes
-- Note that neighborhood names tend to be longer, hence the greater VARCHAR length

CREATE TABLE pres_2018 (
    district VARCHAR (50),
    neighborhood VARCHAR (100),
    registered INTEGER,
    voted INTEGER,
    valid INTEGER,
    rte INTEGER,
    ince INTEGER,
    aksener INTEGER,
    selo INTEGER,
    karamolla INTEGER
);

-- Copies the data from the raw csv file and inserts the ballot box records into the temporary table

COPY pres_2018
FROM '/Users/ercansen/Dropbox/apps/istanbul/2018-06-PRES/2018-06-PRES.csv' DELIMITER ',' CSV HEADER;



-- ELECTION 5: April 16, 2017 (Constitutional Referendum)


-- Creates the temp table, names the columns and chooses the dtypes
-- Note that neighborhood names tend to be longer, hence the greater VARCHAR length

CREATE TABLE ref_2017 (
    district VARCHAR (50),
    neighborhood VARCHAR (100),
    registered INTEGER,
    voted INTEGER,
    valid INTEGER,
    yes INTEGER,
    nop INTEGER
);

-- Copies the data from the raw csv file and inserts the ballot box records into the temporary table

COPY ref_2017
FROM '/Users/ercansen/Dropbox/apps/istanbul/2017-04/2017-04.csv' DELIMITER ',' CSV HEADER;



-- ELECTION 6: November 1, 2015 (General - MP)


-- Creates the temp table, names the columns and chooses the dtypes
-- Note that neighborhood names tend to be longer, hence the greater VARCHAR length

CREATE TABLE gen_nov_2015 (
    district VARCHAR (50),
    neighborhood VARCHAR (100),
    registered INTEGER,
    voted INTEGER,
    valid INTEGER,
    akp INTEGER,
    chp INTEGER,
    mhp INTEGER,
    hdp INTEGER,
    sp INTEGER
);

-- Copies the data from the raw csv file and inserts the ballot box records into the temporary table

COPY gen_nov_2015
FROM '/Users/ercansen/Dropbox/apps/istanbul/2015-11/2015-11.csv' DELIMITER ',' CSV HEADER;



-- ELECTION 7: June 7, 2015 (General - MP)


-- Creates the temp table, names the columns and chooses the dtypes
-- Note that neighborhood names tend to be longer, hence the greater VARCHAR length

CREATE TABLE gen_jun_2015 (
    district VARCHAR (50),
    neighborhood VARCHAR (100),
    registered INTEGER,
    voted INTEGER,
    valid INTEGER,
    akp INTEGER,
    chp INTEGER,
    mhp INTEGER,
    hdp INTEGER,
    sp INTEGER,
    gulenist INTEGER
);

-- Copies the data from the raw csv file and inserts the ballot box records into the temporary table

COPY gen_jun_2015
FROM '/Users/ercansen/Dropbox/apps/istanbul/2015-06/2015-06.csv' DELIMITER ',' CSV HEADER;


/* STEP 1 ends*/




/* STEP 2 begins*/


-- DISTRICTS


-- Creates sequence that starts with minimum value 100, and increments by 100

CREATE SEQUENCE districts_seq
MINVALUE 100
INCREMENT 100;


-- Creates the table 'districts' with columns for 'id' and 'district' (name)

CREATE TABLE districts (
    id INTEGER PRIMARY KEY DEFAULT NEXTVAL('districts_seq'),
    district VARCHAR (50) UNIQUE NOT NULL
);


-- Inserts the unique districts in the most recent election into the 'districts' table

INSERT INTO districts(district)
SELECT DISTINCT(district)
FROM reelect_2019
ORDER BY district;



-- NEIGHBORHOODS


-- Creates the table 'neighborhoods' with columns: 'id', 'dist_id', 'district' and 'neighborhood'
-- 'dist_id' (ID value of corresponding district) is a foreign key
-- The relationship between 'neighborhoods' and 'districts' is many-to-one

CREATE TABLE neighborhoods (
    id INTEGER PRIMARY KEY,
    dist_id INTEGER NOT NULL,
    district VARCHAR (50) NOT NULL,
    neighborhood VARCHAR (100) NOT NULL,
    CONSTRAINT fk_district                     -- adds foreign key constraint 
        FOREIGN KEY(dist_id)
            REFERENCES districts(id)
);


-- Populates the neighborhoods table by inserting records
-- Joins data from two tables and uses a subquery, to fill in the desired information

INSERT INTO neighborhoods 
    (id, dist_id, district, neighborhood)
(SELECT RANK () OVER (
                    PARTITION BY MAX(d.id)
                    ORDER BY r.neighborhood
                ) + MAX(d.id) id,              -- subquery using RANK OVER PARTITION to obtain neighborhood IDs
                MAX(d.id),                     -- MAX is arbitrary, other agg.fnc.s would work too since all d.id values are the same within group
                r.district, 
                r.neighborhood 
FROM reelect_2019 AS r
    RIGHT JOIN districts AS d
        ON d.district = r.district
WHERE RIGHT(r.neighborhood, 4) = 'MAH.'        -- only gets records that end with 'MAH.', abbreviation for the word neighborhood
GROUP BY r.district, r.neighborhood
ORDER BY r.district, r.neighborhood);



/* STEP 2 ends*/




/* STEP 3 begins*/

/* LEGEND for Calculated Columns' Names:

Common abbreviations in column names:
    _p : stands for percentage, regular way to calculate a party's vote share, percentage among valid votes
    _r : stands for registered, party's vote share percentage among registered voters
    _sp :  as mentioned earlier, sp, although in the opposition bloc, is an Islamist party and has similarities with the governing akp
             hence, the estimates that distribute sp voters into the two blocs test different cases
             in the low turnout case, 30% of sp voters lean toward opposition and 50% toward the government
             in the high turnout case, 40% lean toward opposition and 55% toward the government
    _low : represents the same low turnout case that is explained above (in _sp)
    _hi : represents the same high turnout case that is explained above (in _sp)
    _rc : stands for rate of change
    _rate_ch : also stands for rate of change
    cum_mil : ratio of government bloc into the opposition
    _dif : difference of number of votes (usually of the same party, between two elections)

*/



-- ELECTION 1: 2019 Mayoral Rerun

/* Notes: 

 Rate of change is calculated relative to the local election that was three months before current election
 In this election, many former akp voters chose not to vote, and many others switched to the opposition party
 The last feature akp_rc_turnout divides the rate of change of akp into change in number of votes casted, 
   to better represent the effect of swing votes rather than voters who chose not to participate
 
*/ 


-- Creates the table to hold aggregated neighborhood-wise elections results and additional features

CREATE TABLE reelect_19 AS
SELECT MAX(n.id) AS nbhd_id,         -- MAX is arbitrary, other agg.fnc.s would work too since all d.id values are the same within group
       r.district, 
       r.neighborhood, 
       SUM(r.registered) AS registered,
       SUM(r.voted) AS voted, 
       SUM(r.valid) AS valid, 
       SUM(r.akp) AS akp, 
       SUM(r.chp) AS chp, 
       SUM(r.sp) AS sp, 
       MAX(l.voted) AS voted_march,       -- Includes columns from the previous election, to engineer new features regarding changes in voter behavior
       MAX(l.akp) AS akp_march, 
       MAX(l.chp) AS chp_march
FROM reelect_2019 r
    INNER JOIN neighborhoods n
        ON n.neighborhood = r.neighborhood
        AND n.district = r.district
    INNER JOIN (
        SELECT neighborhood, district, SUM(voted), SUM(akp), SUM(chp)
        FROM local_2019
        GROUP BY neighborhood, district) l
        ON l.neighborhood = r.neighborhood
        AND l.district = r.district
GROUP BY r.district, r.neighborhood
ORDER BY nbhd_id;


-- Before the two elections in 2019, the original neighborhood with ID 3730 was split into three, and nbhd.s 3716 and 3730 are added
-- Since the older election results and the socioeconomic data have them as a single nbhd., the 2019 election results are summed into one

UPDATE reelect_19
SET registered = registered + (SELECT SUM(registered) FROM reelect_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    voted = voted + (SELECT SUM(voted) FROM reelect_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    valid = valid + (SELECT SUM(valid) FROM reelect_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    akp = akp + (SELECT SUM(akp) FROM reelect_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    chp = chp + (SELECT SUM(chp) FROM reelect_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    sp = sp + (SELECT SUM(sp) FROM reelect_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736)
WHERE nbhd_id = 3730;

DELETE FROM reelect_19
WHERE nbhd_id = 3716
OR nbhd_id = 3736;


-- Adds new columns for vote share percentages and other political features that are devised

ALTER TABLE reelect_19
ADD COLUMN turnout DECIMAL(6,2),
ADD COLUMN valid_p DECIMAL(5,2),
ADD COLUMN akp_p DECIMAL(5,2),
ADD COLUMN chp_p DECIMAL(5,2),
ADD COLUMN sp_p DECIMAL(5,2),
ADD COLUMN chp_sp INTEGER,
ADD COLUMN chp_sp_p DECIMAL(5,2),
ADD COLUMN chp_sp_r DECIMAL(5,2),
ADD COLUMN chp_sp30 INTEGER,
ADD COLUMN chp_sp30_p DECIMAL(5,2),
ADD COLUMN chp_sp30_r DECIMAL(5,2),
ADD COLUMN chp_sp40 INTEGER,
ADD COLUMN chp_sp40_p DECIMAL(5,2),
ADD COLUMN chp_sp40_r DECIMAL(5,2),
ADD COLUMN akp_sp50 INTEGER,
ADD COLUMN akp_sp50_p DECIMAL(5,2),
ADD COLUMN akp_sp50_r DECIMAL(5,2),
ADD COLUMN akp_sp55 INTEGER,
ADD COLUMN akp_sp55_p DECIMAL(5,2),
ADD COLUMN akp_sp55_r DECIMAL(5,2),
ADD COLUMN cum_mil_nosp DECIMAL(5,2),
ADD COLUMN cum_mil_low DECIMAL(5,2),
ADD COLUMN cum_mil_hi DECIMAL(5,2),
ADD COLUMN turnout_dif INTEGER,
ADD COLUMN akp_dif INTEGER,
ADD COLUMN chp_dif INTEGER,
ADD COLUMN turnout_rate_ch DECIMAL(7,3),
ADD COLUMN akp_rate_ch DECIMAL(5,2),
ADD COLUMN chp_rate_ch DECIMAL(5,2),
ADD COLUMN akp_rc_turnout DECIMAL(7,4); 


-- First, sets the values of those columns that do not rely on other calculated columns

UPDATE reelect_19
SET turnout = voted * 1.0 / registered * 100,
    valid_p = valid * 1.0 / voted * 100,
    akp_p = akp * 1.0 / valid * 100,
    chp_p = chp * 1.0 / valid * 100,
    sp_p = sp * 1.0 / valid * 100,
    chp_sp = chp + sp,
    chp_sp30 = chp + (sp * 3 / 10),
    chp_sp40 = chp + (sp * 4 / 10),
    akp_sp50 = akp + (sp * 1 / 2),
    akp_sp55 = akp + (sp * 55 / 100),
    turnout_dif = voted - voted_march,
    akp_dif = akp - akp_march,
    chp_dif = chp - chp_march;


-- Next, sets the values of the remaining columns

UPDATE reelect_19
SET chp_sp_p = chp_sp * 1.0 / valid * 100,
    chp_sp_r = chp_sp * 1.0 / registered * 100,
    chp_sp30_p = chp_sp30 * 1.0 / valid * 100,
    chp_sp30_r = chp_sp30 * 1.0 / registered * 100,
    chp_sp40_p = chp_sp40 * 1.0 / valid * 100,
    chp_sp40_r = chp_sp40 * 1.0 / registered * 100,
    akp_sp50_p = akp_sp50 * 1.0 / valid * 100,
    akp_sp50_r = akp_sp50 * 1.0 / registered * 100,
    akp_sp55_p = akp_sp55 * 1.0 / valid * 100,
    akp_sp55_r = akp_sp55 * 1.0 / registered * 100,
    cum_mil_nosp = akp * 1.0 / chp,
    cum_mil_low = akp_sp50 * 1.0 / chp_sp30,
    cum_mil_hi = akp_sp55 * 1.0 / chp_sp40,
    turnout_rate_ch = turnout_dif * 1.0 / voted_march,
    akp_rate_ch = akp_dif * 1.0 / akp_march,
    chp_rate_ch = chp_dif * 1.0 / chp_march,
    akp_rc_turnout = akp_dif * 1.0 / akp_march / NULLIF(turnout_dif, 0); 



-- ELECTION 2: 2019 Local (cancelled)

CREATE TABLE local_19 AS
SELECT MAX(n.id) AS nbhd_id, 
       l.district, 
       l.neighborhood, 
       SUM(registered) AS registered, 
       SUM(voted) AS voted, 
       SUM(valid) AS valid, 
       SUM(akp) AS akp, 
       SUM(chp) AS chp, 
       SUM(sp) AS sp
FROM local_2019 l
    INNER JOIN neighborhoods n
        ON n.neighborhood = l.neighborhood
        AND n.district = l.district
GROUP BY l.district, l.neighborhood
ORDER BY nbhd_id;

UPDATE local_19
SET registered = registered + (SELECT SUM(registered) FROM local_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    voted = voted + (SELECT SUM(voted) FROM local_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    valid = valid + (SELECT SUM(valid) FROM local_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    akp = akp + (SELECT SUM(akp) FROM local_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    chp = chp + (SELECT SUM(chp) FROM local_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736),
    sp = sp + (SELECT SUM(sp) FROM local_19 WHERE nbhd_id = 3716 OR nbhd_id = 3736)
WHERE nbhd_id = 3730;

DELETE FROM local_19
WHERE nbhd_id = 3716
OR nbhd_id = 3736;

ALTER TABLE local_19
ADD COLUMN turnout DECIMAL(6,2),
ADD COLUMN valid_p DECIMAL(5,2),
ADD COLUMN akp_p DECIMAL(5,2),
ADD COLUMN chp_p DECIMAL(5,2),
ADD COLUMN sp_p DECIMAL(5,2),
ADD COLUMN chp_sp INTEGER,
ADD COLUMN chp_sp_p DECIMAL(5,2),
ADD COLUMN chp_sp_r DECIMAL(5,2),
ADD COLUMN chp_sp30 INTEGER,
ADD COLUMN chp_sp30_p DECIMAL(5,2),
ADD COLUMN chp_sp30_r DECIMAL(5,2),
ADD COLUMN chp_sp40 INTEGER,
ADD COLUMN chp_sp40_p DECIMAL(5,2),
ADD COLUMN chp_sp40_r DECIMAL(5,2),
ADD COLUMN akp_sp50 INTEGER,
ADD COLUMN akp_sp50_p DECIMAL(5,2),
ADD COLUMN akp_sp50_r DECIMAL(5,2),
ADD COLUMN akp_sp55 INTEGER,
ADD COLUMN akp_sp55_p DECIMAL(5,2),
ADD COLUMN akp_sp55_r DECIMAL(5,2),
ADD COLUMN cum_mil_nosp DECIMAL(5,2),
ADD COLUMN cum_mil_low DECIMAL(5,2),
ADD COLUMN cum_mil_hi DECIMAL(5,2);

UPDATE local_19
SET turnout = voted * 1.0 / registered * 100,
    valid_p = valid * 1.0 / voted * 100,
    akp_p = akp * 1.0 / valid * 100,
    chp_p = chp * 1.0 / valid * 100,
    sp_p = sp * 1.0 / valid * 100,
    chp_sp = chp + sp,
    chp_sp30 = chp + (sp * 3 / 10),
    chp_sp40 = chp + (sp * 4 / 10),
    akp_sp50 = akp + (sp * 1 / 2),
    akp_sp55 = akp + (sp * 55 / 100);

UPDATE local_19
SET chp_sp_p = chp_sp * 1.0 / valid * 100,
    chp_sp_r = chp_sp * 1.0 / registered * 100,
    chp_sp30_p = chp_sp30 * 1.0 / valid * 100,
    chp_sp30_r = chp_sp30 * 1.0 / registered * 100,
    chp_sp40_p = chp_sp40 * 1.0 / valid * 100,
    chp_sp40_r = chp_sp40 * 1.0 / registered * 100,
    akp_sp50_p = akp_sp50 * 1.0 / valid * 100,
    akp_sp50_r = akp_sp50 * 1.0 / registered * 100,
    akp_sp55_p = akp_sp55 * 1.0 / valid * 100,
    akp_sp55_r = akp_sp55 * 1.0 / registered * 100,
    cum_mil_nosp = akp * 1.0 / chp,
    cum_mil_low = akp_sp50 * 1.0 / chp_sp30,
    cum_mil_hi = akp_sp55 * 1.0 / chp_sp40; 


-- ELECTION 3: 2018 MP

/* Notes:
 The feature mhp_iyip is the ratio of mhp votes into iyip votes. 
 In a country with a rising tide of nationalism, these two nationalist parties whose stances are at the two opposing poles 
   should be compared to obtain useful insights.
 (pro-Erdogan, conservative, authoritarian vs. anti-Erdogan, secular, democratic) 
*/

CREATE TABLE mp_18 AS
SELECT MAX(n.id) AS nbhd_id, 
       m.district, 
       m.neighborhood, 
       SUM(registered) AS registered, 
       SUM(voted) AS voted, 
       SUM(valid) AS valid, 
       SUM(akp) AS akp, 
       SUM(chp) AS chp, 
       SUM(mhp) AS mhp, 
       SUM(iyip) AS iyip, 
       SUM(hdp) AS hdp, 
       SUM(sp) AS sp, 
       SUM(cumhur) AS cumhur, 
       SUM(millet) AS millet
FROM mp_2018 m
    INNER JOIN neighborhoods n
        ON n.neighborhood = m.neighborhood
        AND n.district = m.district
GROUP BY m.district, m.neighborhood
ORDER BY nbhd_id;

ALTER TABLE mp_18
ADD COLUMN turnout DECIMAL(6,2),
ADD COLUMN valid_p DECIMAL(5,2),
ADD COLUMN akp_p DECIMAL(5,2),
ADD COLUMN chp_p DECIMAL(5,2),
ADD COLUMN mhp_p DECIMAL(5,2),
ADD COLUMN iyip_p DECIMAL(5,2),
ADD COLUMN hdp_p DECIMAL(5,2),
ADD COLUMN sp_p DECIMAL(5,2),
ADD COLUMN cumhur_p DECIMAL(5,2),         -- this is only those voters who casted their vote for the bloc, instead of one of the participating parties
ADD COLUMN millet_p DECIMAL(5,2),         -- not to be confused with the whole millet bloc vote, see above. 
ADD COLUMN millet_off INTEGER,            -- stands for millet official, the sum of chp, iyip, sp and millet, the official members of millet coalition
ADD COLUMN millet_off_p DECIMAL(5,2),
ADD COLUMN millet_off_r DECIMAL(5,2),
ADD COLUMN millet_hdp_nosp INTEGER,       -- the sum of chp, iyip, hdp and millet, the main parties in opposition (not includes sp, see the note on sp above)
ADD COLUMN millet_hdp_nosp_p DECIMAL(5,2),
ADD COLUMN millet_hdp_nosp_r DECIMAL(5,2),
ADD COLUMN millet_hdp_sp30 INTEGER,
ADD COLUMN millet_hdp_sp30_p DECIMAL(5,2),
ADD COLUMN millet_hdp_sp30_r DECIMAL(5,2),
ADD COLUMN millet_hdp_sp40 INTEGER,
ADD COLUMN millet_hdp_sp40_p DECIMAL(5,2),
ADD COLUMN millet_hdp_sp40_r DECIMAL(5,2),
ADD COLUMN cumhur_tot INTEGER,
ADD COLUMN cumhur_tot_p DECIMAL(5,2),
ADD COLUMN cumhur_tot_r DECIMAL(5,2),
ADD COLUMN cumhur_sp50 INTEGER,
ADD COLUMN cumhur_sp50_p DECIMAL(5,2),
ADD COLUMN cumhur_sp50_r DECIMAL(5,2),
ADD COLUMN cumhur_sp55 INTEGER,
ADD COLUMN cumhur_sp55_p DECIMAL(5,2),
ADD COLUMN cumhur_sp55_r DECIMAL(5,2),
ADD COLUMN mhp_iyip DECIMAL(5,2),
ADD COLUMN cum_mil_nosp DECIMAL(5,2),
ADD COLUMN cum_mil_low DECIMAL(5,2),
ADD COLUMN cum_mil_hi DECIMAL(5,2);

UPDATE mp_18
SET turnout = voted * 1.0 / registered * 100,
    valid_p = valid * 1.0 / voted * 100,
    akp_p = akp * 1.0 / valid * 100,
    chp_p = chp * 1.0 / valid * 100,
    mhp_p = mhp * 1.0 / valid * 100,
    iyip_p = iyip * 1.0 / valid * 100,
    hdp_p = hdp * 1.0 / valid * 100,
    sp_p = sp * 1.0 / valid * 100,
    cumhur_p = cumhur * 1.0 / valid * 100,
    millet_p = millet * 1.0 / valid * 100,
    millet_off = chp + iyip + sp + millet,
    millet_hdp_nosp = chp + iyip + millet + hdp,
    millet_hdp_sp30 = chp + iyip + millet + hdp + (sp * 3 / 10),
    millet_hdp_sp40 = chp + iyip + millet + hdp + (sp * 4 / 10),
    cumhur_tot = akp + mhp + cumhur,
    cumhur_sp50 = akp + mhp + cumhur + (sp * 5 / 10),
    cumhur_sp55 = akp + mhp + cumhur + (sp * 55 / 100),
    mhp_iyip = mhp * 1.0 / NULLIF(iyip, 0);

UPDATE mp_18
SET millet_off_p = millet_off * 1.0 / valid * 100,
    millet_off_r = millet_off * 1.0 / registered * 100,
    millet_hdp_nosp_p = millet_hdp_nosp * 1.0 / valid * 100,
    millet_hdp_nosp_r = millet_hdp_nosp * 1.0 / registered * 100,
    millet_hdp_sp30_p = millet_hdp_sp30 * 1.0 / valid * 100,
    millet_hdp_sp30_r = millet_hdp_sp30 * 1.0 / registered * 100,
    millet_hdp_sp40_p = millet_hdp_sp40 * 1.0 / valid * 100,
    millet_hdp_sp40_r = millet_hdp_sp40 * 1.0 / registered * 100,
    cumhur_tot_p = cumhur_tot * 1.0 / valid * 100,
    cumhur_tot_r = cumhur_tot * 1.0 / registered * 100,
    cumhur_sp50_p = cumhur_sp50 * 1.0 / valid * 100,
    cumhur_sp50_r = cumhur_sp50 * 1.0 / registered * 100,
    cumhur_sp55_p = cumhur_sp55 * 1.0 / valid * 100,
    cumhur_sp55_r = cumhur_sp55 * 1.0 / registered * 100,
    cum_mil_nosp = cumhur_tot * 1.0 / millet_hdp_nosp,
    cum_mil_low = cumhur_sp50 * 1.0 / millet_hdp_sp30,
    cum_mil_hi = cumhur_sp55 * 1.0 / millet_hdp_sp40; 



-- ELECTION 4: 2018 Presidential

/* Notes:
 The feature cumhur_tot_mp (cumhur bloc's total vote in the mp elections) is included to compare akp's vote in mp election 
   and their candidate rte's vote in presidential
*/

CREATE TABLE pres_18 AS
SELECT MAX(n.id) AS nbhd_id, 
       p.district, 
       p.neighborhood, 
       SUM(p.registered) AS registered, 
       SUM(p.voted) AS voted, 
       SUM(p.valid) AS valid,
       SUM(p.rte) AS rte, 
       SUM(p.ince) AS ince, 
       SUM(p.aksener) AS aksener, 
       SUM(p.selo) AS selo, 
       SUM(p.karamolla) AS karamolla, 
       (MAX(m.akp)+MAX(m.mhp)+MAX(m.cumhur)) AS cumhur_tot_mp
FROM pres_2018 p
    INNER JOIN neighborhoods n
        ON n.neighborhood = p.neighborhood
        AND n.district = p.district
    LEFT JOIN (
        SELECT district, neighborhood, SUM(akp) akp, SUM(mhp) mhp, SUM(cumhur) cumhur
        FROM mp_2018
        GROUP BY district, neighborhood
        ) m
        ON m.neighborhood = p.neighborhood
        AND m.district = p.district
GROUP BY p.district, p.neighborhood
ORDER BY nbhd_id;

ALTER TABLE pres_18
ADD COLUMN turnout DECIMAL(6,2),
ADD COLUMN valid_p DECIMAL(5,2),
ADD COLUMN rte_p DECIMAL(5,2),
ADD COLUMN ince_p DECIMAL(5,2),
ADD COLUMN aksener_p DECIMAL(5,2),
ADD COLUMN selo_p DECIMAL(5,2),
ADD COLUMN karamolla_p DECIMAL(5,2),
ADD COLUMN rte_r DECIMAL(5,2),
ADD COLUMN ince_r DECIMAL(5,2),
ADD COLUMN aksener_r DECIMAL(5,2),
ADD COLUMN selo_r DECIMAL(5,2),
ADD COLUMN karamolla_r DECIMAL(5,2),
ADD COLUMN millet_off INTEGER,
ADD COLUMN millet_off_p DECIMAL(5,2),
ADD COLUMN millet_off_r DECIMAL(5,2),
ADD COLUMN millet_hdp_nosp INTEGER,
ADD COLUMN millet_hdp_nosp_p DECIMAL(5,2),
ADD COLUMN millet_hdp_nosp_r DECIMAL(5,2),
ADD COLUMN millet_hdp_sp30 INTEGER,
ADD COLUMN millet_hdp_sp30_p DECIMAL(5,2),
ADD COLUMN millet_hdp_sp30_r DECIMAL(5,2),
ADD COLUMN millet_hdp_sp40 INTEGER,
ADD COLUMN millet_hdp_sp40_p DECIMAL(5,2),
ADD COLUMN millet_hdp_sp40_r DECIMAL(5,2),
ADD COLUMN cumhur_sp50 INTEGER,
ADD COLUMN cumhur_sp50_p DECIMAL(5,2),
ADD COLUMN cumhur_sp50_r DECIMAL(5,2),
ADD COLUMN cumhur_sp55 INTEGER,
ADD COLUMN cumhur_sp55_p DECIMAL(5,2),
ADD COLUMN cumhur_sp55_r DECIMAL(5,2),
ADD COLUMN cum_mil_nosp DECIMAL(5,2),
ADD COLUMN cum_mil_low DECIMAL(5,2),
ADD COLUMN cum_mil_hi DECIMAL(5,2),
ADD COLUMN rte_change INTEGER,
ADD COLUMN rte_change_cum DECIMAL(7,3),
ADD COLUMN rte_change_reg DECIMAL(7,3);

UPDATE pres_18
SET turnout = voted * 1.0 / registered * 100,
    valid_p = valid * 1.0 / voted * 100,
    rte_p = rte * 1.0 / valid * 100,
    ince_p = ince * 1.0 / valid * 100,
    aksener_p = aksener * 1.0 / valid * 100,
    selo_p = selo * 1.0 / valid * 100,
    karamolla_p = karamolla * 1.0 / valid * 100,
    rte_r = rte * 1.0 / registered * 100,
    ince_r = ince * 1.0 / registered * 100,
    aksener_r = aksener * 1.0 / registered * 100,
    selo_r = selo * 1.0 / registered * 100,
    karamolla_r = karamolla * 1.0 / registered * 100,
    millet_off = ince + aksener + karamolla,
    millet_hdp_nosp = ince + aksener + selo,
    millet_hdp_sp30 = ince + aksener + selo + (karamolla * 3 / 10),
    millet_hdp_sp40 = ince + aksener + selo + (karamolla * 4 / 10),
    cumhur_sp50 = rte + (karamolla * 1 / 2),
    cumhur_sp55 = rte + (karamolla * 55 / 100),
    rte_change = rte - cumhur_tot_mp;

UPDATE pres_18
SET millet_off_p = millet_off * 1.0 / valid * 100,
    millet_off_r = millet_off * 1.0 / registered * 100,
    millet_hdp_nosp_p = millet_hdp_nosp * 1.0 / valid * 100,
    millet_hdp_nosp_r = millet_hdp_nosp * 1.0 / registered * 100,
    millet_hdp_sp30_p = millet_hdp_sp30 * 1.0 / valid * 100,
    millet_hdp_sp30_r = millet_hdp_sp30 * 1.0 / registered * 100,
    millet_hdp_sp40_p = millet_hdp_sp40 * 1.0 / valid * 100,
    millet_hdp_sp40_r = millet_hdp_sp40 * 1.0 / registered * 100,
    cumhur_sp50_p = cumhur_sp50 * 1.0 / valid * 100,
    cumhur_sp50_r = cumhur_sp50 * 1.0 / registered * 100,
    cumhur_sp55_p = cumhur_sp55 * 1.0 / valid * 100,
    cumhur_sp55_r = cumhur_sp55 * 1.0 / registered * 100,
    cum_mil_nosp = rte * 1.0 / millet_hdp_nosp,
    cum_mil_low = cumhur_sp50 * 1.0 / millet_hdp_sp30,
    cum_mil_hi = cumhur_sp55 * 1.0 / millet_hdp_sp40,
    rte_change_cum = rte_change * 1.0 / cumhur_tot_mp * 100,
    rte_change_reg = rte_change * 1.0 / registered * 100;





-- ELECTION 5: 2017 Referendum */

/* Notes: 
 The feature yes_no is the ratio of yes votes into no votes, similar to cum_mil ratios (features) on other elections
*/

CREATE TABLE ref_17 AS
SELECT MAX(n.id) AS nbhd_id, 
       r.district, 
       r.neighborhood, 
       SUM(registered) AS registered, 
       SUM(voted) AS voted, 
       SUM(valid) AS valid, 
       SUM(yes) AS yes, 
       SUM(nop) AS nop
FROM ref_2017 r
    INNER JOIN neighborhoods n
        ON n.neighborhood = r.neighborhood
        AND n.district = r.district
GROUP BY r.district, r.neighborhood
ORDER BY nbhd_id;

ALTER TABLE ref_17
ADD COLUMN turnout DECIMAL(6,2),
ADD COLUMN valid_p DECIMAL(6,2),
ADD COLUMN yes_p DECIMAL(6,2),
ADD COLUMN nop_p DECIMAL(6,2),
ADD COLUMN yes_r DECIMAL(6,2),
ADD COLUMN nop_r DECIMAL(6,2),
ADD COLUMN yes_no DECIMAL(6,2);

UPDATE ref_17
SET turnout = voted * 1.0 / registered * 100.0,
    valid_p = valid * 1.0 / voted * 100.0,
    yes_p = yes * 1.0 / valid * 100.0,
    nop_p = nop * 1.0 / valid * 100.0,
    yes_r = yes * 1.0 / registered * 100.0,
    nop_r = nop * 1.0 / registered * 100.0,
    yes_no = yes * 1.0 / nop;



-- ELECTION 6: November 2015 General
/* Notes: 
 hdp and akp's vote in same year's June elections are included, to compare how the vote share shifted
 It is important to analyze this effect, since between the two elections in 2015, 
   the government followed a nationalist rhetoric to criminalize and marginalize hdp and its voters
 It was a result of hdp's great success and popularity in June elections among non-Kurdish voters who didn't use to traditionally vote for hdp
*/

CREATE TABLE gen_nov_15 AS
SELECT MAX(n.id) AS nbhd_id, 
       g.district, 
       g.neighborhood, 
       SUM(g.registered) AS registered, 
       SUM(g.voted) AS voted, 
       SUM(g.valid) AS valid,
       SUM(g.akp) AS akp, 
       SUM(g.chp) AS chp, 
       SUM(g.mhp) AS mhp, 
       SUM(g.hdp) AS hdp, 
       SUM(g.sp) AS sp, 
       (MAX(p.akp) * 1.0 / MAX(p.registered) * 100.0) AS jun_akp_r, 
       (MAX(p.hdp) * 1.0 / MAX(p.registered) * 100.0) AS jun_hdp_r
FROM gen_nov_2015 g
    INNER JOIN neighborhoods n
        ON n.neighborhood = g.neighborhood
        AND n.district = g.district
    INNER JOIN (
        SELECT district, neighborhood, SUM(akp) akp, SUM(hdp) hdp, SUM(registered) registered
        FROM gen_jun_2015
        GROUP BY district, neighborhood
        ) p
        ON p.neighborhood = g.neighborhood
        AND p.district = g.district
GROUP BY g.district, g.neighborhood
ORDER BY nbhd_id;

ALTER TABLE gen_nov_15
ADD COLUMN akp_r DECIMAL(5,2),
ADD COLUMN hdp_r DECIMAL(5,2),
ADD COLUMN akp_dif DECIMAL(5,2),
ADD COLUMN hdp_dif DECIMAL(5,2),
ADD COLUMN turnout DECIMAL(5,2),
ADD COLUMN valid_p DECIMAL(5,2),
ADD COLUMN akp_p DECIMAL(5,2),
ADD COLUMN chp_p DECIMAL(5,2),
ADD COLUMN mhp_p DECIMAL(5,2),
ADD COLUMN hdp_p DECIMAL(5,2),
ADD COLUMN sp_p DECIMAL(5,2),
ADD COLUMN hdp_dif_per_vote DECIMAL(5,3),
ADD COLUMN akp_dif_per_vote DECIMAL(5,3);

UPDATE gen_nov_15
SET turnout = voted * 1.0 / registered * 100.0,
    valid_p = valid * 1.0 / voted * 100.0,
    akp_p = akp * 1.0 / valid * 100.0,
    chp_p = chp * 1.0 / valid * 100.0,
    mhp_p = mhp * 1.0 / valid * 100.0,
    hdp_p = hdp * 1.0 / valid * 100.0,
    sp_p = sp * 1.0 / valid * 100.0,
    hdp_r = hdp * 1.0 / registered * 100.0,
    akp_r = akp * 1.0 / registered * 100.0;

UPDATE gen_nov_15  
SET hdp_dif = hdp_r - jun_hdp_r,
    akp_dif = akp_r - jun_akp_r,
    hdp_dif_per_vote = (hdp_r - jun_hdp_r) / NULLIF(jun_hdp_r, 0),
    akp_dif_per_vote = (akp_r - jun_akp_r) / NULLIF(jun_akp_r, 0);


-- ELECTION 7: June 2015 General

CREATE TABLE gen_jun_15 AS
SELECT MAX(n.id) AS nbhd_id, 
       g.district, 
       g.neighborhood, 
       SUM(registered) AS registered, 
       SUM(voted) AS voted, 
       SUM(valid) AS valid, 
       SUM(akp) AS akp, 
       SUM(chp) AS chp, 
       SUM(mhp) AS mhp, 
       SUM(hdp) AS hdp, 
       SUM(sp) AS sp, 
       SUM(gulenist) AS gulenist
FROM gen_jun_2015 g
    INNER JOIN neighborhoods n
        ON n.neighborhood = g.neighborhood
        AND n.district = g.district
GROUP BY g.district, g.neighborhood
ORDER BY nbhd_id;

ALTER TABLE gen_jun_15
ADD COLUMN turnout DECIMAL(5,2),
ADD COLUMN valid_p DECIMAL(5,2),
ADD COLUMN akp_p DECIMAL(5,2),
ADD COLUMN chp_p DECIMAL(5,2),
ADD COLUMN mhp_p DECIMAL(5,2),
ADD COLUMN hdp_p DECIMAL(5,2),
ADD COLUMN sp_p DECIMAL(5,2),
ADD COLUMN gulenist_p DECIMAL(5,2),
ADD COLUMN hdp_r DECIMAL(5,2),
ADD COLUMN akp_r DECIMAL(5,2);

UPDATE gen_jun_15
SET turnout = voted * 1.0 / registered * 100.0,
    valid_p = valid * 1.0 / voted * 100.0,
    akp_p = akp * 1.0 / valid * 100.0,
    chp_p = chp * 1.0 / valid * 100.0,
    mhp_p = mhp * 1.0 / valid * 100.0,
    hdp_p = hdp * 1.0 / valid * 100.0,
    sp_p = sp * 1.0 / valid * 100.0,
    gulenist_p = gulenist * 1.0 / valid * 100.0,
    hdp_r = hdp * 1.0 / registered * 100.0,
    akp_r = akp * 1.0 / registered * 100.0;


-- Outputs the final tables to csv
COPY (SELECT * FROM reelect_19 ORDER BY nbhd_id) TO '/Users/ercansen/Desktop/apps/istanbul/sql outputs/reelect_19.csv' WITH CSV HEADER;
COPY (SELECT * FROM local_19 ORDER BY nbhd_id) TO '/Users/ercansen/Desktop/apps/istanbul/sql outputs/local_19.csv' WITH CSV HEADER;
COPY (SELECT * FROM mp_18 ORDER BY nbhd_id) TO '/Users/ercansen/Desktop/apps/istanbul/sql outputs/mp_18.csv' WITH CSV HEADER;
COPY (SELECT * FROM pres_18 ORDER BY nbhd_id) TO '/Users/ercansen/Desktop/apps/istanbul/sql outputs/pres_18.csv' WITH CSV HEADER;
COPY (SELECT * FROM ref_17 ORDER BY nbhd_id) TO '/Users/ercansen/Desktop/apps/istanbul/sql outputs/ref_17.csv' WITH CSV HEADER;
COPY (SELECT * FROM gen_nov_15 ORDER BY nbhd_id) TO '/Users/ercansen/Desktop/apps/istanbul/sql outputs/gen_nov_15.csv' WITH CSV HEADER;
COPY (SELECT * FROM gen_jun_15 ORDER BY nbhd_id) TO '/Users/ercansen/Desktop/apps/istanbul/sql outputs/gen_jun_15.csv' WITH CSV HEADER;
COPY (SELECT * FROM neighborhoods ORDER BY nbhd_id) TO '/Users/ercansen/Desktop/apps/istanbul/sql outputs/neighborhoods.csv' WITH CSV HEADER;