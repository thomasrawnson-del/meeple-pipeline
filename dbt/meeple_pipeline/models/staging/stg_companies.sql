with source as (
    select * from {{ source('raw', 'raw_company_profiles') }}
),

flattened as (
    select
        raw_data:company_number::string as company_number,
        raw_data:company_name::string as company_name,
        raw_data:company_status::string as company_status,
        raw_data:date_of_creation::date as date_of_creation,
        raw_data:type::string as company_type,
        raw_data:sic_codes as sic_codes,
        loaded_at
    from source
)

select * from flattened