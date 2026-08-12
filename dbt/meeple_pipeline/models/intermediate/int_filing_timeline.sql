with companies as (
    select * from {{ ref('stg_companies') }}
),

filings as (
    select * from {{ ref('stg_filing_history') }}
)

select
    filings.company_number,
    companies.company_name,
    companies.company_status,
    filings.filing_type,
    filings.filing_category,
    filings.filing_date,
    filings.filing_description,
    year(filings.filing_date) as filing_year,
    quarter(filings.filing_date) as filing_quarter
from filings
inner join companies
    on filings.company_number = companies.company_number