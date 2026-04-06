-- This is a sample of SQL queries used for data extraction and transformation in the marketing project.--
with google_facebook_ads as (
select ad_date, decode_url_part(url_parameters) as url_parameters, coalesce(spend, 0) as spend,
coalesce(impressions, 0) as impressions,
coalesce(reach, 0) as reach, coalesce(clicks, 0) as clicks, coalesce(leads, 0) as leads, 
coalesce(value, 0) as value
from google_ads_basic_daily
union all
select ad_date, decode_url_part(url_parameters) as url_parameters,
coalesce(spend, 0) spend, coalesce(impressions, 0) as impressions,
coalesce(reach, 0) as reach, coalesce(clicks, 0) as clicks, coalesce(leads, 0) as leads, 
coalesce(value, 0) as value
from facebook_ads_basic_daily),
fb_go_by_month as (
select date_trunc('month', ad_date) as ad_month, 
case
when lower(substring(url_parameters, 'utm_campaign=([^&#$]+)')) = 'nan' then null
else lower(substring(url_parameters, 'utm_campaign=([^&#$]+)')) end as utm_campaign, 
sum(spend) as total_spend,
sum(impressions) as total_impressions,
sum(clicks) as total_clicks,
sum(value) as total_value,
sum(clicks)::numeric/case when sum(impressions) = 0 then null else sum(impressions) end as CTR,
case when sum(clicks)>0 then 1.00 * sum(spend)/sum(clicks) end as CPC,
case when sum(impressions)>0 then sum(spend)::numeric/sum(impressions)*1000 end as CPM,
case when sum(spend)>0 then round(sum(value)::numeric/sum(spend), 2) end as ROMI
from google_facebook_ads
group by 1, 2)
select ad_month, utm_campaign, 
total_spend, 
total_clicks, 
total_value,
CTR, 
ctr/lag(CTR, 1) over(partition by utm_campaign order by ad_month) - 1 as PREV_CTR_perc,
CPC, 
cpc/lag(CPC, 1) over(partition by utm_campaign order by ad_month) - 1 as PREV_CPC_perc,
CPM, 
cpm/lag(cpm, 1) over(partition by utm_campaign order by ad_month) - 1 as PREV_CPM_perc,
ROMI,
romi/lag(ROMI, 1) over(partition by utm_campaign order by ad_month) - 1 as PREV_ROMI_perc
from fb_go_by_month
order by utm_campaign, ad_month;

