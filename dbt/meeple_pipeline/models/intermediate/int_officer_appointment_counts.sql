-- Note: officer identity is approximated via name + partial DOB, since
-- Companies House doesn't expose a stable officer ID across companies.
-- This can cause false merges for common names sharing a birth month/year.

with current_appointments as (
    select * from {{ ref('int_company_officers') }}
    where is_current_officer = true
),

appointment_counts as (
    select
        officer_name,
        dob_month,
        dob_year,
        count(distinct company_number) as company_count,
        array_agg(distinct company_name) as companies
    from current_appointments
    group by officer_name, dob_month, dob_year
)

select *
from appointment_counts
order by company_count desc