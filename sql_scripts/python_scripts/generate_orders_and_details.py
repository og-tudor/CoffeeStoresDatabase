import random
from datetime import datetime, timedelta

# Constraints
PRODUCT_IDS = range(1, 21)  # Product IDs 1-20
CUSTOMER_IDS = range(1, 11)  # Customer IDs 1-10
COFFEE_STORES = {
    1: [5, 6],  # Employees for store 1
    2: [7, 8],  # Employees for store 2
    3: [9, 10]  # Employees for store 3
}
ORDER_COUNT = 300  # Total number of orders
START_DATE = datetime(2023, 10, 1)  # Start date for orders
END_DATE = datetime(2024, 6, 1)     # End date for orders
MAX_PRODUCTS_PER_ORDER = 11  # Max items per order
MAX_VALUES_PER_INSERT = 1000  # Max rows per INSERT statement

# Function to generate random datetime within a range
def random_datetime(start, end):
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    return start + timedelta(seconds=random_seconds)

# Generate Orders
orders = []
order_id = 1
for _ in range(ORDER_COUNT):
    coffee_store_id = random.choice(list(COFFEE_STORES.keys()))
    employee_id = random.choice(COFFEE_STORES[coffee_store_id])  # From specific store
    # Randomly select a customer_id or None
    customer_id = random.choice([random.choice(CUSTOMER_IDS), None])
    order_date = random_datetime(START_DATE, END_DATE).strftime('%Y-%m-%d %H:%M:%S')
    orders.append((order_id, customer_id, employee_id, coffee_store_id, order_date))
    order_id += 1

# Generate OrderDetails
order_details = []
order_detail_id = 1
for order in orders:
    current_order_id = order[0]
    num_products = random.randint(1, MAX_PRODUCTS_PER_ORDER)
    products = random.sample(PRODUCT_IDS, num_products)  # Unique products per order
    for product_id in products:
        quantity = random.randint(1, 3)  # Quantity between 1 and 3
        order_details.append((order_detail_id, current_order_id, product_id, quantity))
        order_detail_id += 1

# File output paths
orders_file = "orders.sql"
order_details_file = "order_details.sql"

# Helper function to write batched inserts
def write_batched_inserts(file, table_name, columns, data, max_values_per_insert):
    file.write(f"-- Populating {table_name}\n")
    file.write(f"SET IDENTITY_INSERT {table_name} ON;\n")

    for i in range(0, len(data), max_values_per_insert):
        batch = data[i:i + max_values_per_insert]
        values = ",\n".join(
            f"({', '.join('NULL' if v is None else repr(v) for v in row)})" for row in batch
        )
        file.write(f"INSERT INTO {table_name} ({', '.join(columns)})\nVALUES\n{values};\n")

    file.write(f"SET IDENTITY_INSERT {table_name} OFF;\n\n")

# Write Orders to file
with open(orders_file, "w") as f_orders:
    write_batched_inserts(
        f_orders,
        "Orders",
        ["order_id", "customer_id", "employee_id", "coffee_store_id", "order_date"],
        orders,
        MAX_VALUES_PER_INSERT
    )

# Write OrderDetails to file
with open(order_details_file, "w") as f_details:
    write_batched_inserts(
        f_details,
        "OrderDetails",
        ["order_detail_id", "order_id", "product_id", "quantity"],
        order_details,
        MAX_VALUES_PER_INSERT
    )

print(f"SQL files successfully written:\n- {orders_file}\n- {order_details_file}")
