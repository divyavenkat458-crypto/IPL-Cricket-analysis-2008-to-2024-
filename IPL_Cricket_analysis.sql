create database IPL_Cricket_Analysis;
use IPL_Cricket_Analysis;
create table matches (
id int,
season int,
city text,
date text,
team1 text,
team2 text,
toss_winner text,
toss_decision text,
winner text,
player_of_match text,
venue text
);
use  IPL_Cricket_Analysis;
select * from matches;
 create table deliveries (
 match_id int,
 inning int,
 batting_team text,
 bowling_team text,
 batsman text,
 bowler text,
 runs_batsman int,
 runs_extra int,
 runs_total int,
 is_wicket int,
 dismissal_kind text
 );
 use  IPL_Cricket_Analysis;
select * from deliveries;

# Analysis queries

# Most successful teams by wins
select winner as team, count(*) as total_wins
from matches
group by winner 
order by total_wins desc;

# Does winning a toss help to win the match?
select 
count(*) as total_matches,
sum(case when toss_winner = 'winner' then 1 else 0 end) as total_toss_won,
round(sum(case when toss_winner = 'winner' then 1 else 0 end) / count(*) *100.00,2) as win_percent
from matches;
#  Field first or bat first - which wins more?
select toss_decision,
count(*) as total_matches,
sum(case when toss_winner = 'winner' then 1 else 0 end) as total_toss_won,
round(sum(case when toss_winner = 'winner' then 1 else 0 end) / count(*) *100.00,2) as win_percent
from matches
group by toss_decision;

# Top 10 run scorers of all time
select batsman,
sum(runs_batsman) as total_runs,
count(distinct match_id) as matches_played,
round(avg(runs_batsman),2) as avg_runs_per_ball
from deliveries
group by batsman
order by total_runs desc
limit 10;

# Top 10 wicket takers of all time
select bowler,
count(*) as total_wicket,
count(distinct match_id) as matches_bowled
from deliveries
where is_wicket = 1 
and dismissal_kind not in ('run out', 'retired hurt', 'obstructing the field')
group by bowler
order by total_wicket
limit 10;

# Most player of the match awards
select player_of_match,
count(*) as awards
from matches
where player_of_match is not null
group by player_of_match
order by awards desc
limit 10;

# Find the total runs scored by each batting team, calculate their average runs per match, 
# And rank the teams based on total runs scored?
select team, total_runs, matches_played,
round(total_runs / matches_played,2) as avg_run_per_match,
rank() over(order by total_runs desc) as run_rank
from 
(
select d.batting_team as team,
sum(d.runs_total) as total_runs,
count(distinct m.id) as matches_played
from deliveries d
join matches m
on d.match_id = m.id
group by d.batting_team
) as team_stats
order by run_rank;

# Find the top 5 batsmen based on their total runs scored, along with the number of matches they playes, 
# Rank them based on total runs
select batsman, total_runs, matches_played,
rank()over (order by total_runs desc) as run_rank
from
(
select d.batsman,
sum(d.runs_batsman) as total_runs,
count(distinct d.match_id) as matches_played
from deliveries d
group by d.batsman
) as played_stats
order by run_rank
limit 10;

# Season_wise total runs scored (batting trends over years)
select m.season,
sum(d.runs_total) as total_runs,
count(distinct m.id) as total_matches,
round(avg(d.runs_total),2) as avg_runs
from matches m
join deliveries d 
on m.id = d.match_id
group by m.season
order by m.season;

# Best bowling economy (min 100 overs bowled)
select bowler,
sum(runs_total) as run_given,
count(*) /6 as overs_bowled,
round(sum(runs_total) * 6.0 / count(*),2) as economy
from deliveries
group by bowler
having count(*) >= 600    # 100 over = 600 ball
order by economy asc
limit 10;

# Most matches host by venue
select venue, city , count(*) as matches_hosted
from matches
group by venue, city
order by matches_hosted
limit 10;