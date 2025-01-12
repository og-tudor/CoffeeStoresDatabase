import random
from datetime import datetime, timedelta

# orders constraints
# ids between 1 and 20
PRODUCT_IDS = range(1, 21)
CUSTOMER_IDS = range(1, 11)
# employee ids for each store
COFFEE_STORES = {
    1: [5, 6],
    2: [7, 8],
    3: [9, 10]
}
ORDER_COUNT = 600
START_DATE = datetime(2024, 8, 1)
END_DATE = datetime(2025, 5, 1)
MAX_PRODUCTS_PER_ORDER = 15
MAX_VALUES_PER_INSERT = 1000

# generates a random datetime between start and end
def random_datetime(start, end):
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    return start + timedelta(seconds=random_seconds)

# getting the orders
orders = []
order_id = 1
for _ in range(ORDER_COUNT):
    coffee_store_id = random.choice(list(COFFEE_STORES.keys()))
    employee_id = random.choice(COFFEE_STORES[coffee_store_id])
    # select either a customer id (registered) or None (guest)
    customer_id = random.choice([random.choice(CUSTOMER_IDS), None])
    order_date = random_datetime(START_DATE, END_DATE).strftime('%Y-%m-%d %H:%M:%S')
    orders.append((order_id, customer_id, employee_id, coffee_store_id, order_date))
    order_id += 1

# geenerating order details
order_details = []
order_detail_id = 1
for order in orders:
    current_order_id = order[0]
    num_products = random.randint(1, MAX_PRODUCTS_PER_ORDER)
    # selecting random products from the product list
    products = random.sample(PRODUCT_IDS, num_products)
    for product_id in products:
        quantity = random.randint(1, 3)
        order_details.append((order_detail_id, current_order_id, product_id, quantity))
        order_detail_id += 1


# writing to the SQL files
orders_file = "orders.sql"
order_details_file = "order_details.sql"

# batched inserts because sql only allows 1000 max values per insert
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

# writing to file ORDERS
with open(orders_file, "w") as f_orders:
    write_batched_inserts(
        f_orders,
        "Orders",
        ["order_id", "customer_id", "employee_id", "coffee_store_id", "order_date"],
        orders,
        MAX_VALUES_PER_INSERT
    )

# writing to file ORDER_DETAILS
with open(order_details_file, "w") as f_details:
    write_batched_inserts(
        f_details,
        "OrderDetails",
        ["order_detail_id", "order_id", "product_id", "quantity"],
        order_details,
        MAX_VALUES_PER_INSERT
    )

print(f"SQL files successfully written:\n- {orders_file}\n- {order_details_file}")
