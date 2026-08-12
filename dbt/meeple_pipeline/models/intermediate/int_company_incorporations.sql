with companies as (
    select * from {{ ref('stg_companies') }}
),

classified as (
    select
        company_number,
        company_name,
        company_status,
        date_of_creation,
        year(date_of_creation) as incorporation_year,
        sic_codes,
        case
            when array_contains('32400'::variant, sic_codes) then 'manufacturer'
            when array_contains('46499'::variant, sic_codes) then 'wholesaler'
            when array_contains('47640'::variant, sic_codes) then 'retailer'
            else 'other'
        end as company_type
    from companies
)

select * from classified