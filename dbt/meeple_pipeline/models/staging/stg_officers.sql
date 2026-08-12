with source as (
    select * from {{ source('raw', 'raw_officers') }}
),

flattened as (
    select
        regexp_substr(file_name, '([0-9A-Z]+)\\.json$', 1, 1, 'e') as company_number,
        officer.value:name::string as officer_name,
        officer.value:officer_role::string as officer_role,
        officer.value:appointed_on::date as appointed_on,
        officer.value:resigned_on::date as resigned_on,
        officer.value:nationality::string as nationality,
        officer.value:date_of_birth:month::int as dob_month,
        officer.value:date_of_birth:year::int as dob_year,
        loaded_at
    from source,
    lateral flatten(input => raw_data:items) as officer
)

select * from flattened