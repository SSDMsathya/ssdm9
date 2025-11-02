from sqlalchemy import create_engine, text

DATABASE_URL = "postgresql://postgres:ssdm123@localhost:54321/postgres"
SCHEMA = "ssdm9"

engine = create_engine(DATABASE_URL)

def test_connection():
    with engine.connect() as conn:
        result = conn.execute(text(f"SELECT table_name FROM information_schema.tables WHERE table_schema='{SCHEMA}'"))
        tables = [row[0] for row in result]
        print("Connected to database.")
        print("Tables in schema:", tables)

if __name__ == "__main__":
    test_connection()