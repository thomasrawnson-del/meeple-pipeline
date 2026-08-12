select
    officer_name,
    dob_month,
    dob_year,
    company_count,
    companies
from {{ ref('int_officer_appointment_counts') }}
where company_count >= 2
    and is_corporate_officer = false
order by company_count desc