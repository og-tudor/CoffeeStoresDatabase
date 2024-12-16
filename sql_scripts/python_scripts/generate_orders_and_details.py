import random
from datetime import datetime, timedelta

# Constraints
PRODUCT_IDS = range(1, 11)  # Product IDs 1-10
CUSTOMER_IDS = range(1, 11)  # Customer IDs 1-10
COFFEE_STORES = {
    1: [5, 6],  # Employees for store 1
    2: [7, 8],  # Employees for store 2
    3: [9, 10]  # Employees for store 3
}
ORDER_COUNT = 60  # Total number of orders
START_DATE = datetime(2023, 12, 1)  # Start date for orders
END_DATE = datetime(2024, 4, 29)  # End date for orders
MAX_PRODUCTS_PER_ORDER = 10  # Max items per order

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
    customer_id = random.choice(CUSTOMER_IDS)
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

# Write Orders to file
with open(orders_file, "w") as f_orders:
    f_orders.write("-- Populating Orders\n")
    f_orders.write("SET IDENTITY_INSERT Orders ON;\n")
    for order in orders:
        f_orders.write(f"INSERT INTO Orders (order_id, customer_id, employee_id, coffee_store_id, order_date) "
                       f"VALUES ({order[0]}, {order[1]}, {order[2]}, {order[3]}, '{order[4]}');\n")
    f_orders.write("SET IDENTITY_INSERT Orders OFF;\n\n")

# Write OrderDetails to file
with open(order_details_file, "w") as f_details:
    f_details.write("-- Populating OrderDetails\n")
    f_details.write("SET IDENTITY_INSERT OrderDetails ON;\n")
    for detail in order_details:
        f_details.write(f"INSERT INTO OrderDetails (order_detail_id, order_id, product_id, quantity) "
                        f"VALUES ({detail[0]}, {detail[1]}, {detail[2]}, {detail[3]});\n")
    f_details.write("SET IDENTITY_INSERT OrderDetails OFF;\n")

print(f"SQL files successfully written:\n- {orders_file}\n- {order_details_file}")
