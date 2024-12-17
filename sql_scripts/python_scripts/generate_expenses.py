import random
from datetime import datetime, timedelta

# Define constants
coffee_stores = [1, 2, 3]
expense_types = {
    "Electricity": (100, 200),
    "Water": (120, 200),
    "Salaries": (19000, 50000),
    "Rent": (500, 500),
    "Marketing": (300, 1200),
    "Equipment": (200, 1000),
    "Repairs": (200, 500)
}
start_date = datetime(2023, 10, 1)
end_date = datetime(2024, 6, 1)

# Generate expenses
def generate_expenses():
    expenses = []
    expense_id = 1
    current_date = start_date

    while current_date <= end_date:
        for store_id in coffee_stores:
            for expense_type, (min_cost, max_cost) in expense_types.items():
                if expense_type in ["Marketing", "Equipment", "Repairs"]:
                    # Include optional expenses randomly
                    if random.choice([True, False]):
                        cost = round(random.uniform(min_cost, max_cost), 2)
                        expenses.append((expense_id, store_id, cost, current_date, expense_type))
                        expense_id += 1
                else:
                    # Mandatory expenses
                    cost = round(random.uniform(min_cost, max_cost), 2)
                    expenses.append((expense_id, store_id, cost, current_date, expense_type))
                    expense_id += 1
        current_date += timedelta(days=30)  # Move to next month
    return expenses

# Export expenses to SQL format
def export_to_sql(expenses):
    sql_statements = ["SET IDENTITY_INSERT Expenses ON;", "INSERT INTO Expenses (expense_id, coffee_store_id, cost, date, expense_type) VALUES"]
    values = []
    for expense in expenses:
        expense_id, store_id, cost, date, expense_type = expense
        date_str = date.strftime('%Y-%m-%d')
        values.append(f"    ({expense_id}, {store_id}, {cost}, '{date_str}', '{expense_type}')")
    sql_statements.append(",\n".join(values) + ";")
    sql_statements.append("SET IDENTITY_INSERT Expenses OFF;")
    return "\n".join(sql_statements)

# Generate and export
expenses = generate_expenses()
sql_script = export_to_sql(expenses)

# Write to file
with open("populate_expenses.sql", "w") as file:
    file.write(sql_script)

print("SQL script generated: populate_expenses.sql")
