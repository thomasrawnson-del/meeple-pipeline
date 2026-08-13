# ingestion/companies_house.py

import os
import time
import json
import logging
from datetime import date

import requests
import boto3
from dotenv import load_dotenv

load_dotenv()


API_KEY = os.getenv("COMPANIES_HOUSE_API_KEY")
BASE_URL = "https://api.company-information.service.gov.uk"
BUCKET = os.getenv("S3_BUCKET_NAME")

s3 = boto3.client("s3", region_name="eu-west-2")

logging.basicConfig(
    filename="logs/ingestion_run.log",
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)

def fetch(endpoint: str) -> dict:
    """Make a single authenticated GET request to Companies House."""
    url = f"{BASE_URL}{endpoint}"
    response = requests.get(url, auth=(API_KEY, ""))
    response.raise_for_status()
    time.sleep(0.5)
    return response.json()

def fetch_paginated(endpoint: str) -> list:
    """Fetch all pages of a paginated endpoint, return combined results."""
    items = []
    start_index = 0
    page_size = 100

    while True:
        paged_endpoint = f"{endpoint}?start_index={start_index}&items_per_page={page_size}"
        data = fetch(paged_endpoint)

        page_items = data.get("items", [])
        items.extend(page_items)

        total_results = data.get("total_results", len(items))
        start_index += page_size

        if start_index >= total_results or not page_items:
            break

    return items

def fetch_company_profile(company_number: str) -> dict:
    """Fetch the company profile — not paginated, single object."""
    return fetch(f"/company/{company_number}")


def fetch_officers(company_number: str) -> dict:
    """Fetch all officers for a company, handling pagination."""
    return {"items": fetch_paginated(f"/company/{company_number}/officers")}


def fetch_filing_history(company_number: str) -> dict:
    """Fetch all filing history for a company, handling pagination."""
    return {"items": fetch_paginated(f"/company/{company_number}/filing-history")}

def upload_to_s3(data: dict, company_number: str, data_type: str) -> None:
    """Upload one JSON payload to S3, partitioned by pull date."""
    today = date.today().isoformat()
    key = f"dev/{data_type}/{today}/{company_number}.json"
    s3.put_object(Bucket=BUCKET, Key=key, Body=json.dumps(data))

def process_company(company_number: str) -> None:
    """Fetch all three data types for one company and upload each."""
    try:
        profile = fetch_company_profile(company_number)
        upload_to_s3(profile, company_number, "profile")

        officers = fetch_officers(company_number)
        upload_to_s3(officers, company_number, "officers")

        filings = fetch_filing_history(company_number)
        upload_to_s3(filings, company_number, "filing-history")

        logging.info(f"Success: {company_number}")
        print(f"Done: {company_number}")

    except Exception as e:
        logging.error(f"Failed: {company_number} — {e}")
        print(f"Failed: {company_number} — {e}")

def load_company_numbers() -> list:
    """Load the target company number list from a JSON file."""
    with open("ingestion/company_numbers.json") as f:
        return json.load(f)


def main():
    company_numbers = load_company_numbers()
    print(f"Starting ingestion for {len(company_numbers)} companies")

    for company_number in company_numbers:
        process_company(company_number)

    print("Ingestion run complete.")


if __name__ == "__main__":
    main()