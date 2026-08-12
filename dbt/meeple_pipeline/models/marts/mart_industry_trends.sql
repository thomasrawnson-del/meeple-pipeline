select
    incorporation_year,
    company_type,
    count(*) as companies_incorporated
from {{ ref('int_company_incorporations') }}
where incorporation_year is not null
group by incorporation_year, company_type
order by incorporation_year, company_type