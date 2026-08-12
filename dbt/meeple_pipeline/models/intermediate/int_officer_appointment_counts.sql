-- Note: officer identity is approximated via name + partial DOB, since
-- Companies House doesn't expose a stable officer ID across companies.
-- This can cause false merges for common names sharing a birth month/year.
-- Corporate officers (companies acting as directors/secretaries for other
-- companies) have no date of birth and are flagged separately rather than
-- excluded, since they're legitimate data worth keeping visible.

with current_appointments as (
    select * from {{ ref('int_company_officers') }}
    where is_current_officer = true
),

appointment_counts as (
    select
        officer_name,
        dob_month,
        dob_year,
        case when dob_month is null and dob_year is null then true else false end as is_corporate_officer,
        count(distinct company_number) as company_count,
        array_agg(distinct company_name) as companies
    from current_appointments
    group by officer_name, dob_month, dob_year
)

select *
from appointment_counts
order by company_count desc