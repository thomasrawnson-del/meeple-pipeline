from pathlib import Path
from dagster import AssetExecutionContext
from dagster_dbt import DbtCliResource, dbt_assets
from .project import meeple_dbt_project

dbt_resource = DbtCliResource(
    project_dir=meeple_dbt_project,
    profiles_dir=str(Path.home() / ".dbt"),
)


@dbt_assets(manifest=meeple_dbt_project.manifest_path)
def meeple_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()