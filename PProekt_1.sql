-- This is a sample of SQL queries used for data extraction and transformation in the marketing project.--
with daliy_spend as (
select ad_date, 'Google' AS platform,
spend AS daily_spend
from google_ads_basic_daily
union all
select ad_date, 'Facebook' AS platform,
spend AS daily_spend
from facebook_ads_basic_daily)
select ad_date as date, platform,
round(AVG(daily_spend), 2) AS avg_daily_spend,
MAX(daily_spend) AS max_daily_spend,
MIN(daily_spend) AS min_daily_spend
from daliy_spend
group by ad_date, platform
order by ad_date, platform;
