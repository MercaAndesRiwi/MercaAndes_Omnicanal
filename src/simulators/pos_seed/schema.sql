CREATE SCHEMA IF NOT EXISTS colombia;
CREATE SCHEMA IF NOT EXISTS peru;
CREATE SCHEMA IF NOT EXISTS ecuador;
CREATE SCHEMA IF NOT EXISTS bolivia;
CREATE SCHEMA IF NOT EXISTS chile;
CREATE SCHEMA IF NOT EXISTS brazil;

DO $$
DECLARE
    schema_name TEXT;
BEGIN

    FOREACH schema_name IN ARRAY ARRAY[
        'colombia',
        'peru',
        'ecuador',
        'bolivia',
        'chile',
        'brazil'
    ]
    LOOP

        -- Sucursales
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I.branch (
                branch_id BIGINT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                branch_zip_code VARCHAR(20),
                city VARCHAR(100) NOT NULL,
                state VARCHAR(100) NOT NULL
            )
        ', schema_name);

        -- Categorías de productos
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I.product_category (
                product_category_id INTEGER PRIMARY KEY,
                name VARCHAR(100) NOT NULL
            )
        ', schema_name);

        -- Productos
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I.product (
                product_id VARCHAR(50) PRIMARY KEY,
                product_category_id INTEGER NOT NULL,
                sku VARCHAR(50) NOT NULL,
                name VARCHAR(150) NOT NULL,

                CONSTRAINT fk_product_category
                    FOREIGN KEY (product_category_id)
                    REFERENCES %I.product_category(product_category_id)
            )
        ', schema_name, schema_name);

        -- Ventas
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I.sale (
                sale_id BIGINT PRIMARY KEY,
                sale_at TIMESTAMP NOT NULL,
                branch_id BIGINT NOT NULL,
                payment_method VARCHAR(50) NOT NULL,

                CONSTRAINT fk_sale_branch
                    FOREIGN KEY (branch_id)
                    REFERENCES %I.branch(branch_id)
            )
        ', schema_name, schema_name);

        -- Productos incluidos en cada venta
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I.sale_item (
                sale_item_id BIGINT PRIMARY KEY,
                sale_id BIGINT NOT NULL,
                product_id VARCHAR(50) NOT NULL,
                sku VARCHAR(50) NOT NULL,
                quantity INTEGER NOT NULL,
                unit_price NUMERIC(12,2) NOT NULL,

                CONSTRAINT fk_sale_item_sale
                    FOREIGN KEY (sale_id)
                    REFERENCES %I.sale(sale_id),

                CONSTRAINT fk_sale_item_product
                    FOREIGN KEY (product_id)
                    REFERENCES %I.product(product_id)
            )
        ', schema_name, schema_name, schema_name);

    END LOOP;

END $$;