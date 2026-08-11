import snowflake.connector
import os 
from dotenv import load_dotenv

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))
print("Account value:", os.getenv("SNOWFLAKE_ACCOUNT"))

conn = snowflake.connector.connect(
    account=os.getenv("SNOWFLAKE_ACCOUNT"),
    user=os.getenv("SNOWFLAKE_USER"),
    password=os.getenv("SNOWFLAKE_PASSWORD"),
    warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
    database=os.getenv("SNOWFLAKE_DATABASE"),
    schema=os.getenv("SNOWFLAKE_SCHEMA"),
)

cur = conn.cursor()
cur.execute("SELECT CURRENT_VERSION()")
result = cur.fetchone()
print(f"Connected successfully. Snowflake version: {result[0]}")

cur.close()
conn.close()