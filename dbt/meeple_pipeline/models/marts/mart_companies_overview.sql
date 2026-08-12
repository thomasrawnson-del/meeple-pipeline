with companies as (
    select * from {{ ref('int_company_incorporations') }}
),

officer_counts as (
    select
        company_number,
        count(distinct officer_name) as current_officer_count
    from {{ ref('int_company_officers') }}
    where is_current_officer = true
    group by company_number
)

select
    companies.company_number,
    companies.company_name,
    companies.company_status,
    companies.company_type,
    companies.date_of_creation,
    companies.incorporation_year,
    coalesce(officer_counts.current_officer_count, 0) as current_officer_count
from companies
left join officer_counts
    on companies.company_number = officer_counts.company_number