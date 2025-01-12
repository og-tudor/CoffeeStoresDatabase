import random
from datetime import datetime, timedelta

# constants for the inserts
coffee_stores = [1, 2, 3]
expense_types = {
    "Electricity": (400, 600),
    "Water": (420, 560),
    "Salaries": (15000, 17000),
    "Rent": (400, 500),
    "Marketing": (200, 500),
    "Equipment": (200, 1000),
    "Repairs": (200,1000)
}
start_date = datetime(2024, 8, 1)
end_date = datetime(2025, 5, 1)

# generating expenses
def generate_expenses():
    expenses = []
    expense_id = 1
    current_date = start_date

    while current_date <= end_date:
        for store_id in coffee_stores:
            for expense_type, (min_cost, max_cost) in expense_types.items():
                if expense_type in ["Marketing", "Equipment", "Repairs"]:
                    # randomly include these expenses
                    if random.choice([True, False]):
                        cost = round(random.uniform(min_cost, max_cost), 2)
                        expenses.append((expense_id, store_id, cost, current_date, expense_type))
                        expense_id += 1
                else:
                    # mandatory expenses
                    cost = round(random.uniform(min_cost, max_cost), 2)
                    expenses.append((expense_id, store_id, cost, current_date, expense_type))
                    expense_id += 1
        current_date += timedelta(days=30)
    return expenses

# transform expenses into SQL script
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

# generate and export
expenses = generate_expenses()
sql_script = export_to_sql(expenses)

# write to the file
with open("populate_expenses.sql", "w") as file:
    file.write(sql_script)

print("SQL script generated: populate_expenses.sql")
