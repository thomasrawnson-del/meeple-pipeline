with source as (
    select * from {{ source('raw', 'raw_filing_history') }}
),

flattened as (
    select
        regexp_substr(file_name, '([0-9A-Z]+)\\.json$', 1, 1, 'e') as company_number,
        filing.value:type::string as filing_type,
        filing.value:date::date as filing_date,
        filing.value:description::string as filing_description,
        filing.value:category::string as filing_category,
        loaded_at
    from source,
    lateral flatten(input => raw_data:items) as filing
)

select * from flattened