use hw4;

--  #1
select 
	missionname, 
    rockets.rocketname, 
    organizations.orgname, 
    launch_sites.sitename, 
    destination,
    launchyear
from missions
join rockets on missions.rocketid = rockets.rocketid
join launch_sites on missions.siteid = launch_sites.siteid
join organizations on rockets.orgid = organizations.orgid
order by launchyear desc, missionname;

-- #2
select
	missionname,
    rockets.rocketname,
    payloads.payloadname,
    payloads.payloadtype,
    payloads.masskg
from missions
join rockets on missions.rocketid = rockets.rocketid
join payloads on missions.missionid = payloads.missionid
where launchyear = 2024
order by masskg desc;

-- #3
select
	sitename,
    missions.missionname,
    rockets.rocketname,
    missions.launchyear
from launch_sites
left join missions on launch_sites.siteid = missions.siteid
left join rockets on missions.rocketid = rockets.rocketid
where launchyear is null or launchyear = 2024
order by sitename;
 
 -- #4
with payload_sums as(
	select 
		organizations.orgid,
        sum(payloads.masskg) as total_payload_mass
	from organizations
    join rockets on rockets.orgid = organizations.orgid
    join missions on missions.rocketid = rockets.rocketid
    join payloads on payloads.missionid = missions.missionid
    group by organizations.orgid
) select 
	orgname,
    headquarterscountry,
    orgtype,
    total_payload_mass
from organizations
join payload_sums on organizations.orgid = payload_sums.orgid
order by total_payload_mass desc;

-- #5
with country_payload_sums as(
	select 
		countries.countrycode,
        sum(payloads.masskg) as total_payload_mass
	from countries
    join launch_sites on launch_sites.countrycode = countries.countrycode
    join missions on missions.siteid = launch_sites.siteid
    join payloads on payloads.missionid = missions.missionid
    group by countries.countrycode
),
total_missions as (
	select 
		countries.countrycode,
        count(missions.missionid) as total_missions
	from countries
    join launch_sites on launch_sites.countrycode = countries.countrycode
    join missions on missions.siteid = launch_sites.siteid
    group by countries.countrycode
) select
	countryname,
    total_missions,
    total_payload_mass
from countries
join country_payload_sums on country_payload_sums.countrycode = countries.countrycode
join total_missions on total_missions.countrycode = countries.countrycode
order by total_payload_mass desc; 

	


