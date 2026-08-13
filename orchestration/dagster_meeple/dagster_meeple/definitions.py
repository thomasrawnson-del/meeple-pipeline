from dagster import Definitions

from .assets import meeple_dbt_assets, dbt_resource

defs = Definitions(
    assets=[meeple_dbt_assets],
    resources={"dbt": dbt_resource},
)