import os
from pathlib import Path
from dotenv import load_dotenv
from dagster_dbt import DbtProject

load_dotenv(dotenv_path=Path(__file__).parent.parent.parent.parent / ".env")

meeple_dbt_project = DbtProject(
    project_dir=Path(__file__).parent.parent.parent.parent / "dbt" / "meeple_pipeline",
    profiles_dir=Path.home() / ".dbt",
)

meeple_dbt_project.prepare_if_dev()