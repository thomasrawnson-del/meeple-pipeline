with companies as (
    select * from {{ ref('stg_companies') }}
),

officers as (
    select * from {{ ref('stg_officers') }}
)

select
    companies.company_number,
    companies.company_name,
    companies.company_status,
    officers.officer_name,
    officers.officer_role,
    officers.appointed_on,
    officers.resigned_on,
    officers.nationality,
    officers.dob_month,
    officers.dob_year,
    case when officers.resigned_on is null then true else false end as is_current_officer
from companies
inner join officers
    on companies.company_number = officers.company_number