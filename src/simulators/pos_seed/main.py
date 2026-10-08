import os
import random

import psycopg


DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://mercaandes:mercaandes_password@localhost:5432/mercaandes_pos"
)

SEED = int(os.getenv("SEED", "42"))

COUNTRIES = [
    "colombia",
    "peru",
    "ecuador",
    "bolivia",
    "chile",
    "brazil",
]

BRANCHES_BY_COUNTRY = {
    "colombia": 50,
    "peru": 25,
    "ecuador": 20,
    "bolivia": 15,
    "chile": 20,
    "brazil": 10,
}

CATEGORIES = [
    "Technology",
    "Home",
    "Beauty",
    "Sports",
    "Clothing",
]


def get_connection():
    return psycopg.connect(DATABASE_URL)


def seed_categories(connection, country):
    with connection.cursor() as cursor:
        for category_id, category_name in enumerate(CATEGORIES, start=1):
            cursor.execute(
                f"""
                INSERT INTO {country}.product_category
                    (product_category_id, name)
                VALUES (%s, %s)
                ON CONFLICT (product_category_id) DO NOTHING
                """,
                (category_id, category_name),
            )


def seed_branches(connection, country):
    number_of_branches = BRANCHES_BY_COUNTRY[country]

    with connection.cursor() as cursor:
        for branch_id in range(1, number_of_branches + 1):
            cursor.execute(
                f"""
                INSERT INTO {country}.branch
                    (branch_id, name, branch_zip_code, city, state)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (branch_id) DO NOTHING
                """,
                (
                    branch_id,
                    f"MercaAndes {country.title()} {branch_id}",
                    f"{branch_id:05d}",
                    f"City {branch_id}",
                    f"State {branch_id}",
                ),
            )


def seed_products(connection, country):
    with connection.cursor() as cursor:
        for product_number in range(1, 101):
            category_id = random.randint(1, len(CATEGORIES))

            product_id = f"{country[:3].upper()}-PROD-{product_number:04d}"
            sku = f"{country[:3].upper()}-SKU-{product_number:04d}"

            cursor.execute(
                f"""
                INSERT INTO {country}.product
                    (product_id, product_category_id, sku, name)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (product_id) DO NOTHING
                """,
                (
                    product_id,
                    category_id,
                    sku,
                    f"Product {product_number}",
                ),
            )


def main():
    random.seed(SEED)

    print(f"Seed used: {SEED}")

    with get_connection() as connection:

        for country in COUNTRIES:
            print(f"Processing {country}...")

            seed_categories(connection, country)
            seed_branches(connection, country)
            seed_products(connection, country)

        connection.commit()

    print("Seed base successfully completed.")


if __name__ == "__main__":
    main()